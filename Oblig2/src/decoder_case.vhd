library ieee;
use ieee.std_logic_1164.all;

architecture RTL of decoder_ent is 
begin
    process(a) begin
        case a is 
        when "00" => b <= "1110"; --14--
        when "01" => b <= "1101"; --13--
        when "10" => b <= "1011"; --11--
        when "11" => b <= "0111"; --7--
        when others => b <= "0000";
        end case;
    end process;
end architecture RTL;
