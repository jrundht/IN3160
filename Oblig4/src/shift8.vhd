library ieee;
use ieee.std_logic_1164.all;

entity shift8 is
	port(
		clk        : in  std_logic;
		reset      : in  std_logic;
		serial_in  : in  std_logic;
		serial_out : out std_logic;
		b 			  : out std_logic_vector(7 downto 0)
	);
end shift8;
	
architecture structural of shift8 is

	component dff 
	port(
		rst_n : in  std_logic;
		mclk  : in  std_logic;
		din   : in  std_logic;
		dout  : out std_logic
		);
	end component;
		

	begin
	DFF1 : dff port map(rst_n => reset, mclk => clk, din => serial_in, dout => b(7));
	DFF2 : dff port map(rst_n => reset, mclk => clk, din => b(7)     , dout => b(6));
	DFF3 : dff port map(rst_n => reset, mclk => clk, din => b(6)     , dout => b(5));
	DFF4 : dff port map(rst_n => reset, mclk => clk, din => b(5)     , dout => b(4));
	DFF5 : dff port map(rst_n => reset, mclk => clk, din => b(4)     , dout => b(3));
	DFF6 : dff port map(rst_n => reset, mclk => clk, din => b(3)     , dout => b(2));
	DFF7 : dff port map(rst_n => reset, mclk => clk, din => b(2)     , dout => b(1));
	DFF8 : dff port map(rst_n => reset, mclk => clk, din => b(1)     , dout => b(0));
	serial_out <= b(0);
end architecture structural;
