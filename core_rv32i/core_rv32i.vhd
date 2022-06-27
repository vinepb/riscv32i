library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity core_rv32i is
	port (
		clock : in std_logic;
		reset : in std_logic;
		debug_instruction : out std_logic_vector(31 downto 0)
	);
end entity core_rv32i;

architecture logic of core_rv32i is
	component datapath
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
			register_destination_address_mem_wb_out : out std_logic_vector(4 downto 0);
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
	end component datapath;

	component controller
		port (
			clock : in std_logic;
			reset : in std_logic;
			
			-- from datapath
			instruction : in std_logic_vector(31 downto 0);

			-- to datapath
			mem_to_reg_out : out std_logic_vector(1 downto 0);
			reg_write_out : out std_logic;
			mem_write_out : out std_logic;
			mem_read_out : out std_logic;
			data_format_out : out std_logic;
			ALU_Src_out : out std_logic;
			ALU_Op_out : out std_logic_vector(3 downto 0);
			branch_control_out : out std_logic_vector(3 downto 0);
			jump_signal_out : out std_logic
		);
	end component controller;

	component forwarding_unit
		port (
			register_source_address_1_ID_EX : in std_logic_vector(4 downto 0);
			register_source_address_2_ID_EX : in std_logic_vector(4 downto 0);
			register_destination_address_EX_MEM : in std_logic_vector(4 downto 0);
			register_destination_address_MEM_WB : in std_logic_vector(4 downto 0);
			mem_to_reg_EX_MEM : in std_logic_vector(1 downto 0);
			mem_to_reg_MEM_WB : in std_logic_vector(1 downto 0);

			forwardA_out : out std_logic_vector(1 downto 0);
			forwardB_out : out std_logic_vector(1 downto 0)
		);
	end component forwarding_unit;

	component hazard_unit
		port (
			register_source_address_1 : in std_logic_vector(4 downto 0);
			register_source_address_2 : in std_logic_vector(4 downto 0);
			mem_read_ID_EX : in std_logic;
			register_destination_address_ID_EX : std_logic_vector(4 downto 0);

			flush_signal : out std_logic
		);
	end component hazard_unit;

	component mux16_2_1
		port (
			selection : in std_logic;
			input_0, input_1 : in std_logic_vector(15 downto 0);
			output_0 : out std_logic_vector(15 downto 0)
		);
	end component mux16_2_1;

	--CONTROL TO MUX
	signal mem_to_reg : std_logic_vector(1 downto 0);
	signal reg_write : std_logic;
	signal mem_write : std_logic;
	signal mem_read : std_logic;
	signal data_format : std_logic; -- lb or lw
	signal ALU_Src : std_logic; -- select RS2 data or Imm
	signal ALU_Op : std_logic_vector(3 downto 0);
	signal branch_control : std_logic_vector(3 downto 0);
	signal jump_signal : std_logic;
	signal control_bits_in : std_logic_vector(15 downto 0);
	--MUX TO DATAPATH
	signal control_bits_out : std_logic_vector(15 downto 0);
	--FORWARDING UNIT TO DATAPATH
	signal forwardA : std_logic_vector(1 downto 0);
	signal forwardB : std_logic_vector(1 downto 0);
	--HAZARD DETECTION UNIT TO DATAPATH
	signal flush_signal : std_logic;
	--DATAPATH TO CONTROL
	signal instruction : std_logic_vector(31 downto 0);
	signal if_id_reset : std_logic;
	--DATAPATH TO FORWARDING UNIT
	signal register_destination_address_EX_MEM : std_logic_vector(4 downto 0);
	signal register_destination_address_MEM_WB : std_logic_vector(4 downto 0);
	signal mem_to_reg_EX_MEM : std_logic_vector(1 downto 0);
	signal mem_to_reg_MEM_WB : std_logic_vector(1 downto 0);
	signal register_source_address_1_ID_EX : std_logic_vector(4 downto 0);
	signal register_source_address_2_ID_EX : std_logic_vector(4 downto 0);
	--DATAPATH TO HAZARD DETECTION UNIT
	signal register_source_address_1 : std_logic_vector(4 downto 0);
	signal register_source_address_2 : std_logic_vector(4 downto 0);
	signal register_destination_address_ID_EX : std_logic_vector(4 downto 0);
	signal mem_read_ID_EX : std_logic;
begin
	datapath_0 : datapath port map(clock, reset, forwardA, forwardB, control_bits_out(15 downto 14), control_bits_out(13), control_bits_out(12), control_bits_out(11), control_bits_out(10), control_bits_out(9), control_bits_out(8 downto 5), control_bits_out(4 downto 1), control_bits_out(0), flush_signal, register_destination_address_ID_EX, register_destination_address_EX_MEM, register_destination_address_MEM_WB, mem_read_ID_EX, mem_to_reg_EX_MEM, mem_to_reg_MEM_WB, register_source_address_1, register_source_address_2, register_source_address_1_ID_EX, register_source_address_2_ID_EX, instruction, if_id_reset);
	controller_0 : controller port map(clock, reset, instruction, mem_to_reg, reg_write, mem_write, mem_read, data_format, ALU_Src, ALU_Op, branch_control, jump_signal);
	forwarding_unit_0 : forwarding_unit port map(register_source_address_1_ID_EX, register_source_address_2_ID_EX, register_destination_address_EX_MEM, register_destination_address_MEM_WB, mem_to_reg_EX_MEM, mem_to_reg_MEM_WB, forwardA, forwardB);
	hazard_unit_0 : hazard_unit port map(register_source_address_1, register_source_address_2, mem_read_ID_EX, register_destination_address_ID_EX, flush_signal);
	control_mux : mux16_2_1 port map(if_id_reset, control_bits_in, "0000000000000000", control_bits_out);

	control_bits_in <= std_logic_vector(mem_to_reg & reg_write & mem_write & mem_read & data_format & ALU_Src & ALU_Op & branch_control & jump_signal);
	debug_instruction <= instruction;
end architecture logic;