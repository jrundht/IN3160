library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity compute_seq is 
port(
    clk, reset   : in std_logic;
    
    a     : in std_logic_vector(15 downto 0) := (others => '0');    
    b     : in std_logic_vector(15 downto 0) := (others => '0');    
    c     : in std_logic_vector(15 downto 0) := (others => '0');    
    d     : in std_logic_vector(15 downto 0) := (others => '0');
    result : out std_logic_vector(17 downto 0) := (others => '0')
);
end entity compute_seq;

architecture RTL of compute_seq is

begin
    process(clk) is
        variable ab   : unsigned(16 downto 0); 
        variable abc  : unsigned(17 downto 0); 
        variable abcd : unsigned(17 downto 0);
        variable next_result : unsigned(17 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then 


            ab   := unsigned('0' & a) + unsigned('0' & b);
            abc  := ab + unsigned("00" & c);
            abcd := abc + unsigned("00" & d);
            result <= (others => '0') when reset else std_logic_vector(abcd);

            --LØSN
            -- next_result := (unsigned("00" & a) + unsigned("00" & b) +
            --             unsigned("00" & c) + unsigned("00" & d));
            -- result <= std_logic_vector(next_result);

        end if;
    end process;

end architecture RTL;
