library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity output_synchronizer is
    port(
      mclk      : in std_logic;
      reset     : in std_logic;

      dir       : in std_logic;
      en        : in std_logic;

      dir_synch : out std_logic; 
      en_synch  : out std_logic
);
end entity;

architecture behavioral of output_synchronizer is
begin
  process(mclk) is
    begin
      if rising_edge(mclk) then
        if reset then 
          dir_synch <= '0';
          en_synch <= '0';
        else

          dir_synch <= dir;
          en_synch  <= en;
        end if;
      end if;
  end process;
end behavioral;