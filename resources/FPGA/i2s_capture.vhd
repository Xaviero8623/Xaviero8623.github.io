-- =============================================================================
-- I2S Capture
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_capture is
    generic ( FFT_SIZE : integer := 256 );
    port (
        clk, rst_n, enable : in std_logic;
        aud_bclk, aud_adclrck, aud_adcdat : in std_logic;
        sample_valid : out std_logic;
        sample_data : out signed(15 downto 0);
        frame_ready : out std_logic;
        frame_addr : in std_logic_vector(7 downto 0);
        frame_data : out signed(15 downto 0)
    );
end entity i2s_capture;

architecture rtl of i2s_capture is
    signal bs, ls, ds : std_logic_vector(2 downto 0);
    signal br, lrck, dat : std_logic;
    type st_t is (IDLE, WAIT_L, SKIP, CAP, DONE);
    signal st : st_t;
    signal sr : std_logic_vector(15 downto 0);
    signal bc : integer range 0 to 31;
    signal lp : std_logic;

    -- Internal signals to bypass the "cannot read out port" rule
    signal int_sample_valid : std_logic;
    signal int_sample_data  : signed(15 downto 0);

    type fbuf_t is array (0 to FFT_SIZE-1) of signed(15 downto 0);
    signal fbuf : fbuf_t := (others => (others => '0'));
    signal scnt : unsigned(7 downto 0);

    function bitrev(x: unsigned(7 downto 0)) return integer is
        variable y: unsigned(7 downto 0);
    begin
        for i in 0 to 7 loop y(i) := x(7-i); end loop;
        return to_integer(y);
    end function;
begin
    br <= '1' when bs(2 downto 1) = "01" else '0';
    lrck <= ls(2);
    dat <= ds(2);

    -- Map internal signals to the actual output ports
    sample_valid <= int_sample_valid;
    sample_data  <= int_sample_data;

    process(clk)
    begin
        if rising_edge(clk) then
            bs <= bs(1 downto 0) & aud_bclk;
            ls <= ls(1 downto 0) & aud_adclrck;
            ds <= ds(1 downto 0) & aud_adcdat;
        end if;
    end process;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            st <= IDLE; sr <= (others => '0'); bc <= 0;
            int_sample_valid <= '0'; int_sample_data <= (others => '0'); lp <= '1';
        elsif rising_edge(clk) then
            int_sample_valid <= '0'; lp <= lrck;
            case st is
                when IDLE => if enable = '1' then st <= WAIT_L; end if;
                when WAIT_L => if lp = '1' and lrck = '0' then st <= SKIP; end if;
                when SKIP => if br = '1' then st <= CAP; bc <= 15; end if;
                when CAP =>
                    if br = '1' then
                        sr <= sr(14 downto 0) & dat;
                        if bc = 0 then st <= DONE; else bc <= bc - 1; end if;
                    end if;
                when DONE =>
                    int_sample_data <= signed(sr);
                    int_sample_valid <= '1';
                    st <= WAIT_L;
            end case;
        end if;
    end process;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            scnt <= (others => '0');
            frame_ready <= '0';
        elsif rising_edge(clk) then
            frame_ready <= '0';
            if int_sample_valid = '1' and enable = '1' then
                fbuf(bitrev(scnt)) <= int_sample_data;
                if scnt = to_unsigned(FFT_SIZE-1, 8) then
                    scnt <= (others => '0');
                    frame_ready <= '1';
                else
                    scnt <= scnt + 1;
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            frame_data <= fbuf(to_integer(unsigned(frame_addr)));
        end if;
    end process;
end architecture rtl;