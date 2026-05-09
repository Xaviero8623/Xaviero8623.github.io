-- =============================================================================
-- I2C Master 
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_master is
    port (
        clk        : in  std_logic;
        rst_n      : in  std_logic;
        start      : in  std_logic;
        slave_addr : in  std_logic_vector(6 downto 0);
        data       : in  std_logic_vector(15 downto 0);
        done       : out std_logic;
        busy       : out std_logic;
        i2c_sclk   : out std_logic;
        i2c_sdat   : inout std_logic
    );
end entity i2c_master;

architecture rtl of i2c_master is
    constant CLK_DIV : integer := 200;
    constant HALF    : integer := 100;
    constant QUARTER : integer := 50;

    type state_t is (S_IDLE, S_START, S_BYTE0, S_ACK0, S_BYTE1, S_ACK1, S_BYTE2, S_ACK2, S_STOP, S_DONE);
    signal state : state_t;

    signal sda_out, sda_oe : std_logic;
    signal shift_reg : std_logic_vector(7 downto 0);
    signal phase_cnt : integer range 0 to 255;
    signal bit_cnt   : integer range 0 to 7;
    signal tx_data   : std_logic_vector(23 downto 0);
begin
    i2c_sdat <= sda_out when sda_oe = '1' else 'Z';
    busy <= '0' when state = S_IDLE else '1';

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= S_IDLE;
            i2c_sclk <= '1'; sda_out <= '1'; sda_oe <= '1';
            done <= '0'; phase_cnt <= 0; bit_cnt <= 0;
        elsif rising_edge(clk) then
            done <= '0';
            case state is
                when S_IDLE =>
                    i2c_sclk <= '1'; sda_out <= '1'; sda_oe <= '1';
                    if start = '1' then
                        tx_data <= slave_addr & "0" & data;
                        phase_cnt <= 0; state <= S_START;
                    end if;

                when S_START =>
                    phase_cnt <= phase_cnt + 1;
                    if phase_cnt < HALF then
                        i2c_sclk <= '1'; sda_out <= '1';
                    elsif phase_cnt < CLK_DIV then
                        sda_out <= '0';
                    else
                        i2c_sclk <= '0'; phase_cnt <= 0;
                        bit_cnt <= 7; shift_reg <= tx_data(23 downto 16);
                        state <= S_BYTE0;
                    end if;

                when S_BYTE0 | S_BYTE1 | S_BYTE2 =>
                    phase_cnt <= phase_cnt + 1; sda_oe <= '1';
                    if phase_cnt = 0 then sda_out <= shift_reg(7);
                    elsif phase_cnt = QUARTER then i2c_sclk <= '1';
                    elsif phase_cnt = QUARTER + HALF then i2c_sclk <= '0';
                    elsif phase_cnt >= CLK_DIV - 1 then
                        phase_cnt <= 0; shift_reg <= shift_reg(6 downto 0) & '0';
                        if bit_cnt = 0 then
                            if state = S_BYTE0 then state <= S_ACK0;
                            elsif state = S_BYTE1 then state <= S_ACK1;
                            else state <= S_ACK2; end if;
                        else bit_cnt <= bit_cnt - 1; end if;
                    end if;

                when S_ACK0 | S_ACK1 | S_ACK2 =>
                    phase_cnt <= phase_cnt + 1;
                    if phase_cnt = 0 then sda_oe <= '0';
                    elsif phase_cnt = QUARTER then i2c_sclk <= '1';
                    elsif phase_cnt = QUARTER + HALF then i2c_sclk <= '0';
                    elsif phase_cnt >= CLK_DIV - 1 then
                        phase_cnt <= 0; sda_oe <= '1'; bit_cnt <= 7;
                        if state = S_ACK0 then
                            shift_reg <= tx_data(15 downto 8); state <= S_BYTE1;
                        elsif state = S_ACK1 then
                            shift_reg <= tx_data(7 downto 0); state <= S_BYTE2;
                        else
                            sda_out <= '0'; state <= S_STOP;
                        end if;
                    end if;

                when S_STOP =>
                    phase_cnt <= phase_cnt + 1; sda_oe <= '1';
                    if phase_cnt = 0 then sda_out <= '0'; i2c_sclk <= '0';
                    elsif phase_cnt = QUARTER then i2c_sclk <= '1';
                    elsif phase_cnt = QUARTER + HALF then sda_out <= '1';
                    elsif phase_cnt >= CLK_DIV - 1 then state <= S_DONE; end if;

                when S_DONE =>
                    done <= '1'; state <= S_IDLE;
                when others => state <= S_IDLE;
            end case;
        end if;
    end process;
end architecture rtl;