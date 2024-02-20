library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg7ctrl_ent is 
  port 
  ( 
    mclk      : in std_logic; --100MHz, positive flank 
    reset     : in std_logic; --Asynchronous reset, active high 
    d0        : in std_logic_vector(3 downto 0); 
    d1        : in std_logic_vector(3 downto 0); 
    abcdefg   : out std_logic_vector(6 downto 0); 
    c         : out std_logic 
  ); 
end entity seg7ctrl_ent;

