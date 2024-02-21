library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity self_test is
port(
    mclk        : in std_logic; -- 100MHz clock 
    reset       : in std_logic; 
    d0          : in std_logic_vector(3 downto 0); 
    d1          : in std_logic_vector(3 downto 0); 
    abcdefg     : out std_logic_vector(6 downto 0); 
    second_tick, c : out std_logic
    
);
end entity;

architecture RTL of self_test is
    signal tick : std_logic;
    component seg7ctrl_ent 
    port(
        mclk      : in std_logic; --100MHz, positive flank 
        reset     : in std_logic; --Asynchronous reset, active high 
        d0        : in std_logic_vector(3 downto 0); 
        d1        : in std_logic_vector(3 downto 0); 
        abcdefg   : out std_logic_vector(6 downto 0); 
        c         : out std_logic 
    );
    end component;

    
    begin
    second_tick <= tick;

    process(mclk, reset) is
        variable count : std_logic_vector(29 downto 0);
        begin
            if reset then
                count := (others => '0');
            elsif rising_edge(mclk) then
                count := count + 1;
                tick <= '0'; -- MAKE SURE IT IS ONLY ACTIVE FOR ONE CLOCK CYCLE

                if count = X"3B9ACA00" then -- NUMBER OF NS IN 1S
                    tick <= '1';
                    count := (others => '0');
                end if;
            end if;
    end process;

    process(second_tick) is
        if second_tick then
            s7c: seg7ctrl_ent port map(mclk => mclk, 
                                reset => reset,     
                                d0 => d0, 
                                d1 => d1
                                abcdefg => abcdefg
                                c => c);
        end if;
    end process;

    -- NYTT PORTMAP FOR ROM? ?????

end RTL;