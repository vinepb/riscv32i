library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity datapath is
	port (
		clock : in std_logic;
		reset : in std_logic;

		-- from control
		forwardA : in std_logic_vector(1 downto 0);
		forwardB : in std_logic_vector(1 downto 0);
		mem_to_reg : in std_logic_vector(1 downto 0);
		reg_write : in std_logic;
		mem_write : in std_logic;
		mem_read : in std_logic;
		data_format : in std_logic;
		ALU_Src : in std_logic;
		ALU_Op : in std_logic_vector(3 downto 0);
		branch_control : in std_logic_vector(3 downto 0);
		jump_signal : in std_logic;
		flush_signal : in std_logic;
		
		-- to control
		register_destination_address_ID_EX_out : out std_logic_vector(4 downto 0);
		register_destination_address_EX_MEM_out : out std_logic_vector(4 downto 0);
		register_destination_address_MEM_WB_out : out std_logic_vector(4 downto 0);
		mem_read_ID_EX_out : out std_logic;
		mem_to_reg_EX_MEM_out : out std_logic_vector(1 downto 0);
		mem_to_reg_MEM_WB_out : out std_logic_vector(1 downto 0);
		register_source_address_1_out : out std_logic_vector(4 downto 0);
		register_source_address_2_out : out std_logic_vector(4 downto 0);
		register_source_address_1_ID_EX_out : out std_logic_vector(4 downto 0);
		register_source_address_2_ID_EX_out : out std_logic_vector(4 downto 0);
		fetched_instruction : out std_logic_vector(31 downto 0);
		if_id_reset_out : out std_logic
	);
end entity datapath;

