library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity compute_seq_pipelined is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        a       : in std_logic_vector(15 downto 0);
        b       : in std_logic_vector(15 downto 0);
        c       : in std_logic_vector(15 downto 0);
        d       : in std_logic_vector(15 downto 0);
        vdata   : in std_logic;

        vresult : out std_logic;
        result  : out std_logic_vector(17 downto 0)
    );
end entity compute_seq_pipelined;

architecture RTL of compute_seq_pipelined is
    signal r_ab, r_cd : unsigned(16 downto 0);
    signal r_vdata : std_logic;
    
    signal next_ab, next_cd : unsigned(16 downto 0);
    signal next_result : std_logic_vector(17 downto 0);
    -- signal next_vresult : std_logic;

begin

    next_ab <= unsigned("0" & a) + unsigned("0" & b);
    next_cd <= unsigned("0" & c) + unsigned("0" & d);
    next_result <= std_logic_vector(("0" & naxt_ab) + ("0" & naxt_ab)) 
                when r_vdata else (others => '0');

    process(clk) is 

    begin
        if rising_edge(clk) then
            if reset then
                r_ab <= (others => '0');
                r_cd <= (others => '0');
                r_vdata <= (others => '0');

                vresult <= '0';
                result  <= (others => '0');
            else 
                r_ab <= next_ab;
                r_cd <= next_cd;
                result <= next_result;
                r_vdata <= vdata;
                vresult <= r_vdata;
            end if;

        end if;

    end process;
    


end architecture RTL;