-- =============================================================================
-- FFT Core
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_core is
    generic ( N : integer := 256; STAGES : integer := 8 );
    port (
        clk, rst_n, start : in std_logic;
        done, busy : out std_logic;
        load_addr : out std_logic_vector(7 downto 0);
        load_data : in signed(15 downto 0);
        mag_valid : out std_logic;
        mag_addr : out std_logic_vector(6 downto 0);
        mag_data : out std_logic_vector(15 downto 0)
    );
end entity fft_core;

architecture rtl of fft_core is
    component twiddle_rom is
        port (
            clk : in std_logic; addr : in std_logic_vector(6 downto 0);
            cos_out, sin_out : out signed(15 downto 0)
        );
    end component;

    type ram_t is array (0 to N-1) of signed(31 downto 0);
    signal ram_re, ram_im : ram_t := (others => (others => '0'));

    signal tw_addr : std_logic_vector(6 downto 0);
    signal tw_cos, tw_sin : signed(15 downto 0);

    signal ar, ai, br, bi : signed(31 downto 0);
    signal prr, pri, pir, pii : signed(47 downto 0);
    signal wbr, wbi, oar, oai, obr, obi : signed(31 downto 0);

    type fst_t is (F_IDLE, F_LOAD, F_SINIT, F_RA, F_RB, F_TW, F_CMP, F_WR, F_NXT, F_MAG, F_DONE);
    signal fs : fst_t;

    signal stg : integer range 0 to 15;
    signal blk, bfy, hsz, nblk, itop, ibot : integer range 0 to 255;
    signal bsz, lcnt : integer range 0 to 511;
    signal mcnt : integer range 0 to 127;
begin
    u_tw: twiddle_rom port map(clk, tw_addr, tw_cos, tw_sin);

    prr <= tw_cos * br; pri <= tw_sin * bi;
    pir <= tw_cos * bi; pii <= tw_sin * br;

    wbr <= resize(shift_right(prr - pri, 15), 32);
    wbi <= resize(shift_right(pir + pii, 15), 32);

    oar <= shift_right(ar + wbr, 1); oai <= shift_right(ai + wbi, 1);
    obr <= shift_right(ar - wbr, 1); obi <= shift_right(ai - wbi, 1);

    busy <= '0' when fs = F_IDLE else '1';

    process(clk, rst_n)
        variable are, aim, mx, mn, mg : unsigned(31 downto 0);
        variable rv, iv : signed(31 downto 0);
    begin
        if rst_n = '0' then
            fs <= F_IDLE; done <= '0'; mag_valid <= '0';
            load_addr <= (others => '0'); tw_addr <= (others => '0');
            stg <= 0; blk <= 0; bfy <= 0; lcnt <= 0; mcnt <= 0;
        elsif rising_edge(clk) then
            done <= '0'; mag_valid <= '0';
            case fs is
                when F_IDLE =>
                    if start = '1' then lcnt <= 0; load_addr <= (others => '0'); fs <= F_LOAD; end if;
                when F_LOAD =>
                    if lcnt > 0 then
                        ram_re(lcnt-1) <= resize(load_data, 32);
                        ram_im(lcnt-1) <= (others => '0');
                    end if;
                    if lcnt = N then
                        fs <= F_SINIT; stg <= 0;
                    else
                        load_addr <= std_logic_vector(to_unsigned(lcnt, 8));
                        lcnt <= lcnt + 1;
                    end if;
                when F_SINIT =>
                    hsz <= 1 * (2 ** stg); bsz <= 1 * (2 ** (stg + 1));
                    nblk <= N / (2 ** (stg + 1)); blk <= 0; bfy <= 0; fs <= F_RA;
                when F_RA =>
                    itop <= blk * bsz + bfy; ibot <= blk * bsz + bfy + hsz; fs <= F_RB;
                when F_RB =>
                    ar <= ram_re(itop); ai <= ram_im(itop);
                    br <= ram_re(ibot); bi <= ram_im(ibot);
                    tw_addr <= std_logic_vector(to_unsigned(bfy * (2 ** (STAGES-1-stg)), 7));
                    fs <= F_TW;
                when F_TW => fs <= F_CMP;
                when F_CMP => fs <= F_WR;
                when F_WR =>
                    ram_re(itop) <= oar; ram_im(itop) <= oai;
                    ram_re(ibot) <= obr; ram_im(ibot) <= obi; fs <= F_NXT;
                when F_NXT =>
                    if bfy < hsz - 1 then bfy <= bfy + 1; fs <= F_RA;
                    elsif blk < nblk - 1 then blk <= blk + 1; bfy <= 0; fs <= F_RA;
                    elsif stg < STAGES - 1 then stg <= stg + 1; fs <= F_SINIT;
                    else mcnt <= 0; fs <= F_MAG; end if;
                when F_MAG =>
                    rv := ram_re(mcnt); iv := ram_im(mcnt);
                    are := unsigned(abs(rv)); aim := unsigned(abs(iv));
                    if are > aim then mx := are; mn := aim; else mx := aim; mn := are; end if;
                    mg := mx + shift_right(mn, 2);
                    mag_addr <= std_logic_vector(to_unsigned(mcnt, 7));
                    if mg > x"0000FFFF" then mag_data <= x"FFFF"; else mag_data <= std_logic_vector(mg(15 downto 0)); end if;
                    mag_valid <= '1';
                    if mcnt = 127 then fs <= F_DONE; else mcnt <= mcnt + 1; end if;
                when F_DONE =>
                    done <= '1'; fs <= F_IDLE;
            end case;
        end if;
    end process;
end architecture rtl;