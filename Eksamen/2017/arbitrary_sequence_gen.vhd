library IEEE:
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arbitrary_sequencer_gen is
  port(
    clk  : in std_logic;
    rst  : in std_logic;
    run  : in std_logic;
    q    : out std_logic_vector(2 downto 0)
  );
end entity;

architecture RTL of arbitrary_sequencer_gen is
  type state_type is (S_1, S_2, S_3, S_4,
                      S_5, S_6, S_7);
  signal present_state, next_state : state_type;
  
begin

  REGISTER_ASSIGNMENT: process(clk) is
  begin
    if rising_edge(clk) then
      if rst then
        present_state <= s_4;
      else
        present_state <= next_state;
      end if;
    end if;
  end process;

  NEXT_STATE_CL: process(all) is
  begin
    case present_state is
      when s_4 =>
        next_state <=
          s_2 when run else s_4;
      when s_2 =>
        next_state <=
          s_5 when run else s_2;
      when s_5 =>
        next_state <=
          s_6 when run else s_5;
      when s_7 =>
        next_state <=
          s_3 when run else s_7;
      when s_3 =>
        next_state <=
          s_1 when run else s_3;
      when s_1 =>
        next_state <=
          s_4 when run else s_1;
      when others =>
        next_state <= s_4;
    end case;
  end process;

  OUTPUT_CL: process(all) is
  begin
    case present_state is
      when s_4 =>
        q <= "100";
      when s_2 =>
        q <= "010";
      when s_5 =>
        q <= "101";
      when s_6 =>
        q <= "110";
      when s_7 =>
        q <= "111";
      when s_3 =>
        q <= "011";
      when s_1 =>
        q <= "001";
    end case;
  end process;

end architecture RTL;
