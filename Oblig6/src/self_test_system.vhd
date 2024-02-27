library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity self_test_system is
    port(
        mclk    : in std_logic;
        reset   : in std_logic;
        abcdefg : out std_logic_vector(6 downto 0); 
        c       : out std_logic
    );
end entity;

architecture RTL of self_test_system is
    signal d0_system, d1_system : std_logic_vector(3 downto 0); 


    begin
        --SELF_TEST
        st: entity work.self_test 
        port map( mclk => mclk,
                    reset => reset,
                    d0 => d0_system,
                    d1 => d1_system
        );

        --SEG7CTRL
        s7c: entity work.seg7ctrl_ent 
        port map(mclk => mclk, 
                    reset => reset,     
                    d0 => d0_system, 
                    d1 => d1_system,
                    abcdefg => abcdefg,
                    c => c
        );

end RTL;

