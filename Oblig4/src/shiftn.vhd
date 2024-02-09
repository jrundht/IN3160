library ieee;
use ieee.std_logic_1164.all;

entity shiftn is
	generic(width : positive := 32);
	port(
		clk        : in  std_logic;
		reset      : in  std_logic;
		serial_in  : in  std_logic;
		serial_out : out std_logic;		
		b          : out std_logic_vector(width-1 downto 0)
	);
end shiftn;

architecture structural of shiftn is
	component dff 
	port(
		rst_n     : in  std_logic;   -- Reset
		mclk      : in  std_logic;   -- Clock
		din       : in  std_logic;   -- Data in
		dout      : out std_logic    -- Data out
	);
	end component;

	begin
		DFF0 : dff port map(rst_n => reset, mclk => clk, din => serial_in, dout => b(width-1));

        generate_dff: 
        for i in 1 to width-1 generate
			DFFi : dff port map(rst_n => reset, 
							mclk => clk, 
							din => b(width-i), 
							dout => b(width-i-1));
			
        end generate generate_dff;

	serial_out <= b(0);
end architecture structural;

-- architecture structural of shiftn is
-- 	component dff 
-- 	port(
-- 		rst_n     : in  std_logic;   -- Reset
-- 		mclk      : in  std_logic;   -- Clock
-- 		din       : in  std_logic;   -- Data in
-- 		dout      : out std_logic    -- Data out
-- 	);
-- 	end component;

-- 	begin

--         generate_dff: 
--         for i in 1 to width-1 generate
-- 			if1: 
-- 			if i = 1 generate
-- 				DFFi: dff port map(rst_n => reset, mclk => clk, din => serial_in, dout => b(width-i));
-- 				DFFi1: dff port map(rst_n => reset, 
-- 								mclk => clk, 
-- 								din => b(width-i), 
-- 								dout => b(width-i-1));
-- 			end generate if1;
-- 			if2: 
-- 			if i > 1 generate
-- 				DFFi: dff port map(rst_n => reset, 
-- 							mclk => clk, 
-- 							din => b(width-i), 
-- 							dout => b(width-i-1));
-- 			end generate if2;
-- 			end;
--         end generate generate_dff;

-- 	serial_out <= b(0);
-- end architecture structural;