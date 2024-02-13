library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package Declaration
package subprog_pck is
    function parity_toggle(indata : std_logic_vector) return std_logic;

    function parity_xor(indata : std_logic_vector) return std_logic;
end package subprog_pck;

-- Package Body Section
package body subprog_pck is
    --Method 1: parity toggle, using for, loop and variables.   
    function parity_toggle(indata : std_logic_vector) return std_logic is 
    variable toggle : std_logic := '0';
    begin
        for i in indata'range loop
        if indata(i) = '1' then
            toggle := not toggle;
        end if;        
        end loop;
        return toggle;
    end parity_toggle;
    
    -- Method: 2 parity using xor function (VHDL 2008)
    function parity_xor(indata : std_logic_vector) return std_logic is
    begin
        return xor(indata);
    end parity_xor;
    
end package body subprog_pck;
