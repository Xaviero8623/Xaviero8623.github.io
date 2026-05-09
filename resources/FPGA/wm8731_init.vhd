-- =============================================================================
-- WM8731 Init
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wm8731_init is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        config_done : out std_logic;
        i2c_sclk    : out std_logic;
        i2c_sdat    : inout std_logic
    );
end entity wm8731_init;

architecture rtl of wm8731_init is
    signal i2c_start, i2c_done, i2c_busy : std_logic;
    signal i2c_data : std_logic_vector(15 downto 0);

    type tbl_t is array (0 to 10) of std_logic_vector(15 downto 0);
    constant tbl : tbl_t := (
        x"1E00", x"0017", x"0217", x"0479", x"0679", x"0815",
        x"0A00", x"0C00", x"0E42", x"1000", x"1201"
    );

    type st_t is (W, S, D, NX, FIN);
    signal st : st_t;
    signal idx : integer range 0 to 15;
    signal dly : unsigned(19 downto 0);
begin
    u_i2c: entity work.i2c_master port map (
        clk => clk, rst_n => rst_n, start => i2c_start,
        slave_addr => "0011010", data => i2c_data,
        done => i2c_done, busy => i2c_busy,
        i2c_sclk => i2c_sclk, i2c_sdat => i2c_sdat
    );

    config_done <= '1' when st = FIN else '0';

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            st <= W; idx <= 0; dly <= (others => '0');
            i2c_start <= '0'; i2c_data <= (others => '0');
        elsif rising_edge(clk) then
            i2c_start <= '0';
            case st is
                when W =>
                    dly <= dly + 1;
                    if dly >= to_unsigned(1000000, 20) then st <= S; end if;
                when S =>
                    if i2c_busy = '0' then
                        i2c_data <= tbl(idx); i2c_start <= '1'; st <= D;
                    end if;
                when D =>
                    if i2c_done = '1' then
                        st <= NX; dly <= (others => '0');
                    end if;
                when NX =>
                    dly <= dly + 1;
                    if dly >= to_unsigned(10000, 20) then
                        if idx < 10 then idx <= idx + 1; st <= S;
                        else st <= FIN; end if;
                    end if;
                when FIN => null;
            end case;
        end if;
    end process;
end architecture rtl;