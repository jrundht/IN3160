library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quadrature_decoder is
  port(
    mclk    : in std_logic;
    reset   : in std_logic;

    --synchronized a and b
    sa      : in std_logic; 
    sb      : in std_logic;

    pos_inc : out std_logic;
    pos_dec : out std_logic
  );
end entity;

architecture RTL of quadrature_decoder is
  signal err                : std_logic := '0';
  signal ab_combined        : std_logic_vector(1 downto 0) := (others => '0');
  signal next_inc, next_dec : std_logic := '0';

  type state_type is (s_reset, s_init, s_0, s_1, s_2, s_3);
  signal present_state, next_state : state_type;
begin

  ab_combined(1) <= sa;
  ab_combined(0) <= sb;

  REGISTER_ASSIGNMENT: process(mclk) is 
  begin
    if rising_edge(mclk) then
      present_state <= s_reset when reset else next_state;
      pos_dec <= '0' when pos_dec else next_inc;
      pos_inc <= '0' when pos_inc else next_dec;
    end if;  
  end process;

  NEXT_STATE_CL: process(all) is
  begin
    next_state <= present_state;
    case present_state is 
      when s_reset =>
        next_state <= s_init 
        when ab_combined = "00"
        else s_reset;

      when s_init =>
        next_state <= s_0
          when ab_combined = "00"
          else s_1 
          when ab_combined = "01"
          else s_2
          when ab_combined = "11"
          else s_3;
      
      when s_0 =>
        next_state <= s_0
          when ab_combined = "00"
          else s_1 
          when ab_combined = "01"
          else s_reset
          when ab_combined = "11"
          else s_3;

      when s_1 =>
        next_state <= s_0
          when ab_combined = "00"
          else s_1 
          when ab_combined = "01"
          else s_2
          when ab_combined = "11"
          else s_reset;

      when s_2 =>
        next_state <= s_reset
          when ab_combined = "00"
          else s_1 
          when ab_combined = "01"
          else s_2
          when ab_combined = "11"
          else s_3;

      when s_3 =>
        next_state <= s_0
          when ab_combined = "00"
          else s_reset 
          when ab_combined = "01"
          else s_2
          when ab_combined = "11"
          else s_3;
      end case;
  end process;

  OUTPUT_CL: process(all) is
  begin
    err <= '0';
    -- pos_inc <= '0';
    -- pos_dec <= '0';

    case present_state is
      when s_reset =>

      when s_init =>

      when s_0 =>
        -- pos_inc <= '1' when ab_combined = "01";
        err     <= '1' when ab_combined = "11";
        -- pos_dec <= '1' when ab_combined = "10";

      when s_1 =>
        -- pos_dec <= '1' when ab_combined = "00";
        -- pos_inc <= '1' when ab_combined = "11";
        err     <= '1' when ab_combined = "10";

      when s_2 =>
        err     <= '1' when ab_combined = "00";
        -- pos_dec <= '1' when ab_combined = "01";
        -- pos_inc <= '1' when ab_combined = "10";

      when s_3 =>
        -- pos_inc <= '1' when ab_combined = "00";
        err     <= '1' when ab_combined = "01";
        -- pos_dec <= '1' when ab_combined = "11";
    end case;
  end process;

  -- Logic for controlling inc and dec
  -- If put in the output_cl process they only become 0.5 clock cycles long
  INCDEC_LOGIC: process(all) is
  begin
    next_inc <= '1' 
    when present_state = s_0 and ab_combined = "01"
    else '1' 
    when present_state = s_1 and ab_combined = "11"
    else '1' 
    when present_state = s_2 and ab_combined = "10"
    else '1' 
    when present_state = s_3 and ab_combined = "00"
    else '0';


    next_dec <= '1' 
    when present_state = s_0 and ab_combined = "10"
    else '1' 
    when present_state = s_1 and ab_combined = "00"
    else '1' 
    when present_state = s_2 and ab_combined = "01"
    else '1' 
    when present_state = s_3 and ab_combined = "11"
    else '0';
  end process;

end RTL;