library ieee;
use ieee.std_logic_1164.all;

entity decoder_ent is 
  port(
    a : in std_logic_vector(1 downto 0);
    b : out std_logic_vector(3 downto 0)
  );
end decoder_ent;