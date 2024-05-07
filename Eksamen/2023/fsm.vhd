library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fsm is
    port(
        clk, rstn : in std_logic;
        sdata : in std_logic;

        tdata : out std_logic_vector(7 downto 0);
        tvalid : out std_logic
    );
end fsm;

architecture rtl of fsm is
    signal cnt, next_cnt : unsigned(3 downto 0);
    signal data, next_data : std_logic_vector(7 downto 0);


    type state_type is (s_idle, s_wait, s_valid);
    signal present_state, next_state : state_type;
begin

    next_data <= data(6 downto 0) & sdata;

    REGISTER_ASSIGNMENT: process(clk) is
    begin
        if rising_edge(clk) then 
            if rstn then 
                present_state <= next_state;
                data <= next_data;
                cnt <= next_cnt;
            else -- reset på lavt signal
                present_state <= s_idle;
                cnt <= (others => '0');
                data <= (others => '0');
            end if;
        end if;

    end process;

    NEXT_STATE_CL: process(all) is

    begin

        case present_state is
            when s_idle =>
                next_state <= s_wait when 
                data = x"AA" 
                else s_idle;
                
            when s_wait => 
                next_state <= s_idle when cnt = 6 and data(6 downto 0) & sdata = x"FF" else 
                s_valid when cnt = 6 else
                s_wait;
            
            when s_valid =>
                next_state <= s_wait;
            
                
            when others =>
                next_state <= s_idle;
        end case;
    end process;

    OUTPUT_CL: process(all) is

    begin
        next_cnt <= (others => '0');
        tvalid <= '0';
        tdata <= (others => '0');

        case present_state is
            when s_idle =>
                null;
            when s_wait => 
                next_cnt <= cnt + 1;

            when s_valid =>
                tvalid <= '1';
                tdata <= data;

            when others =>
                null;
        end case;
    end process;
    
end rtl;