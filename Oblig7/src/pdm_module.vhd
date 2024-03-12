library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pdm_module is 
  generic( WIDTH: natural := 16 );  
  port( 
    clk,  
    reset      : in std_logic; 
    setpoint,  
    min_off,    
    min_on, 
    max_on     : in std_logic_vector(WIDTH-1 downto 0); 
    mea_req    : in std_logic; 
    mea_ack, 
    pdm_pulse  : out std_logic  
  ); 
end entity pdm_module; 

architecture RTL of pdm_module is
  signal r_acc, next_acc           : unsigned(WIDTH downto 0) := (others => '0');       -- acc=accumulator, +1bit
  alias PDM_out                    : std_logic is r_acc(r_acc'left); -- leftmost bit = “carry”

  signal next_timer, next_counter  : unsigned(WIDTH-1 downto 0) := (others => '0');
  signal timer, counter, update_timer  : unsigned(WIDTH-1 downto 0) := (others => '0');

  type state_type is (s_mea, s_low, s_high);
  signal  present_state, next_state : state_type;
 

  begin

    next_acc <= ("0" & unsigned(setpoint)) + ("0" & r_acc(WIDTH-1 downto 0));
      
    -- 1: Seq state assignment -- alt som er avhengig av klokka
    REGISTER_ASSIGNMENT: process(clk) is
    begin
      if rising_edge(clk) then
        if reset then -- Synchronous?
          present_state <= s_low;

        else
          -- Update timer and counter 
          timer <= next_timer;
          counter <= next_counter when PDM_out = '1';
          r_acc <= next_acc;
          present_state <= next_state;

        end if;
      end if;
    end process;

    -- 2: combinatorial next_state logic -- bytte fra en state til neste
    next_state_CL: process(all) is
    begin
      next_state <= present_state;
      case present_state is 
        
        -- State: pulse=0
        when s_low => 
          next_state <= 
          s_mea when mea_req else 
          s_high when 
          timer = "0" and counter > unsigned(min_on)
          else s_low;
          
        -- State: pulse=1
        when s_high =>
          next_state <= 
          s_low when 
          timer = "0" or counter = "0"
          else s_high;

        -- State: measurement
        when s_mea =>
          next_state <=
          s_mea when mea_req else s_low;

      end case;
    end process;
    
    -- 3: combinatorial output logic -- output i en state -- det som står i de grønne boksene i asm
    output_CL: process(all) is
      begin
        next_timer <= (others => '0') when timer = 0 else timer - 1;

        case present_state is
            when s_low =>
              next_timer <= unsigned(max_on) when next_state = s_high;
             
              pdm_pulse <= '0';
            when s_high => 
              next_timer <= unsigned(min_off) when next_state = s_low;
              pdm_pulse <= '1';
            when s_mea =>
              mea_ack <= '1' when mea_req else '0';
        end case;
    end process;

    counting: process(all) is
      variable MAX_VALUE : unsigned(WIDTH-1 downto 0) := (others => '1'); -- Maximum value for counter
      variable ZERO : unsigned(WIDTH-1 downto 0) := (others => '0');      -- Zero value for counter
      begin
        -- Counter logic
        next_counter <= 
          --Count up logic
          (counter + 1) 
          when (pdm_pulse = '0' and counter < MAX_VALUE) 
          
          -- Count down logic
          else (counter - 1) 
          when (pdm_pulse = '1' and counter > ZERO) 
          else counter;


        update_timer <= unsigned(max_on) when pdm_pulse else unsigned(min_off);
    end process;

  end architecture RTL;