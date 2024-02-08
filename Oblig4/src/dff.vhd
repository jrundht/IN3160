
library ieee;
use ieee.std_logic_1164.all;

entity dff is 
  port ( 
    -- System Clock and Reset
    rst_n     : in  std_logic;   -- Reset
    mclk      : in  std_logic;   -- Clock
    -- Shifted data in and out
    din       : in  std_logic;   -- Data in
    dout      : out std_logic    -- Data out
  );      
end dff;


architecture rtl of dff is 
  signal next_d : std_logic;
begin
  -- Combinational logic selects input
  next_d <= '0' when rst_n = '0' else din;
  
  -- register update
  dout <= next_d when rising_edge(mclk);
end architecture rtl;


-- code below is for demonstration purposes only

-- architecture VHDL2002_async of dff is 
-- begin
--   P_DFF : process(rst_n, mclk)
--   begin
--     if rst_n='0' then
--       dout <= '0';
--     elsif rising_edge(mclk) then
--       dout <= din;
--     end if;
--   end process P_DFF;  
-- end architecture VHDL2002_async;

-- architecture async_reset of dff is 
-- begin
--   dout <= 
--     '0' when not reset_n else 
--     din when rising_edge(clk);
-- end architecture async_reset;