architecture logic of datapath is

	component adder
		port (
			input_0 : in std_logic_vector(31 downto 0);
			input_1 : in std_logic_vector(31 downto 0);
			output_0 : out std_logic_vector(31 downto 0)
		);
	end component adder;

	component delay_driver
        port (
            reg_in : in std_logic;
            load, clock, clear : in std_logic;
            reg_out : out std_logic
        );
    end component delay_driver;

	component mux_2_1
		port (
			selection : in std_logic;
			input_0, input_1 : in std_logic_vector(31 downto 0);
			output_0 : out std_logic_vector(31 downto 0)
		);
	end component mux_2_1;

	component mux_3_1
		port (
			selection : in std_logic_vector(1 downto 0);
			input_0, input_1, input_2 : in std_logic_vector(31 downto 0);
			output_0 : out std_logic_vector(31 downto 0)
		);
	end component mux_3_1;

	component mux_4_1
		port (
			selection : in std_logic_vector(1 downto 0);
			input_0, input_1, input_2, input_3 : in std_logic_vector(31 downto 0);
			output_0 : out std_logic_vector(31 downto 0)
		);
	end component mux_4_1;

	component if_id_reg
		port (
			clock, clear : in std_logic;
			instruction_address_in : in std_logic_vector(31 downto 0);
			instruction_data_in : in std_logic_vector(31 downto 0);
			instruction_address_out : out std_logic_vector(31 downto 0);
			instruction_data_out : out std_logic_vector(31 downto 0)
		);
	end component if_id_reg;

	component id_ex_reg
		port (
			--INPUTS
			clock, clear : in std_logic;
			--EX control signals
			ALU_Op_in : in std_logic_vector(3 downto 0);
			ALU_Src_in : in std_logic;
			--MEM control signals
			mem_write_in : in std_logic;
			mem_read_in : in std_logic;
			data_format_in : in std_logic;
			--WB control signals
			mem_to_reg_in : in std_logic_vector(1 downto 0);
			reg_write_in : in std_logic;
			--from IF/ID
			register_destination_address_in : in std_logic_vector(4 downto 0);
			register_source_address_1_in : in std_logic_vector(4 downto 0);
			register_source_address_2_in : in std_logic_vector(4 downto 0);
			register_source_data_1_in : in std_logic_vector(31 downto 0);
			register_source_data_2_in : in std_logic_vector(31 downto 0);		
			immediate_in : in std_logic_vector(31 downto 0);
			instruction_address_in : in std_logic_vector(31 downto 0);

			--OUTPUTS
			--EX control signals
			ALU_Op_out : out std_logic_vector(3 downto 0);
			ALU_Src_out : out std_logic;
			--MEM control signals
			mem_write_out : out std_logic;
			mem_read_out : out std_logic;
			data_format_out : out std_logic;
			--WB control signals
			mem_to_reg_out : out std_logic_vector(1 downto 0);
			reg_write_out : out std_logic;
			--from IF/ID
			register_destination_address_out : out std_logic_vector(4 downto 0);
			register_source_address_1_out : out std_logic_vector(4 downto 0);
			register_source_address_2_out : out std_logic_vector(4 downto 0);
			register_source_data_1_out : out std_logic_vector(31 downto 0);
			register_source_data_2_out : out std_logic_vector(31 downto 0);		
			immediate_out : out std_logic_vector(31 downto 0);
			instruction_address_out : out std_logic_vector(31 downto 0)
		);
	end component id_ex_reg;

	component ex_mem_reg
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
	end component ex_mem_reg;

	component mem_wb_reg
		port (
			--INPUTS
			clock, clear : in std_logic;
			--WB control signals
			mem_to_reg_in : in std_logic_vector(1 downto 0);
			reg_write_in : in std_logic;
			--from mem stage
			ALU_result_in : in std_logic_vector(31 downto 0);
			mem_read_data_in : in std_logic_vector(31 downto 0);
			register_destination_address_in : in std_logic_vector(4 downto 0);
			instruction_address_in : in std_logic_vector(31 downto 0);
			--OUTPUTS
			--WB control signals
			mem_to_reg_out : out std_logic_vector(1 downto 0);
			reg_write_out : out std_logic;
			--from mem stage
			ALU_result_out : out std_logic_vector(31 downto 0);
			mem_read_data_out : out std_logic_vector(31 downto 0);
			register_destination_address_out : out std_logic_vector(4 downto 0);
			instruction_address_out : out std_logic_vector(31 downto 0)
		);
	end component mem_wb_reg;

	component program_counter
		port (
			clear, clock : in std_logic;
			address_in : in std_logic_vector(31 downto 0);
			next_address : out std_logic_vector(31 downto 0);
			address_out : out std_logic_vector(31 downto 0)
		);
	end component program_counter;

	component instruction_memory
		port (
			clock : in std_logic;
			byte_address : in std_logic_vector(31 downto 0);
			output_data : out std_logic_vector(31 downto 0)
		);
	end component instruction_memory;

	component instruction_decode_unit
		port (
			clock : in std_logic;
			reset : in std_logic;
			instruction : in std_logic_vector(31 downto 0);

			opcode : out std_logic_vector(6 downto 0);
			funct7 : out std_logic_vector(6 downto 0);
			funct3 : out std_logic_vector(2 downto 0);
			register_source_address_1 : out std_logic_vector(4 downto 0);
			register_source_address_2 : out std_logic_vector(4 downto 0);
			register_destination_address : out std_logic_vector(4 downto 0);
			jump_target_sel : out std_logic
		);
	end component instruction_decode_unit;

	component immediate_generator
		port (
			clock : in std_logic;
			reset : in std_logic;

			instruction : in std_logic_vector(31 downto 0);
			immediate : out std_logic_vector(31 downto 0)
		);
	end component immediate_generator;

	component jump_target_unit
		port (
			current_instruction_address : in std_logic_vector(31 downto 0);
			register_source_data_1 : in std_logic_vector(31 downto 0);
			immediate : in std_logic_vector(31 downto 0);
			jump_target_sel : in std_logic;
			target_address : out std_logic_vector(31 downto 0)
		);
	end component jump_target_unit;

	component branch_logic
		port (
			input_0, input_1 : in std_logic_vector(31 downto 0);
			branch :in std_logic;
			branch_control : in std_logic_vector(2 downto 0);
			branch_response : out std_logic
		);
	end component branch_logic;

	component datamem_interface
		port (
			clock, clear : in std_logic;
			byte_address : in std_logic_vector(31 downto 0);
			input_data : in std_logic_vector(31 downto 0);
			load : in std_logic; -- mem_write
			data_format : in std_logic; -- 0 = signed word, 1 = signed byte
			
			output_data : out std_logic_vector(31 downto 0)
		);
	end component datamem_interface;

	component register_file
		port (
			clock, clear, reg_write : in std_logic;
			write_address : in std_logic_vector(4 downto 0);
			write_data : in std_logic_vector(31 downto 0);
			read_address_0 : in std_logic_vector(4 downto 0);
			read_address_1 : in std_logic_vector(4 downto 0);
			output_data_0 : out std_logic_vector(31 downto 0);
			output_data_1 : out std_logic_vector(31 downto 0)
		);
	end component register_file;

	component ALU
		port (
			operation : in std_logic_vector(3 downto 0);
			input_0 : in std_logic_vector(31 downto 0);
			input_1 : in std_logic_vector(31 downto 0);

			ALU_output : out std_logic_vector(31 downto 0)
		);
	end component ALU;

	-- IF originated
	signal next_instruction_address : std_logic_vector(31 downto 0);
	signal selected_instruction_address : std_logic_vector(31 downto 0);
	signal instruction_memory_address : std_logic_vector(31 downto 0);
	signal instruction_address : std_logic_vector(31 downto 0);
	signal instruction : std_logic_vector(31 downto 0);
	signal if_id_reset : std_logic;
	-- ID originated
	signal PC_Src : std_logic;
	signal jump_target_address : std_logic_vector(31 downto 0);
	signal instruction_address_IF_ID : std_logic_vector(31 downto 0);
	signal instruction_IF_ID : std_logic_vector(31 downto 0);
	signal register_source_address_1 : std_logic_vector(4 downto 0);
    signal register_source_address_2 : std_logic_vector(4 downto 0);
    signal register_destination_address : std_logic_vector(4 downto 0);
	signal register_source_data_1 : std_logic_vector(31 downto 0);
	signal register_source_data_2 : std_logic_vector(31 downto 0);
	signal immediate : std_logic_vector(31 downto 0);
	signal opcode : std_logic_vector(6 downto 0);
	signal funct7 : std_logic_vector(6 downto 0);
	signal funct3 : std_logic_vector(2 downto 0);
	signal jump_target_sel : std_logic;
	-- EX originated
	signal PC_Src_delayed : std_logic;
	signal ALU_Op_ID_EX : std_logic_vector(3 downto 0);
	signal ALU_Src_ID_EX : std_logic;
	signal mem_write_ID_EX : std_logic;
	signal mem_read_ID_EX : std_logic;
	signal data_format_ID_EX : std_logic;
	signal mem_to_reg_ID_EX : std_logic_vector(1 downto 0);
	signal reg_write_ID_EX : std_logic;
	signal instruction_address_ID_EX : std_logic_vector(31 downto 0);
	signal register_destination_address_ID_EX : std_logic_vector(4 downto 0);
	signal register_source_address_1_ID_EX : std_logic_vector(4 downto 0);
	signal register_source_address_2_ID_EX : std_logic_vector(4 downto 0);
	signal register_source_data_1_ID_EX : std_logic_vector(31 downto 0);
	signal register_source_data_2_ID_EX : std_logic_vector(31 downto 0);
	signal immediate_ID_EX : std_logic_vector(31 downto 0);
	signal ALU_command_ID_EX : std_logic_vector(3 downto 0);
	signal ALU_result : std_logic_vector(31 downto 0);
	signal mux_A_output_data : std_logic_vector(31 downto 0);
	signal mux_B_output_data : std_logic_vector(31 downto 0);
	signal mux_C_output_data : std_logic_vector(31 downto 0);
	signal branch_result : std_logic;
	-- MEM originated
	signal mem_write_EX_MEM : std_logic;
	signal mem_read_EX_MEM : std_logic;
	signal data_format_EX_MEM : std_logic;
	signal mem_to_reg_EX_MEM : std_logic_vector(1 downto 0);
	signal reg_write_EX_MEM : std_logic;
	signal instruction_address_EX_MEM : std_logic_vector(31 downto 0);
	signal ALU_result_EX_MEM : std_logic_vector(31 downto 0);
	signal mem_write_data_EX_MEM : std_logic_vector(31 downto 0);
	signal mem_read_data : std_logic_vector(31 downto 0);
	signal register_destination_address_EX_MEM : std_logic_vector(4 downto 0);
	-- WB originated
	signal register_destination_address_MEM_WB : std_logic_vector(4 downto 0);
	signal register_destination_data : std_logic_vector(31 downto 0);
	signal mem_to_reg_MEM_WB : std_logic_vector(1 downto 0);
	signal reg_write_MEM_WB : std_logic;
	signal ALU_result_MEM_WB : std_logic_vector(31 downto 0);
	signal mem_read_data_MEM_WB : std_logic_vector(31 downto 0);
	signal instruction_address_MEM_WB : std_logic_vector(31 downto 0);
	signal return_instruction_address : std_logic_vector(31 downto 0);
	

