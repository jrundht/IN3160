library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity self_test_module is
    port(
        mclk        : in std_logic; -- 100MHz clock 
        reset       : in std_logic;
        duty_cycle  : out std_logic_vector(7 downto 0)
    );
end entity;

architecture RTL of self_test_module is
    constant adr_width  : natural := 5;
    constant data_width : natural := 8;

    signal tick         :  std_logic := '0';

    signal ROM_data     : std_logic_vector(data_width-1 downto 0);
    signal adr          : std_logic_vector(4 downto 0) := (others => '0');
    signal next_adr     : unsigned(adr_width-1 downto 0);
begin
    -- ROM-module
    rom1 : entity work.ROM_file  
    generic map(data_width => data_width, addr_width => adr_width)
    port map(address => adr, data => ROM_data);


    process(mclk, reset) is
        variable count : unsigned(29 downto 0);
        begin
            if reset then
                count := (others => '0');
            elsif rising_edge(mclk) then
                count := count + 1;
                if count = X"11e1a300" then -- NUMBER OF 10ns IN 3S -- CHANGE BACK TO THIS: X"11e1a300"
                    tick <= '1';
                    count := (others => '0');
                else
                    tick <= '0'; -- MAKE SURE IT IS ONLY ACTIVE FOR ONE CLOCK CYCLE
                end if;
                adr <= std_logic_vector(next_adr) when tick;
            end if;
    end process;

    -- Next ROM element
    process(all) is
    begin
        -- Stop at end of file
        next_adr <= unsigned(adr) + 1 when unsigned(adr) < (2**adr_width-1) else unsigned(adr);
        duty_cycle <= ROM_data;
    end process;
end RTL;