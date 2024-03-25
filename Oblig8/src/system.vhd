library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system is
    port(
      mclk  : in std_logic;
      reset : in std_logic;

      sa    : in std_logic;
      sb    : in std_logic
    );
end entity;


architecture RTL of system is
    signal duty_cycle : std_logic_vector(7 downto 0);
    
    signal en, dir    : std_logic;

    signal en_synch_test, dir_synch_test : std_logic;
    signal sa_synch_test, sb_synch_test : std_logic;

    signal sys_pos_inc, sys_pos_dec : std_logic;
    signal sys_velocity : signed(7 downto 0);

    signal seg7_velocity : std_logic_vector(6 downto 0);
    signal sys_c : std_logic;
  begin
    
    -- self_test_module
    self_test : entity work.self_test_module  
    port map(mclk => mclk, 
              reset => reset, 
              duty_cycle => duty_cycle);

    -- pwm_module
    pwm_module : entity work.pulse_width_modulator
    port map(mclk => mclk, 
              reset => reset, 
              duty_cycle => duty_cycle, 
              en => en, 
              dir => dir);

    -- output_synch
    output_synch : entity work.output_synchronizer
    port map(mclk => mclk, 
              reset => reset, 
              en => en, 
              dir => dir, 
              en_synch => en_synch_test, 
              dir_synch => dir_synch_test);

    -- input_synch
    input_synch : entity work.input_synchronizer
    port map(mclk => mclk,
              reset => reset, 
              sa => sa, 
              sb => sb,
              sa_synch => sa_synch_test, 
              sb_synch => sb_synch_test);

    -- quadrature_decoder
    quad_dec : entity work.quadrature_decoder
    port map(mclk => mclk,
              reset => reset, 
              sa => sa_synch_test, 
              sb => sb_synch_test,
              pos_inc => sys_pos_inc,
              pos_dec => sys_pos_dec);

    -- velocity_reader
    vel_reader : entity work.velocity_reader
    port map(mclk => mclk,
              reset => reset,
              pos_inc => sys_pos_inc,
              pos_dec => sys_pos_dec, 
              velocity => sys_velocity);

    -- seg7ctrl
    seg7ctrl : entity work.seg7ctrl
    port map(mclk => mclk,
              reset => reset,
              d0 => std_logic_vector(abs(sys_velocity(7 downto 4))), 
              d1 => std_logic_vector(abs(sys_velocity(3 downto 0))),
              abcdefg => seg7_velocity,
              c => sys_c);
    
  end RTL;