library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system is
    port(
      mclk  : in std_logic;
      reset : in std_logic;

      sys_en_synch  : out std_logic;
      sys_dir_synch : out std_logic;

      sa    : in std_logic;
      sb    : in std_logic;
      sys_c : out std_logic;

      seg7_velocity : out std_logic_vector(6 downto 0)
    );
end entity;


architecture Structural of system is
    signal sys_duty_cycle : std_logic_vector(7 downto 0);
    
    signal sys_en, sys_dir    : std_logic;

    signal sys_sa_synch, sys_sb_synch : std_logic;

    signal sys_pos_inc, sys_pos_dec : std_logic;

    signal sys_velocity : signed(7 downto 0);
    signal sys_seg7_velocity : std_logic_vector(7 downto 0);
  begin
    
    -- self_test_module - determines speed and direction (duty_cycle) from ROM
    self_test : entity work.self_test_module  
    port map(mclk => mclk, 
              reset => reset, 
              duty_cycle => sys_duty_cycle);

    -- pwm_module - controls speed of motor
    pwm_module : entity work.pulse_width_modulator
    port map(mclk => mclk, 
              reset => reset, 
              duty_cycle => sys_duty_cycle, 
              en => sys_en, 
              dir => sys_dir);

    -- output_synch - sends enable and direction to motor
    output_synch : entity work.output_synchronizer
    port map(mclk => mclk, 
              reset => reset, 
              en => sys_en, 
              dir => sys_dir, 
              en_synch => sys_en_synch, 
              dir_synch => sys_dir_synch);

    -- input_synch - gets input from quadrature_encoder
    input_synch : entity work.input_synchronizer
    port map(mclk => mclk,
              reset => reset, 
              sa => sa, 
              sb => sb,
              sa_synch => sys_sa_synch, 
              sb_synch => sys_sb_synch);

    -- quadrature_decoder
    quad_dec : entity work.quadrature_decoder
    port map(mclk => mclk,
              reset => reset, 
              sa => sys_sa_synch, 
              sb => sys_sb_synch,
              pos_inc => sys_pos_inc,
              pos_dec => sys_pos_dec);

    -- velocity_reader
    vel_reader : entity work.velocity_reader
    port map(mclk => mclk,
              reset => reset,
              pos_inc => sys_pos_inc,
              pos_dec => sys_pos_dec, 
              velocity => sys_velocity);

    -- seg7ctrl - displays velocity on seven segment display
    sys_seg7_velocity <= std_logic_vector(abs(sys_velocity));

    seg7ctrl : entity work.seg7ctrl
    port map(mclk => mclk,
              reset => reset,
              d0 => sys_seg7_velocity(3 downto 0), 
              d1 => sys_seg7_velocity(7 downto 4),
              abcdefg => seg7_velocity,
              c => sys_c);
    
  end Structural;