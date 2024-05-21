library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pulse_stretcher_fsm is
    generic (N : integer := 2);
    port(
        clk : in std_logic;
        reset : in std_logic;

        x : in std_logic;
        z : out std_logic
    );
end entity pulse_stretcher_fsm;


architecture RTL of pulse_stretcher_fsm is
    signal counter, next_counter : integer:= 0;

    type state_type is (s_idle, s_start, s_stretch);
    signal present_state, next_state : state_type;
begin

    process(clk) is 
    begin
        if rising_edge(clk) then
            if reset then 
                present_state <= s_idle;
                counter <= 0;

            else
                present_state <= next_state;
                counter <= next_counter;
            end if;
        end if;
    end process;

    next_state_CL: process(all) is
    begin
        next_state <= present_state;
        case present_state is
            when s_idle =>
                next_state <=
                s_start when x else s_idle;

            when s_start => 
                next_state <=
                s_start when x else s_stretch;

            when s_stretch =>
                next_state <=
                s_start when x else 
                s_stretch when (counter < N-2) else
                s_idle;

            when others =>
                next_state <= s_idle;
        end case;
    end process;

    process(all) is

    begin
        z <= '0';
        case present_state is

            when s_idle =>
                null;

            when s_start =>
                z <= '1';
                

            when s_stretch =>
                z <= '1';
                next_counter <= counter + 1 when counter > 0 else 0;
        end case;
    end process;


end architecture RTL;