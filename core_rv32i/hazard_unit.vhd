library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity hazard_unit is
	port (
        register_source_address_1 : in std_logic_vector(4 downto 0);
        register_source_address_2 : in std_logic_vector(4 downto 0);
        mem_read_ID_EX : in std_logic;
        register_destination_address_ID_EX : std_logic_vector(4 downto 0);

        flush_signal : out std_logic
    );
end entity hazard_unit;

architecture logic of hazard_unit is
    signal internal_flush_signal : std_logic := '0';
begin
    process_0 : process(register_source_address_1, register_source_address_2, mem_read_ID_EX, register_destination_address_ID_EX)
    begin
        if (mem_read_ID_EX = '1') and ((register_source_address_1 = register_destination_address_ID_EX) or (register_source_address_2 = register_destination_address_ID_EX)) and (register_destination_address_ID_EX /= "00000") then
            internal_flush_signal <= '1';
        else
            internal_flush_signal <= '0';
        end if;
    end process;
    flush_signal <= internal_flush_signal;
end architecture logic;