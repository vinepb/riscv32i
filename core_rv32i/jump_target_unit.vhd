library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity jump_target_unit is
	port (
		current_instruction_address : in std_logic_vector(31 downto 0);
		register_source_data_1 : in std_logic_vector(31 downto 0);
		immediate : in std_logic_vector(31 downto 0);
		jump_target_sel : in std_logic;
		target_address : out std_logic_vector(31 downto 0)
	);
end jump_target_unit;

architecture behavioral of jump_target_unit is
	component adder
		port (
			input_0 : in std_logic_vector(31 downto 0);
			input_1 : in std_logic_vector(31 downto 0);
			output_0 : out std_logic_vector(31 downto 0)
		);
	end component adder;

	component mux_2_1
		port(
			selection : in std_logic;
			input_0, input_1 : in std_logic_vector(31 downto 0);
			output_0 : out std_logic_vector(31 downto 0)
		);
	end component mux_2_1;

	signal internal_jump_target_sel : std_logic := '0';
	signal internal_current_instruction_address : std_logic_vector(31 downto 0) := X"00000000";
	signal internal_immediate : std_logic_vector(31 downto 0) := X"00000000";
	signal internal_target_address : std_logic_vector(31 downto 0) := X"00000000";
	signal internal_mux_output : std_logic_vector(31 downto 0) := X"00000000";
begin
	internal_mux_2_1 : mux_2_1 port map (internal_jump_target_sel, internal_current_instruction_address, register_source_data_1, internal_mux_output);
	internal_adder : adder port map(internal_mux_output, internal_immediate, internal_target_address);

	internal_jump_target_sel <= jump_target_sel;
	internal_current_instruction_address <= current_instruction_address;
	internal_immediate <= immediate;
	target_address <= internal_target_address;
end behavioral;