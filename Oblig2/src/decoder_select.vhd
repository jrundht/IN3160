library ieee;
use ieee.std_logic_1164.all;

architecture RTL of decoder_ent is 
begin
    with a select b <=
        "1110" when "00", --14--
        "1101" when "01", --13--
        "1011" when "10", --11--
        "0001" when "11", --1--
        "0000" when others;
end architecture RTL;
