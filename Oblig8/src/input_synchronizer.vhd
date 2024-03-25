library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_synchronizer is
    port(
      mclk     : in std_logic;
      reset    : in std_logic;

      sa       : in std_logic;
      sb       : in std_logic;

      sa_synch : out std_logic := '0';
      sb_synch : out std_logic := '0'
    );
end entity;

architecture behavioral of input_synchronizer is
  signal sa_mid, sb_mid : std_logic := '0'; -- Middle value
  begin
    -- 2FF
    process(mclk) is
      begin
        if rising_edge(mclk) then 
          if reset then 
            sa_mid <= '0';
            sa_synch <= '0';
          
            sb_mid <= '0';
            sb_synch <= '0';

          else
            sa_mid <= sa;
            sa_synch <= sa_mid;
          
            sb_mid <= sb;
            sb_synch <= sb_mid;
          end if;
        end if;
    end process;
  end behavioral;
