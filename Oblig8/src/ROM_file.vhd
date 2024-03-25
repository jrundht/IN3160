library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

-- Read from filename - reads he
entity ROM_file is
    generic(
        data_width: natural := 8;
        addr_width: natural := 5;
        filename  : string  := "rom_data.dat"
    );
    port(
        address : in std_logic_vector(addr_width-1 downto 0);
        data : out std_logic_vector(data_width-1 downto 0)
    );
end entity;

architecture synth of ROM_file is
    type memory_array is array(0 to 2**addr_width-1) of
    std_logic_vector(data_width-1 downto 0);

    impure function read_file(path : string) return memory_array is
        file init_file  : text open read_mode is path;
        variable c_line : line;
        variable result : memory_array;
    begin
        for i in 0 to 2**addr_width-1 loop
            readline(init_file, c_line);
            hread(c_line, result(i)); -- data has to be hex
        end loop;
        return result;
    end function;
    
    constant ROM_DATA : memory_array := read_file(filename);
begin
    data <= ROM_DATA(to_integer(unsigned(address)));
end architecture synth;