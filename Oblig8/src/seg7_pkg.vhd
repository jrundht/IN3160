library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- PACKAGE DECLARATION
package seg7_pkg is
    function bin2ssd(bin : std_logic_vector(3 downto 0)) return std_logic_vector;
end package seg7_pkg;

-- PACKAGE BODY SECTION
package body seg7_pkg is

    -- CONVERT 4-BIT BINARY INPUT TO SEVEN SEGMENT CODE
    function bin2ssd(bin : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable ssd : std_logic_vector(6 downto 0);
    begin
        case bin is
            when "0000" => ssd := "1111110"; --0
            when "0001" => ssd := "0110000"; --1
            when "0010" => ssd := "1101101"; --2
            when "0011" => ssd := "1111001"; --3
            when "0100" => ssd := "0110011"; --4
            when "0101" => ssd := "1011011"; --5
            when "0110" => ssd := "1011111"; --6
            when "0111" => ssd := "1110000"; --7
            when "1000" => ssd := "1111111"; --8
            when "1001" => ssd := "1111011"; --9
            when "1010" => ssd := "1110111"; --A
            when "1011" => ssd := "0011111"; --B
            when "1100" => ssd := "1001110"; --C
            when "1101" => ssd := "0111101"; --D
            when "1110" => ssd := "1001111"; --E
            when "1111" => ssd := "1000111"; --F
            when others => ssd := "0000000";
        end case;
    
        return ssd;
    end bin2ssd;

end package body seg7_pkg;