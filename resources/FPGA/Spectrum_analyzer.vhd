-- =============================================================================
-- Spectrum Analyzer — Top Level
-- By: Patrick Purev, Xavier Onwu, Tausif Samin
--
-- Pipeline: Mic -> WM8731 (I2S) -> 256-pt FFT -> HEX + LED VU meter + VGA
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spectrum_analyzer is
    port (
        CLOCK_50    : in    std_logic;
        KEY         : in    std_logic_vector(3 downto 0);
        -- Audio codec (WM8731)
        AUD_XCK     : out   std_logic;
        AUD_BCLK    : in    std_logic;
        AUD_ADCLRCK : in    std_logic;
        AUD_ADCDAT  : in    std_logic;
        AUD_DACLRCK : out   std_logic;
        AUD_DACDAT  : out   std_logic;
        -- I2C configuration bus
        I2C_SCLK    : out   std_logic;
        I2C_SDAT    : inout std_logic;
        -- 7-segment displays (active low)
        HEX0        : out   std_logic_vector(6 downto 0);
        HEX1        : out   std_logic_vector(6 downto 0);
        HEX2        : out   std_logic_vector(6 downto 0);
        HEX3        : out   std_logic_vector(6 downto 0);
        HEX4        : out   std_logic_vector(6 downto 0);
        HEX5        : out   std_logic_vector(6 downto 0);
        HEX6        : out   std_logic_vector(6 downto 0);
        HEX7        : out   std_logic_vector(6 downto 0);
        -- VGA output pins
        VGA_BLANK_N : out std_logic;
        VGA_CLK     : out std_logic;
        VGA_HS      : out std_logic;
        VGA_SYNC_N  : out std_logic;
        VGA_VS      : out std_logic;
        VGA_R       : out std_logic_vector(7 downto 0);
        VGA_G       : out std_logic_vector(7 downto 0);
        VGA_B       : out std_logic_vector(7 downto 0);
          
        -- LEDs
        LEDG        : out   std_logic_vector(7 downto 0);
        LEDR        : out   std_logic_vector(17 downto 0)
    );
end entity spectrum_analyzer;

architecture rtl of spectrum_analyzer is

    -- ── Reset synchroniser ────────────────────────────────────────────
    signal rst_sync : std_logic_vector(2 downto 0);
    signal rst_n    : std_logic;

    -- ── PLL ───────────────────────────────────────────────────────────
    signal clk_12     : std_logic;
    signal pll_locked : std_logic;

    -- ── Codec init ────────────────────────────────────────────────────
    signal codec_ready : std_logic;

    -- ── I2S capture ───────────────────────────────────────────────────
    signal sample_valid  : std_logic;
    signal sample_data   : signed(15 downto 0);
    signal frame_ready   : std_logic;
    signal frame_rd_addr : std_logic_vector(7 downto 0);
    signal frame_rd_data : signed(15 downto 0);

    -- ── FFT engine ────────────────────────────────────────────────────
    signal fft_start : std_logic;
    signal fft_done  : std_logic;
    signal fft_busy  : std_logic;
    signal mag_valid : std_logic;
    signal mag_addr  : std_logic_vector(6 downto 0);
    signal mag_data  : std_logic_vector(15 downto 0);

    -- ── Peak detector ─────────────────────────────────────────────────
    signal peak_bin        : std_logic_vector(6 downto 0);
    signal peak_mag        : std_logic_vector(15 downto 0);
    signal peak_bin_hold   : std_logic_vector(6 downto 0);
    signal peak_mag_hold   : std_logic_vector(15 downto 0);
    signal peak_freq_hold  : std_logic_vector(15 downto 0);

    --Binary Coded Decimal magnitude for hex display decoding
    signal freq_bcd : std_logic_vector(19 downto 0);

    --Functional Audio Indicator
    signal flc : unsigned(19 downto 0);

    -- ── VU meter ─────────────────────────────────────────────────────
    signal abs_s : unsigned(15 downto 0);
    signal pk    : unsigned(15 downto 0);
    signal pd    : unsigned(19 downto 0);

    -- ── Double-dabble BCD conversion (combinational) ──────────────────
    function bin2bcd(bin : std_logic_vector(15 downto 0))
        return std_logic_vector
    is
        variable s : std_logic_vector(35 downto 0);
    begin
        s := (35 downto 16 => '0') & bin;
        for i in 0 to 15 loop
            if unsigned(s(19 downto 16)) >= 5 then
                s(19 downto 16) := std_logic_vector(unsigned(s(19 downto 16)) + 3);
            end if;
            if unsigned(s(23 downto 20)) >= 5 then
                s(23 downto 20) := std_logic_vector(unsigned(s(23 downto 20)) + 3);
            end if;
            if unsigned(s(27 downto 24)) >= 5 then
                s(27 downto 24) := std_logic_vector(unsigned(s(27 downto 24)) + 3);
            end if;
            if unsigned(s(31 downto 28)) >= 5 then
                s(31 downto 28) := std_logic_vector(unsigned(s(31 downto 28)) + 3);
            end if;
            if unsigned(s(35 downto 32)) >= 5 then
                s(35 downto 32) := std_logic_vector(unsigned(s(35 downto 32)) + 3);
            end if;
            s := s(34 downto 0) & '0';   -- left shift by 1
        end loop;
        return s(35 downto 16);
    end function;

