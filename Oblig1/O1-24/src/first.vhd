library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIRST is
  port
    (
      clk       : in  std_logic;        -- Clock signal from push button
      reset     : in  std_logic;        -- Global asynchronous reset
      load      : in  std_logic;        -- Synchronous load signal
      inp       : in  std_logic_vector(3 downto 0);  -- Start value
      count     : out std_logic_vector(3 downto 0);  -- Count value
      max_count : out std_logic;        -- Indicates maximum count value
      min_count : out std_logic;
      up        : out std_logic         
      );
end FIRST;

-- The architecture below describes a 4-bit up counter. When the counter
-- reaches its maximum value, the signal MAX_COUNT is activated.

architecture RTL of FIRST is

  --  Declarative region
  signal next_count : unsigned(3 downto 0);
begin
  --  Statements
  
  -- Combinational logic used for register input 
  next_count <= 
    unsigned(inp) when load = '1' else
    unsigned(count) + 1;
    

  REGISTERS: process (clk) is
  begin
    -- Synchronous reset
    if rising_edge(clk) then
      count <= 
        (others => '0') when reset else 
        std_logic_vector(next_count);
      
    end if;

  end process;

  -- Concurrent signal assignment
   max_count <= '1' when count = "1111" else '0'; 
   min_count <= '1' when count = "0000" else '0';
  process (max_count, min_count)

   begin
   if max_count then 
      up <= '0';
      --max_count <= '0';
   end if;

   if min_count then 
      up <= '1';
      --min_count <= '0';
   end if;
  end process;

end RTL;
