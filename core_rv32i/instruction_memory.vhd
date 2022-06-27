library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity instruction_memory is
    port (
		clock : in std_logic;
		byte_address : in std_logic_vector(31 downto 0);
		output_data : out std_logic_vector(31 downto 0)
    );
end entity instruction_memory;

architecture logic of instruction_memory is
	component progmem
		port(
			address		: in std_logic_vector (15 downto 0);
			clock		: in std_logic  := '1';
			q		: out std_logic_vector (31 downto 0)
		);
	end component progmem;

    signal memory_address : std_logic_vector(31 downto 0) := X"00000000";
begin
	address_acquirement : process (byte_address)
	begin
		memory_address <= std_logic_vector(shift_right(unsigned(byte_address), 2)); --Dividing by 4 since 32 = 4*8
	end process;
	progmem_0 : progmem port map(memory_address(15 downto 0), clock, output_data);
end architecture logic;