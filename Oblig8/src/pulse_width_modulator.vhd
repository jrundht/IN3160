library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_width_modulator is
  port(
      mclk       : in std_logic;
      reset      : in std_logic;
      duty_cycle : in std_logic_vector(7 downto 0);

      en         : out std_logic;
      dir        : out std_logic
);
end entity;
architecture RTL of pulse_width_modulator is
    signal counter : std_logic_vector(13 downto 0) := (others => '0');
    alias msb_counter : std_logic_vector(6 downto 0) is counter(13 downto 7);
    signal PWM : std_logic := '0';

    type state_type is (reverse, reverse_idle, forward, forward_idle);
    signal present_state, next_state : state_type;

begin

    REGISTER_ASSIGNMENT: process(mclk) is
    begin
        if rising_edge(mclk) then
          present_state <= reverse_idle when reset else next_state;
          counter <= (others => '0') when reset else std_logic_vector(unsigned(counter) + 1);

          PWM <= '1' when unsigned(msb_counter) < unsigned(abs(signed(duty_cycle))) else '0';
        end if;
    end process;

    NEXT_STATE_CL: process(all) is
    begin
      next_state <= present_state;
      case present_state is 
        when reverse_idle =>
          next_state <= 
          reverse when signed(duty_cycle) < 0
          else forward_idle;

        when reverse => 
          next_state <=
          reverse when signed(duty_cycle) < 0
          else reverse_idle;

        when forward_idle =>
          next_state <= 
          forward when signed(duty_cycle) > 0
          else reverse_idle;

        when forward =>
          next_state <=
          forward when signed(duty_cycle) > 0
          else forward_idle;
      end case;
    end process;

    OUTPUT_CL: process(all) is 
    begin
      case present_state is
        when reverse_idle =>
          en <= '0';
          dir <= '0';
        
        when reverse =>
          en <= PWM; 
          dir <= '0';

        when forward_idle =>
          en <= '0';
          dir <= '1';

        when forward =>
          en <= PWM; 
          dir <= '1';
      end case;
    end process;
end RTL;