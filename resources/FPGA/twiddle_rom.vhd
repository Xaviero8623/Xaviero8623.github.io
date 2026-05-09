-- =============================================================================
-- Twiddle Factor ROM for FFT
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity twiddle_rom is
    port (
        clk     : in  std_logic;
        addr    : in  std_logic_vector(6 downto 0);
        cos_out : out signed(15 downto 0);
        sin_out : out signed(15 downto 0)
    );
end entity twiddle_rom;

architecture rtl of twiddle_rom is
    type rom_array is array(0 to 127) of std_logic_vector(31 downto 0);
    constant rom : rom_array := (
        x"7FFF0000", x"7FF5FCDC", x"7FD8F9B8", x"7FA6F696", x"7F61F374", x"7F09F055", x"7E9CED38", x"7E1DEA1E",
        x"7D89E707", x"7CE3E3F5", x"7C29E0E6", x"7B5CDDDD", x"7A7CDAD8", x"7989D7DA", x"7884D4E1", x"776BD1EF",
        x"7641CF05", x"7504CC21", x"73B5C946", x"7254C674", x"70E2C3AA", x"6F5EC0E9", x"6DC9BE32", x"6C23BB86",
        x"6A6DB8E4", x"68A6B64C", x"66CFB3C1", x"64E8B141", x"62F1AECD", x"60EBAC65", x"5ED7AA0B", x"5CB3A7BE",
        x"5A82A57E", x"5842A34D", x"55F5A129", x"539B9F15", x"51339D0F", x"4EBF9B18", x"4C3F9931", x"49B4975A",
        x"471C9593", x"447A93DD", x"41CE9237", x"3F1790A2", x"3C568F1E", x"398C8DAC", x"36BA8C4B", x"33DF8AFC",
        x"30FB89BF", x"2E118895", x"2B1F877C", x"28268677", x"25288584", x"222384A4", x"1F1A83D7", x"1C0B831D",
        x"18F98277", x"15E281E3", x"12C88164", x"0FAB80F7", x"0C8C809F", x"096A805A", x"06488028", x"0324800B",
        x"00008001", x"FCDC800B", x"F9B88028", x"F696805A", x"F374809F", x"F05580F7", x"ED388164", x"EA1E81E3",
        x"E7078277", x"E3F5831D", x"E0E683D7", x"DDDD84A4", x"DAD88584", x"D7DA8677", x"D4E1877C", x"D1EF8895",
        x"CF0589BF", x"CC218AFC", x"C9468C4B", x"C6748DAC", x"C3AA8F1E", x"C0E990A2", x"BE329237", x"BB8693DD",
        x"B8E49593", x"B64C975A", x"B3C19931", x"B1419B18", x"AECD9D0F", x"AC659F15", x"AA0BA129", x"A7BEA34D",
        x"A57EA57E", x"A34DA7BE", x"A129AA0B", x"9F15AC65", x"9D0FAECD", x"9B18B141", x"9931B3C1", x"975AB64C",
        x"9593B8E4", x"93DDBB86", x"9237BE32", x"90A2C0E9", x"8F1EC3AA", x"8DACC674", x"8C4BC946", x"8AFCCC21",
        x"89BFCF05", x"8895D1EF", x"877CD4E1", x"8677D7DA", x"8584DAD8", x"84A4DDDD", x"83D7E0E6", x"831DE3F5",
        x"8277E707", x"81E3EA1E", x"8164ED38", x"80F7F055", x"809FF374", x"805AF696", x"8028F9B8", x"800BFCDC"
    );
    signal data : std_logic_vector(31 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            data <= rom(to_integer(unsigned(addr)));
        end if;
    end process;
    
    cos_out <= signed(data(31 downto 16));
    sin_out <= signed(data(15 downto 0));
end architecture rtl;