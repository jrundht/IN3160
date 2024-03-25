library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- NEEDED WHEN FUNCTIONS ARE PLACED IN PACKAGE
library work;
use work.seg7_pkg.all;

entity seg7ctrl is 
  port 
  ( 
    mclk      : in std_logic; --100MHz, positive flank 
    reset     : in std_logic; --Asynchronous reset, active high 
    d0        : in std_logic_vector(3 downto 0); 
    d1        : in std_logic_vector(3 downto 0); 
    abcdefg   : out std_logic_vector(6 downto 0); 
    c         : out std_logic 
  ); 
end entity seg7ctrl;


architecture RTL of seg7ctrl is
  signal c_default : std_logic;
begin
  c <= c_default;

  process(mclk, reset) is 
      variable count : unsigned(19 downto 0); --VARIABLE THAT COUNTS UP TO 100Hz
  begin
      if reset  = '1' then 
          count := (others => '0'); -- RESET ASYNCHRONOUSLY
          c_default <= '0';
      elsif rising_edge(mclk) then
          count := count + 1;

          if count = X"0002" then -- WHEN COUNTED TO THIS, FLIP C -- X"F4240" -- HUSK Å SETTE VERDI TILBAKE!!
              c_default <= not c_default; 
              count := (others => '0'); 
          end if;
      end if;

  end process;

  abcdefg <= bin2ssd_v2(d1) when c_default else bin2ssd_v2(d0);
end RTL;

