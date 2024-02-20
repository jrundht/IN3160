library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- PACKAGE DECLARATION
package seg7_pkg is
    function bin2ssd(bin : std_logic_vector) return std_logic_vector;

    function bin2ssd_v2(bin : std_logic_vector) return std_logic_vector;


end package seg7_pkg;

-- PACKAGE BODY SECTION
package body seg7_pkg is

    -- CONVERT 4-BIT BINARY INPUT TO SEVEN SEGMENT CODE
    function bin2ssd(bin : std_logic_vector) return std_logic_vector is
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

    function bin2ssd_v2(bin : std_logic_vector) return std_logic_vector is
        variable ssd : std_logic_vector(6 downto 0);
    begin
        case bin is
            when "0000" => ssd := "0000000"; --0
            when "0001" => ssd := "0011110"; --1
            when "0010" => ssd := "0111100"; --2
            when "0011" => ssd := "1001111"; --3
            when "0100" => ssd := "0001110"; --4
            when "0101" => ssd := "0111101"; --5
            when "0110" => ssd := "0011101"; --6
            when "0111" => ssd := "0010101"; --7
            when "1000" => ssd := "0111011"; --8
            when "1001" => ssd := "0111110"; --9
            when "1010" => ssd := "1110111"; --A
            when "1011" => ssd := "0000101"; --B
            when "1100" => ssd := "1111011"; --C
            when "1101" => ssd := "0011100"; --D
            when "1110" => ssd := "0001101"; --E
            when "1111" => ssd := "1111111"; --F
            when others => ssd := "0000000";
        end case;
    
        return ssd;
    end bin2ssd_v2;

    -- function bin2ssd(bin : std_logic_vector) return std_logic_vector is
    --     variable ssd : std_logic_vector(6 downto 0);
    -- begin
    --     with bin select ssd :=
    --         "1111110" when "0000", --0--
    --         "0110000" when "0001", --1--
    --         "1101101" when "0010", --2--
    --         "1111001" when "0011", --3--
    --         "0110011" when "0100", --4--
    --         "1011011" when "0101", --5--
    --         "1011111" when "0110", --6--
    --         "1110000" when "0111", --7--
    --         "1111111" when "1000", --8--
    --         "1111011" when "1001", --9--
    --         "1110111" when "1010", --A--
    --         "0011111" when "1011", --B--
    --         "1001110" when "1100", --C--
    --         "0111101" when "1101", --D--
    --         "1001111" when "1110", --E--
    --         "1000111" when "1111", --F--
    --         "0000000" when others;

    --     return ssd;
    -- end bin2ssd;

end package body seg7_pkg;