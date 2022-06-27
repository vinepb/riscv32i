library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity ex_mem_reg is
	port (
        --INPUTS
		clock, clear : in std_logic;
        --MEM control signals
		mem_write_in : in std_logic;
		mem_read_in : in std_logic;
        data_format_in : in std_logic;
		--WB control signals
		mem_to_reg_in : in std_logic_vector(1 downto 0);
		reg_write_in : in std_logic;
        --from ex stage
        ALU_result_in : in std_logic_vector(31 downto 0);
        mem_write_data_in : in std_logic_vector(31 downto 0);
        register_destination_address_in : in std_logic_vector(4 downto 0);
        instruction_address_in : in std_logic_vector(31 downto 0);

        --OUTPUTS
        --MEM control signals
		mem_write_out : out std_logic;
		mem_read_out : out std_logic;
        data_format_out : out std_logic;
		--WB control signals
		mem_to_reg_out : out std_logic_vector(1 downto 0);
		reg_write_out : out std_logic;
        --from ex stage
        ALU_result_out : out std_logic_vector(31 downto 0);
        mem_write_data_out : out std_logic_vector(31 downto 0);
        register_destination_address_out : out std_logic_vector(4 downto 0);
        instruction_address_out : out std_logic_vector(31 downto 0)
	);
end ex_mem_reg;

architecture logic of ex_mem_reg is
    component reg1b
        port (
            reg_in : in std_logic;
            load, clock, clear : in std_logic;
            reg_out : out std_logic
        );
    end component reg1b;

    component reg2b
        port (
            reg_in : in std_logic_vector(1 downto 0);
            load, clock, clear : in std_logic;
            reg_out : out std_logic_vector(1 downto 0)
        );
    end component reg2b;

    component reg5b
        port (
            reg_in : in std_logic_vector(4 downto 0);
            load, clock, clear : in std_logic;
            reg_out : out std_logic_vector(4 downto 0)
        );
    end component reg5b;

    component reg32b
        port (
            reg_in : in std_logic_vector(31 downto 0);
            load, clock, clear : in std_logic;
            reg_out : out std_logic_vector(31 downto 0)
        );
    end component reg32b;
    --INTERNAL SIGNALS
    --MEM control signals
    signal mem_write_input_signal : std_logic;
    signal mem_read_input_signal : std_logic;
    signal data_format_input_signal : std_logic;
    --WB control signals
    signal mem_to_reg_input_signal : std_logic_vector(1 downto 0);
    signal reg_write_input_signal : std_logic;
    --from ex stage
    signal ALU_result_input_signal : std_logic_vector(31 downto 0);
    signal mem_write_data_input_signal : std_logic_vector(31 downto 0);
    signal register_destination_address_input_signal : std_logic_vector(4 downto 0);
    signal instruction_address_input_signal : std_logic_vector(31 downto 0);
    --MEM control signals
    signal mem_write_output_signal : std_logic;
    signal mem_read_output_signal : std_logic;
    signal data_format_output_signal : std_logic;
    --WB control signals
    signal mem_to_reg_output_signal : std_logic_vector(1 downto 0);
    signal reg_write_output_signal : std_logic;
    --from ex stage
    signal ALU_result_output_signal : std_logic_vector(31 downto 0);
    signal mem_write_data_output_signal : std_logic_vector(31 downto 0);
    signal register_destination_address_output_signal : std_logic_vector(4 downto 0);
    signal instruction_address_output_signal : std_logic_vector(31 downto 0);
begin
	mem_write_reg : reg1b port map(mem_write_input_signal, '1', clock, clear, mem_write_output_signal);
    mem_read_reg : reg1b port map(mem_read_input_signal, '1', clock, clear, mem_read_output_signal);
    mem_to_reg_reg : reg2b port map(mem_to_reg_input_signal, '1', clock, clear, mem_to_reg_output_signal);
    reg_write_reg : reg1b port map(reg_write_input_signal, '1', clock, clear, reg_write_output_signal);
    data_format_reg : reg1b port map(data_format_input_signal, '1', clock, clear, data_format_output_signal);
    ALU_result_reg : reg32b port map(ALU_result_input_signal, '1', clock, clear, ALU_result_output_signal);
    mem_write_data_reg : reg32b port map(mem_write_data_input_signal, '1', clock, clear, mem_write_data_output_signal);
    register_destination_address_reg : reg5b port map(register_destination_address_input_signal, '1', clock, clear, register_destination_address_output_signal);
    instruction_address_reg : reg32b port map(instruction_address_input_signal, '1', clock, clear, instruction_address_output_signal);

    mem_write_input_signal <= mem_write_in;
    mem_read_input_signal <= mem_read_in;
    data_format_input_signal <= data_format_in;
    --WB control signals
    mem_to_reg_input_signal <= mem_to_reg_in;
    reg_write_input_signal <= reg_write_in;
    --from ex stage
    ALU_result_input_signal <= ALU_result_in;
    mem_write_data_input_signal <= mem_write_data_in;
    register_destination_address_input_signal <= register_destination_address_in;
    instruction_address_input_signal <= instruction_address_in;
    --MEM control signals
    mem_write_out <= mem_write_output_signal;
    mem_read_out <= mem_read_output_signal;
    data_format_out <= data_format_output_signal;
    --WB control signals
    mem_to_reg_out <= mem_to_reg_output_signal;
    reg_write_out <= reg_write_output_signal;
    --from ex stage
    ALU_result_out <= ALU_result_output_signal;
    mem_write_data_out <= mem_write_data_output_signal;
    register_destination_address_out <= register_destination_address_output_signal;
    instruction_address_out <= instruction_address_output_signal;
end logic;