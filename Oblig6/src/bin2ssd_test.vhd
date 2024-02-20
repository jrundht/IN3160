library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- NEEDED WHEN FUNCTIONS ARE PLACED IN PACKAGE
library work;
use work.seg7_pkg.all;

entity bin2ssd_test is 
  port 
  ( 
    di        : in std_logic_vector(3 downto 0); 
    abcdefg   : out std_logic_vector(6 downto 0)
  ); 
end entity bin2ssd_test;

architecture rtl of bin2ssd_test is
  signal ssd : std_logic_vector(6 downto 0);
begin
    process(di) is
    begin
        ssd <= bin2ssd(di);
    end process;
  abcdefg <= ssd;
end rtl;