library ieee;
use ieee.std_logic_1164.all;

architecture RTL of decoder_ent is begin
    process(all) begin
        case a is 
        when "00" => b <= "0001";
        when "01" => b <= "0010";
        when "10" => b <= "0100";
        when others => b <= "1000";
        end case;
    end process;
end RTL;