begin
	pc_adder : adder port map(instruction_address, X"00000004", next_instruction_address);
	pc_mux : mux_2_1 port map(PC_Src, next_instruction_address, jump_target_address, selected_instruction_address);
	pc : program_counter port map(reset, clock, selected_instruction_address, instruction_memory_address, instruction_address);
	prog_mem : instruction_memory port map(clock, instruction_memory_address, instruction);

	if_id : if_id_reg port map(clock, if_id_reset, instruction_address, instruction, instruction_address_IF_ID, instruction_IF_ID);
	
	inst_decode : instruction_decode_unit port map(clock, reset, instruction_IF_ID, opcode, funct7, funct3, register_source_address_1, register_source_address_2, register_destination_address, jump_target_sel);
	reg_file : register_file port map(clock, reset, reg_write_MEM_WB, register_destination_address_MEM_WB, register_destination_data, register_source_address_1, register_source_address_2, register_source_data_1, register_source_data_2);
	imm_gen : immediate_generator port map(clock, reset, instruction_IF_ID, immediate);
	JTU : jump_target_unit port map(instruction_address_IF_ID, register_source_data_1, immediate, jump_target_sel, jump_target_address);
	compare_unit : branch_logic port map(register_source_data_1, register_source_data_2, branch_control(3), branch_control(2 downto 0), branch_result);
	PC_Src_delay_reg : delay_driver port map(PC_Src, '1', clock, reset, PC_Src_delayed);
	
	id_ex : id_ex_reg port map(clock, reset, ALU_Op, ALU_Src, mem_write, mem_read, data_format, mem_to_reg, reg_write, register_destination_address, register_source_address_1, register_source_address_2, register_source_data_1, register_source_data_2, immediate, instruction_address_IF_ID, ALU_Op_ID_EX, ALU_Src_ID_EX, mem_write_ID_EX, mem_read_ID_EX, data_format_ID_EX, mem_to_reg_ID_EX, reg_write_ID_EX, register_destination_address_ID_EX, register_source_address_1_ID_EX, register_source_address_2_ID_EX, register_source_data_1_ID_EX, register_source_data_2_ID_EX, immediate_ID_EX, instruction_address_ID_EX);

	mux_A : mux_4_1 port map(forwardA, register_source_data_1_ID_EX, register_destination_data, ALU_result_EX_MEM, mem_read_data, mux_A_output_data);
	mux_B : mux_4_1 port map(forwardB, register_source_data_2_ID_EX, register_destination_data, ALU_result_EX_MEM, mem_read_data, mux_B_output_data);
	mux_C : mux_2_1 port map(ALU_Src_ID_EX, mux_B_output_data, immediate_ID_EX, mux_C_output_data);
	ALU_0 : ALU port map(ALU_Op_ID_EX, mux_A_output_data, mux_C_output_data, ALU_result);

	ex_mem : ex_mem_reg port map(clock, reset, mem_write_ID_EX, mem_read_ID_EX, data_format_ID_EX, mem_to_reg_ID_EX, reg_write_ID_EX, ALU_result, mux_B_output_data, register_destination_address_ID_EX, instruction_address_ID_EX, mem_write_EX_MEM, mem_read_EX_MEM, data_format_EX_MEM, mem_to_reg_EX_MEM, reg_write_EX_MEM, ALU_result_EX_MEM, mem_write_data_EX_MEM, register_destination_address_EX_MEM, instruction_address_EX_MEM);
	
	datamem : datamem_interface port map(clock, reset, ALU_result_EX_MEM, mem_write_data_EX_MEM, mem_write_EX_MEM, data_format_EX_MEM, mem_read_data);
	
	mem_wb : mem_wb_reg port map(clock, reset, mem_to_reg_EX_MEM, reg_write_EX_MEM, ALU_result_EX_MEM, mem_read_data, register_destination_address_EX_MEM, instruction_address_EX_MEM, mem_to_reg_MEM_WB, reg_write_MEM_WB, ALU_result_MEM_WB, mem_read_data_MEM_WB, register_destination_address_MEM_WB, instruction_address_MEM_WB);
	
	return_address_adder : adder port map(instruction_address_MEM_WB, X"00000004", return_instruction_address);
	wb_mux : mux_3_1 port map(mem_to_reg_MEM_WB, ALU_result_MEM_WB, mem_read_data_MEM_WB, return_instruction_address, register_destination_data);

	PC_Src <= (jump_signal or branch_result);
	if_id_reset <= (reset or flush_signal or PC_Src_delayed);

	if_id_reset_out <= if_id_reset;
	register_destination_address_ID_EX_out <= register_destination_address_ID_EX;
	register_destination_address_EX_MEM_out <= register_destination_address_EX_MEM;
	register_destination_address_MEM_WB_out <= register_destination_address_MEM_WB;
	mem_read_ID_EX_out <= mem_read_ID_EX;
	mem_to_reg_EX_MEM_out <= mem_to_reg_EX_MEM;
	mem_to_reg_MEM_WB_out <= mem_to_reg_MEM_WB;
	register_source_address_1_out <= register_source_address_1;
	register_source_address_2_out <= register_source_address_2;
	register_source_address_1_ID_EX_out <= register_source_address_1_ID_EX;
	register_source_address_2_ID_EX_out <= register_source_address_2_ID_EX;
	fetched_instruction <= instruction_IF_ID;
end architecture logic;