begin

    -- ────────────────────────────────────────────────────────────────
    -- Reset synchroniser (KEY[0] active-low)
    -- ────────────────────────────────────────────────────────────────
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            rst_sync <= rst_sync(1 downto 0) & KEY(0);
        end if;
    end process;
    rst_n <= rst_sync(2);

    -- ────────────────────────────────────────────────────────────────
    -- PLL: 50 MHz -> 12.288 MHz for WM8731 MCLK
    -- ────────────────────────────────────────────────────────────────
    u_pll : entity work.pll_audio
        port map (
            inclk0  => CLOCK_50,
            c0      => clk_12,
            locked  => pll_locked
        );

    AUD_XCK     <= clk_12;
    AUD_DACDAT  <= AUD_ADCDAT;     -- loopback: mic -> headphone
    AUD_DACLRCK <= AUD_ADCLRCK;

    -- ────────────────────────────────────────────────────────────────
    -- WM8731 I2C initialisation
    -- ────────────────────────────────────────────────────────────────
    u_codec : entity work.wm8731_init
        port map (
            clk         => CLOCK_50,
            rst_n       => rst_n and pll_locked,
            config_done => codec_ready,
            i2c_sclk    => I2C_SCLK,
            i2c_sdat    => I2C_SDAT
        );

    -- ────────────────────────────────────────────────────────────────
    -- I2S capture
    -- ────────────────────────────────────────────────────────────────
    u_i2s : entity work.i2s_capture
        generic map (FFT_SIZE => 256)
        port map (
            clk          => CLOCK_50,
            rst_n        => rst_n,
            enable       => codec_ready,
            aud_bclk     => AUD_BCLK,
            aud_adclrck  => AUD_ADCLRCK,
            aud_adcdat   => AUD_ADCDAT,
            sample_valid => sample_valid,
            sample_data  => sample_data,
            frame_ready  => frame_ready,
            frame_addr   => frame_rd_addr,
            frame_data   => frame_rd_data
        );

    -- ────────────────────────────────────────────────────────────────
    -- FFT engine
    -- ────────────────────────────────────────────────────────────────
    u_fft : entity work.fft_core
        generic map (N => 256, STAGES => 8)
        port map (
            clk       => CLOCK_50,
            rst_n     => rst_n,
            start     => fft_start,
            done      => fft_done,
            busy      => fft_busy,
            load_addr => frame_rd_addr,
            load_data => frame_rd_data,
            mag_valid => mag_valid,
            mag_addr  => mag_addr,
            mag_data  => mag_data
        );

    -- Trigger FFT when a new frame is ready and engine is idle
    process(CLOCK_50, rst_n)
    begin
        if rst_n = '0' then
            fft_start <= '0';
        elsif rising_edge(CLOCK_50) then
            fft_start <= frame_ready and (not fft_busy);
        end if;
    end process;

    -- ────────────────────────────────────────────────────────────────
    -- Peak detector
    -- Tracks the highest-magnitude bin while magnitudes stream out.
    -- Latches result at the start of the next frame.
    -- ────────────────────────────────────────────────────────────────
    process(CLOCK_50, rst_n)
        variable v_freq : unsigned(31 downto 0);
    begin
        if rst_n = '0' then
            peak_bin       <= (others => '0');
            peak_mag       <= (others => '0');
            peak_bin_hold  <= (others => '0');
            peak_mag_hold  <= (others => '0');
            peak_freq_hold <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            -- Latch previous frame's peak and reset accumulators
            if fft_start = '1' then
                peak_bin_hold <= peak_bin;
                peak_mag_hold <= peak_mag;
                -- freq = bin * 188 Hz  (48000 / 256 ~ 188)
                v_freq := resize(unsigned(peak_bin) * to_unsigned(188, 16), 32);
                peak_freq_hold <= std_logic_vector(v_freq(15 downto 0));
                peak_bin <= (others => '0');
                peak_mag <= (others => '0');
            end if;

            -- Update running peak (skip DC bin 0)
            if mag_valid = '1' and mag_addr /= "0000000" then
                if unsigned(mag_data) > unsigned(peak_mag) then
                    peak_mag <= mag_data;
                    peak_bin <= mag_addr;
                end if;
            end if;
        end if;
    end process;

    -- ────────────────────────────────────────────────────────────────
    -- BCD conversion (combinational double-dabble)
    -- ────────────────────────────────────────────────────────────────
    freq_bcd <= bin2bcd(peak_freq_hold);

    -- ────────────────────────────────────────────────────────────────
    -- 7-Segment displays
    --   HEX7-4 : peak frequency in Hz (decimal, 5 digits but only 4 used)
    --   HEX3-0 : peak magnitude (hex)
    -- ────────────────────────────────────────────────────────────────
    d7 : entity work.hex_display port map (val => freq_bcd(19 downto 16), seg => HEX7);
    d6 : entity work.hex_display port map (val => freq_bcd(15 downto 12), seg => HEX6);
    d5 : entity work.hex_display port map (val => freq_bcd(11 downto  8), seg => HEX5);
    d4 : entity work.hex_display port map (val => freq_bcd( 7 downto  4), seg => HEX4);

    d3 : entity work.hex_display port map (val => peak_mag_hold(15 downto 12), seg => HEX3);
    d2 : entity work.hex_display port map (val => peak_mag_hold(11 downto  8), seg => HEX2);
    d1 : entity work.hex_display port map (val => peak_mag_hold( 7 downto  4), seg => HEX1);
    d0 : entity work.hex_display port map (val => peak_mag_hold( 3 downto  0), seg => HEX0);

    -- ────────────────────────────────────────────────────────────────
    -- Status LEDs (green)
    -- ────────────────────────────────────────────────────────────────
    LEDG(0) <= pll_locked;
    LEDG(1) <= codec_ready;
    LEDG(2) <= fft_busy;
    LEDG(7 downto 4) <= (others => '0');

    -- Frame heartbeat: LEDG(3) stays on for ~10 ms after each new frame
    process(CLOCK_50, rst_n)
    begin
        if rst_n = '0' then
            flc <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            if frame_ready = '1' then
                flc <= (others => '1');
            elsif flc /= 0 then
                flc <= flc - 1;
            end if;
        end if;
    end process;
    LEDG(3) <= '0' when flc = 0 else '1';

    -- ────────────────────────────────────────────────────────────────
    -- VU meter on red LEDs (peak-hold with decay)
    -- ────────────────────────────────────────────────────────────────
    abs_s <= unsigned(-signed(sample_data)) when sample_data(15) = '1'
             else unsigned(sample_data);

    process(CLOCK_50, rst_n)
    begin
        if rst_n = '0' then
            pk <= (others => '0');
            pd <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            if sample_valid = '1' then
                if abs_s > pk then
                    pk <= abs_s;
                elsif pd = 0 then
                    pd <= to_unsigned(50000, 20);
                    if pk > 0 then
                        pk <= pk - 1;
                    end if;
                else
                    pd <= pd - 1;
                end if;
            end if;
        end if;
    end process;

    process(pk)
    begin
        LEDR <= (others => '0');
        if pk >  64   then LEDR( 0) <= '1'; end if;
        if pk >  128  then LEDR( 1) <= '1'; end if;
        if pk >  256  then LEDR( 2) <= '1'; end if;
        if pk >  512  then LEDR( 3) <= '1'; end if;
        if pk >  1024 then LEDR( 4) <= '1'; end if;
        if pk >  1536 then LEDR( 5) <= '1'; end if;
        if pk >  2048 then LEDR( 6) <= '1'; end if;
        if pk >  3072 then LEDR( 7) <= '1'; end if;
        if pk >  4096 then LEDR( 8) <= '1'; end if;
        if pk >  5120 then LEDR( 9) <= '1'; end if;
        if pk >  6144 then LEDR(10) <= '1'; end if;
        if pk >  8192 then LEDR(11) <= '1'; end if;
        if pk > 10240 then LEDR(12) <= '1'; end if;
        if pk > 12288 then LEDR(13) <= '1'; end if;
        if pk > 16384 then LEDR(14) <= '1'; end if;
        if pk > 24576 then LEDR(15) <= '1'; end if;
        if pk > 28672 then LEDR(16) <= '1'; end if;
        if pk > 32000 then LEDR(17) <= '1'; end if;
    end process;

     -- ────────────────────────────────────────────────────────────────
    -- VGA Spectrum Analyzer Display
    -- ────────────────────────────────────────────────────────────────
    u_vga_display : entity work.vga_spectrum
        port map (
            clk_50        => CLOCK_50,
            rst_n         => rst_n,
            
            -- Hook directly to the FFT outputs we are already generating
            fft_mag_valid => mag_valid,
            fft_mag_addr  => mag_addr,
            fft_mag_data  => mag_data,
            
            -- Hardware Pins
            vga_clk       => VGA_CLK,
            vga_hs        => VGA_HS,
            vga_vs        => VGA_VS,
            vga_blank_n   => VGA_BLANK_N,
            vga_sync_n    => VGA_SYNC_N,
            vga_r         => VGA_R,
            vga_g         => VGA_G,
            vga_b         => VGA_B
        );
end architecture rtl;