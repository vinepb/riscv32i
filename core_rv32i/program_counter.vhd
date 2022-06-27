library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity program_counter is
	port (
		clear, clock : in std_logic;
		address_in : in std_logic_vector(31 downto 0);
		next_address : out std_logic_vector(31 downto 0);
		address_out : out std_logic_vector(31 downto 0)
	);
end entity program_counter;

architecture logic of program_counter is
	component reg32b
		port (
			reg_in : in std_logic_vector(31 downto 0);
			load, clock, clear : in std_logic;
			reg_out : out std_logic_vector(31 downto 0)
		);
	end component;
begin
	internal_register : reg32b port map(address_in, '1', clock, clear, address_out);
	next_address <= address_in;	
end logic;