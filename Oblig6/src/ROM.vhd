library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity ROM is
    generic(
        data_width: natural := 8;
        addr_width: natural := 4
    );
    port(
        address : in std_logic_vector(addr_width-1 downto 0);
        data : out std_logic_vector(data_width-1 downto 0)
    );
end entity;

architecture synth of ROM is
    type memory_array is array(0 to 2**addr_width-1) of
    std_logic_vector(data_width-1 downto 0);

    constant ROM_DATA: memory_array := (
        "00010010", -- 1 2
        "00110100", -- 3 4
        "01000000", -- 4 0
        "00000000", -- 0 0
        "01010110", -- 5 6
        "01110011", -- 7 3
        "00000000", -- 0 0
        "10000110", -- 8 6
        "10010000", -- 9 0
        "00000000", -- 0 0
        "10101011", -- A B
        "00110000", -- 3 0
        "00000000", -- 0 0
        "11000110", -- C 6
        "01100101", -- 6 5
        "00000000"  -- 0 0
    );
begin
    data <= ROM_DATA(to_integer(unsigned(address)));
end architecture synth;