library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity if_id_reg is
	port (
		clock, clear : in std_logic;

		instruction_address_in : in std_logic_vector(31 downto 0);
		instruction_data_in : in std_logic_vector(31 downto 0);

		instruction_address_out : out std_logic_vector(31 downto 0);
		instruction_data_out : out std_logic_vector(31 downto 0)
	);
end if_id_reg;

architecture logic of if_id_reg is

	component reg32b
        port (
            reg_in : in std_logic_vector(31 downto 0);
            load, clock, clear : in std_logic;
            reg_out : out std_logic_vector(31 downto 0)
        );
    end component reg32b;
	
	signal instruction_address_input_signal : std_logic_vector(31 downto 0);
	signal instruction_data_input_signal : std_logic_vector(31 downto 0);

	signal instruction_address_output_signal : std_logic_vector(31 downto 0);
	signal instruction_data_output_signal : std_logic_vector(31 downto 0);

begin
	instruction_address_reg : reg32b port map(instruction_address_input_signal, '1', clock, clear, instruction_address_output_signal);
	instruction_data_reg : reg32b port map(instruction_data_input_signal, '1', clock, clear, instruction_data_output_signal);

	instruction_address_input_signal <= instruction_address_in;
	instruction_data_input_signal <= instruction_data_in;

	instruction_address_out <= instruction_address_output_signal;
	instruction_data_out <= instruction_data_output_signal;
end logic;