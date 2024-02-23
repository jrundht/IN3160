library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity self_test is
port(
    mclk        : in std_logic; -- 100MHz clock 
    reset       : in std_logic; 
    abcdefg     : out std_logic_vector(6 downto 0); 
    second_tick, c : out std_logic
    
);
end entity;

architecture RTL of self_test is
    signal tick : std_logic;
    signal d0_seg7, d1_seg7 : std_logic_vector(3 downto 0);
    signal ROM_data : std_logic_vector(7 downto 0);
    signal adr : std_logic_vector(3 downto 0) := (others => '0');
    signal next_adr : unsigned(3 downto 0);

    begin
        second_tick <= tick;
        
        -- ROM
        rom1 : entity work.ROM  
        generic map(data_width => 8, addr_width => 4)
        port map(address => adr, data => ROM_data);

        --SEG7CTRL
        s7c: entity work.seg7ctrl_ent 
        port map(mclk => mclk, 
                    reset => reset,     
                    d0 => d0_seg7, 
                    d1 => d1_seg7,
                    abcdefg => abcdefg,
                    c => c
        );

    process(mclk, reset) is
        variable count : unsigned(29 downto 0);
        begin
            if reset then
                count := (others => '0');
            elsif rising_edge(mclk) then
                count := count + 1;
                
                if count = X"05" then -- NUMBER OF ns IN 1S -- CHANGE BACK TO THIS: X"3B9ACA00"
                    tick <= '1';
                    count := (others => '0');
                else
                    tick <= '0'; -- MAKE SURE IT IS ONLY ACTIVE FOR ONE CLOCK CYCLE
                end if;

                adr <= std_logic_vector(next_adr) when second_tick;
            end if;
    end process;

    process(all) is
    begin
        next_adr <= unsigned(adr) + 1;
        d1_seg7 <= ROM_data(7 downto 4);
        d0_seg7 <= ROM_data(3 downto 0);
    end process;

end RTL;