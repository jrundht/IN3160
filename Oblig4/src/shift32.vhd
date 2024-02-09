-- library ieee;
-- use ieee.std_logic_1164.all;

-- entity shift32 is
-- 	port(
-- 		clk        : in  std_logic;
-- 		reset      : in  std_logic;
-- 		serial_in  : in  std_logic;
-- 		serial_out : out std_logic;		
-- 		b          : out std_logic_vector(31 downto 0)
-- 	);
-- end shift32;

-- -- Med fire 8-bit shifters
-- -- architecture structural of shift32 is
-- -- 	component shift8 
-- -- 	port(
-- -- 		clk        : in  std_logic;
-- -- 		reset      : in  std_logic;
-- -- 		serial_in  : in  std_logic;
-- -- 		serial_out : out std_logic;
-- -- 		b 			   : out std_logic_vector(7 downto 0)
-- -- 	);
-- -- 	end component;

-- -- 	signal next_signal : std_logic_vector(3 downto 0);

-- -- 	begin
-- -- 	S81 : shift8 port map(clk => clk, reset => reset, serial_in => serial_in, serial_out => next_signal(3), b => b(31 downto 24));
-- -- 	S82 : shift8 port map(clk => clk, reset => reset, serial_in => next_signal(3), serial_out => next_signal(2), b => b(23 downto 16));
-- -- 	S83 : shift8 port map(clk => clk, reset => reset, serial_in => next_signal(2), serial_out => next_signal(1), b => b(15 downto 8));
-- -- 	S84 : shift8 port map(clk => clk, reset => reset, serial_in => next_signal(1), serial_out => next_signal(0), b => b(7 downto 0));
-- -- 	serial_out <= next_signal(0);
-- -- end architecture structural;

-- -- Med 32 dff generert med for generate
-- architecture structural of shift32 is
-- 	component dff 
-- 	port(
-- 		rst_n     : in  std_logic;   -- Reset
-- 		mclk      : in  std_logic;   -- Clock
-- 		din       : in  std_logic;   -- Data in
-- 		dout      : out std_logic    -- Data out
-- 	);
-- 	end component;

-- 	begin
-- 		DFF0 : dff port map(rst_n => reset, mclk => clk, din => serial_in, dout => b(31));

--         generate_dff: 
--         for i in 1 to 31 generate
--             DFFi: dff port map(rst_n => reset, 
--                            mclk => clk, 
--                            din => b(32-i), 
--                            dout => b(31-i));
--         end generate;

-- 	serial_out <= b(0);
-- end architecture structural;

library ieee;
use ieee.std_logic_1164.all;

entity shift32 is
	generic(width : positive := 32);
	port(
		clk        : in  std_logic;
		reset      : in  std_logic;
		serial_in  : in  std_logic;
		serial_out : out std_logic;		
		b          : out std_logic_vector(width-1 downto 0)
	);
end shift32;

architecture structural of shift32 is
	component dff 
	port(
		rst_n     : in  std_logic;   -- Reset
		mclk      : in  std_logic;   -- Clock
		din       : in  std_logic;   -- Data in
		dout      : out std_logic    -- Data out
	);
	end component;

	begin
		DFF0 : dff port map(rst_n => reset, mclk => clk, din => serial_in, dout => b(31));

        generate_dff: 
        for i in 1 to width-1 generate
            DFFi: dff port map(rst_n => reset, 
                           mclk => clk, 
                           din => b(width-i), 
                           dout => b(width-i-1));
        end generate;

	serial_out <= b(0);
end architecture structural;