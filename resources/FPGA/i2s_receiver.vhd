library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2s_receiver is
    Port (
        clk          : in  std_logic;
        rst_n        : in  std_logic;
        aud_bclk     : in  std_logic;
        aud_adclrck  : in  std_logic;
        aud_adcdat   : in  std_logic;
        left_data    : out std_logic_vector(15 downto 0);
        right_data   : out std_logic_vector(15 downto 0);
        data_valid   : out std_logic
    );
end i2s_receiver;

architecture Behavioral of i2s_receiver is

    -- 2-stage synchronizers (prevent metastability)
    signal bclk_s1, bclk_s2, bclk_s3    : std_logic := '0';
    signal lrclk_s1, lrclk_s2, lrclk_s3 : std_logic := '0';
    signal dat_s1, dat_s2                : std_logic := '0';

    -- Edge detection
    signal bclk_rise  : std_logic;
    signal bclk_fall  : std_logic;
    signal lrclk_prev : std_logic := '0';

    -- Shift register
    signal shift_reg  : std_logic_vector(15 downto 0) := (others => '0');
    signal bit_count  : integer range 0 to 15 := 0;

    -- Output registers
    signal left_reg   : std_logic_vector(15 downto 0) := (others => '0');
    signal right_reg  : std_logic_vector(15 downto 0) := (others => '0');

    -- Debug: count how many BCLKs we see
    signal bclk_seen  : std_logic := '0';

begin

    -- Rising and falling edge detection on synchronized BCLK
    bclk_rise <= '1' when bclk_s2 = '1' and bclk_s3 = '0' else '0';
    bclk_fall <= '1' when bclk_s2 = '0' and bclk_s3 = '1' else '0';

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            bclk_s1   <= '0'; bclk_s2  <= '0'; bclk_s3  <= '0';
            lrclk_s1  <= '0'; lrclk_s2 <= '0'; lrclk_s3 <= '0';
            dat_s1    <= '0'; dat_s2   <= '0';
            lrclk_prev <= '0';
            shift_reg  <= (others => '0');
            bit_count  <= 0;
            left_reg   <= (others => '0');
            right_reg  <= (others => '0');
            left_data  <= (others => '0');
            right_data <= (others => '0');
            data_valid <= '0';
            bclk_seen  <= '0';

        elsif rising_edge(clk) then
            data_valid <= '0';

            -- Stage 1 & 2: synchronize async inputs to system clock
            bclk_s1  <= aud_bclk;    bclk_s2  <= bclk_s1;  bclk_s3  <= bclk_s2;
            lrclk_s1 <= aud_adclrck; lrclk_s2 <= lrclk_s1; lrclk_s3 <= lrclk_s2;
            dat_s1   <= aud_adcdat;  dat_s2   <= dat_s1;

            -- Track previous LRCLK state
            if bclk_rise = '1' then
                lrclk_prev <= lrclk_s2;
            end if;

            -- Sample data on rising BCLK edge (I2S: data valid on rising edge)
            if bclk_rise = '1' then
                bclk_seen <= '1';  -- proves BCLK is arriving

                -- Shift in one bit, MSB first
                shift_reg <= shift_reg(14 downto 0) & dat_s2;

                if bit_count = 15 then
                    bit_count <= 0;
                    -- Store completed word based on which channel we were in
                    if lrclk_prev = '0' then
                        left_reg <= shift_reg(14 downto 0) & dat_s2;
                    else
                        right_reg  <= shift_reg(14 downto 0) & dat_s2;
                        left_data  <= left_reg;
                        right_data <= shift_reg(14 downto 0) & dat_s2;
                        data_valid <= '1';
                    end if;
                else
                    bit_count <= bit_count + 1;
                end if;
            end if;

        end if;
    end process;

end Behavioral;