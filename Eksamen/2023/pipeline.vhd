library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pipeline is
    generic (N : integer := 10);
    port(

        clk, reset : in std_logic;
        a, b, c : in std_logic_vector(N-1 downto 0);
        vdata : in std_logic;

        tdata : out std_logic_vector(N-1 downto 0);
        tvalid : out std_logic
    );
end pipeline;

architecture RTL of pipeline is
    signal r_ab : signed(N downto 0);
    signal r_c : signed(N-1 downto 0);
    signal r_vdata : std_logic;
    
    signal next_ab : signed(N downto 0);
    signal next_c : std_logic_vector(N-1 downto 0);
    signal next_tdata : std_logic_vector(2*N downto 0);

begin
    next_ab <= signed(a(N-1) & a) + signed(b(N-1) & b);
    next_c <= signed(c);
    next_tdata <= std_logic_vector(r_ab * r_c) 
        when r_vdata else (others => '0');

    REGISTER_ASSIGNMENT: process(clk) is
    begin
        if rising_edge(clk) then 
            if reset then 
                r_ab <= (others => '0');
                r_c <= (others => '0');
                tdata <= (others => '0');

                r_vdata <= '0';
                tvalid <= '0';
            else
                r_ab <= next_ab;
                r_c <= next_c;
                r_vdata <= vdata;
                t_valid <= r_vdata;

            end if;
        end if;
    end process;
end RTL;