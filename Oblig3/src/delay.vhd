-- For oppgave a)

library ieee;
use ieee.std_logic_1164.all;

entity delay is 
  port (
    -- System Clock and Reset
    rst_n        : in  std_logic;
    mclk         : in  std_logic;
    indata       : in  std_logic_vector(7 downto 0);
    outdata      : out std_logic_vector(7 downto 0)
  );  
end delay;

architecture rtl of delay is 
  signal a, b, c : std_logic_vector(7 downto 0);
  signal v1, v2 : std_logic_vector(7 downto 0);
begin  
  process (rst_n, mclk) is    
  --variable v1, v2 : std_logic_vector(7 downto 0);
  begin
    if (rst_n = '0') then       
      a <= (others => '0');
      --v1 := (others => '0');
      v1 <= (others => '0');
      b <= (others => '0');
      --v2 := (others => '0');
      v2 <= (others => '0');
      c <= (others => '0');
    elsif rising_edge(mclk) then
      a  <= indata;
      v1 <= A;
      b  <= v1;
      v2 <= B;
      c  <= v2;
    end if;
  end process;
  outdata  <= c;
end rtl;
