library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity controller is
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
end entity controller;

architecture logic of controller is
	type operational_states is (normal);
	signal current_state, next_state : operational_states := normal;

	type instruction_cluster is (INVALID, R_type, I_type, S_type, SB_type, U_type, UJ_type);
	signal decoded_cluster : instruction_cluster;

	type instruction_opcode is (INVALID, LUI, JAL, JALR, BEQ, BNE, BLT, BGE, LB, LW, SB, SW,
		ADDI, ANDI, XORI, ORI, ADD, SUB, inst_AND, inst_XOR, inst_OR , inst_SLL, inst_SRL, inst_SLT);
	signal decoded_opcode : instruction_opcode;

	signal fetched_instruction : std_logic_vector(31 downto 0) := X"00000000";	

	signal internal_mem_to_reg_out : std_logic_vector(1 downto 0) := "00";
	signal internal_reg_write_out : std_logic := '0';
	signal internal_mem_write_out : std_logic := '0';
	signal internal_mem_read_out : std_logic := '0';
	signal internal_data_format_out : std_logic := '0';
	signal internal_ALU_Src_out : std_logic := '0';
	signal internal_ALU_Op_out : std_logic_vector(3 downto 0) := "0000";
	signal internal_branch_control_out : std_logic_vector(3 downto 0) := "0000";
	signal internal_jump_signal_out : std_logic := '0';
begin

	synchronism : process (clock, reset)
	begin
		if (reset = '1') then
			current_state <= normal;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

	logic : process (fetched_instruction, decoded_cluster, decoded_opcode, current_state)
	begin
		case (current_state) is
			when normal =>
				if (fetched_instruction(1 downto 0) = "00") or (fetched_instruction = "00000000000000000000000000010011") then
					decoded_cluster <= INVALID;
					decoded_opcode <= INVALID;
				else
					case (fetched_instruction(6 downto 0)) is --opcode
						when "0110011" =>
							decoded_cluster <= R_type;
							case (fetched_instruction(14 downto 12)) is --funct3
								when "000" =>
									case(fetched_instruction(31 downto 25)) is --funct7
										when "0000000" =>
											decoded_opcode <= ADD;
										when "0100000" =>
											decoded_opcode <= SUB;
										when others =>
											decoded_opcode <= INVALID;
									end case;
								when "001" =>
									decoded_opcode <= inst_SLL;
								when "010" =>
									decoded_opcode <= inst_SLT;
								when "100" =>
									decoded_opcode <= inst_XOR;
								when "101" =>
									case(fetched_instruction(31 downto 25)) is --funct7
										when "0000000" =>
											decoded_opcode <= inst_SRL;
										when others =>
											decoded_opcode <= INVALID;
									end case;
								when "110" =>
									decoded_opcode <= inst_OR;
								when "111" =>
									decoded_opcode <= inst_AND;
								when others =>
									decoded_opcode <= INVALID;
							end case;
						when "0000011" =>
							decoded_cluster <= I_type;
							case (fetched_instruction(14 downto 12)) is --funct3
								when "000" =>
									decoded_opcode <= LB;
								when "010" =>
									decoded_opcode <= LW;
								when others =>
									decoded_opcode <= INVALID;
							end case;
						when "0010011" =>
							decoded_cluster <= I_type;
							case (fetched_instruction(14 downto 12)) is --funct3
								when "000" =>
									decoded_opcode <= ADDI;
								when "100" =>
									decoded_opcode <= XORI;
								when "110" =>
									decoded_opcode <= ORI;
								when "111" =>
									decoded_opcode <= ANDI;
								when others =>
									decoded_opcode <= INVALID;
							end case;
						when "1100111" =>
							decoded_cluster <= I_type;
							case (fetched_instruction(14 downto 12)) is --funct3
								when "000" =>
									decoded_opcode <= JALR;
								when others =>
									decoded_opcode <= INVALID;
							end case;
						when "0100011" =>
							decoded_cluster <= S_type;
							case (fetched_instruction(14 downto 12)) is --funct3
								when "000" =>
									decoded_opcode <= SB;
								when "010" =>
									decoded_opcode <= SW;
								when others =>
									decoded_opcode <= INVALID;
							end case;
						when "1100011" =>
							decoded_cluster <= SB_type;
							case (fetched_instruction(14 downto 12)) is --funct3
								when "000" =>
									decoded_opcode <= BEQ;
								when "001" =>
									decoded_opcode <= BNE;
								when "100" =>
									decoded_opcode <= BLT;
								when "101" =>
									decoded_opcode <= BGE;
								when others =>
									decoded_opcode <= INVALID;
							end case;
						when "0110111" =>
							decoded_cluster <= U_type;
							decoded_opcode <= LUI;
						when "1101111" =>
							decoded_cluster <= UJ_type;
							decoded_opcode <= JAL;
						when others =>
							decoded_cluster <= INVALID;
							decoded_opcode <= INVALID;
					end case; --end case opcode
				end if; --end if !bits(1 downto 0) of opcode

				case (decoded_cluster) is
					when INVALID =>
						internal_mem_to_reg_out <= "00";
						internal_reg_write_out <= '0';
						internal_mem_write_out <= '0';
						internal_mem_read_out <= '0';
						internal_data_format_out <= '0';
						internal_ALU_Src_out <= '0';
						internal_ALU_Op_out <= "0000";
						internal_branch_control_out <= "0000";
						internal_jump_signal_out <= '0';
						next_state <= normal;
					when R_type =>
						internal_mem_to_reg_out <= "00";
						internal_reg_write_out <= '1';
						internal_mem_write_out <= '0';
						internal_mem_read_out <= '0';
						internal_data_format_out <= '0';
						internal_ALU_Src_out <= '0';
						internal_ALU_Op_out <= std_logic_vector(fetched_instruction(30) & fetched_instruction(14 downto 12));
						internal_branch_control_out <= "0000";
						internal_jump_signal_out <= '0';
						next_state <= normal;
					when I_type =>
						case (decoded_opcode) is
							when LB | LW =>
								internal_mem_to_reg_out <= "01";
								internal_reg_write_out <= '1';
								internal_mem_write_out <= '0';
								internal_mem_read_out <= '1';
								internal_data_format_out <= fetched_instruction(13);
								internal_ALU_Src_out <= '1';
								internal_ALU_Op_out <= "0000";
								internal_branch_control_out <= "0000";
								internal_jump_signal_out <= '0';
								next_state <= normal;
							when ADDI | ANDI | XORI | ORI =>
								internal_mem_to_reg_out <= "00";
								internal_reg_write_out <= '1';
								internal_mem_write_out <= '0';
								internal_mem_read_out <= '0';
								internal_data_format_out <= '0';
								internal_ALU_Src_out <= '1';
								internal_ALU_Op_out <= std_logic_vector('0' & fetched_instruction(14 downto 12));
								internal_branch_control_out <= "0000";
								internal_jump_signal_out <= '0';
								next_state <= normal;
							when JALR =>
								internal_mem_to_reg_out <= "10";
								internal_reg_write_out <= '1';
								internal_mem_write_out <= '0';
								internal_mem_read_out <= '0';
								internal_data_format_out <= '0';
								internal_ALU_Src_out <= '0';
								internal_ALU_Op_out <= "0000";
								internal_branch_control_out <= "0000";
								internal_jump_signal_out <= '1';
								next_state <= normal;
							when others =>
						end case;
					when S_type =>
						internal_mem_to_reg_out <= "00";
						internal_reg_write_out <= '0';
						internal_mem_write_out <= '1';
						internal_mem_read_out <= '0';
						internal_data_format_out <= fetched_instruction(13);
						internal_ALU_Src_out <= '1';
						internal_ALU_Op_out <= "0000";
						internal_branch_control_out <= "0000";
						internal_jump_signal_out <= '0';
						next_state <= normal;
					when SB_type =>
						internal_mem_to_reg_out <= "00";
						internal_reg_write_out <= '0';
						internal_mem_write_out <= '0';
						internal_mem_read_out <= '0';
						internal_data_format_out <= '0';
						internal_ALU_Src_out <= '0';
						internal_ALU_Op_out <= "0000";
						internal_branch_control_out <= std_logic_vector('1' & fetched_instruction(14 downto 12));
						internal_jump_signal_out <= '0';
						next_state <= normal;
					when U_type =>
						internal_mem_to_reg_out <= "00";
						internal_reg_write_out <= '1';
						internal_mem_write_out <= '0';
						internal_mem_read_out <= '0';
						internal_data_format_out <= '0';
						internal_ALU_Src_out <= '1';
						internal_ALU_Op_out <= "0000";
						internal_branch_control_out <= "0000";
						internal_jump_signal_out <= '0';
						next_state <= normal;
					when UJ_type =>
						internal_mem_to_reg_out <= "10";
						internal_reg_write_out <= '1';
						internal_mem_write_out <= '0';
						internal_mem_read_out <= '0';
						internal_data_format_out <= '0';
						internal_ALU_Src_out <= '0';
						internal_ALU_Op_out <= "0000";
						internal_branch_control_out <= "0000";
						internal_jump_signal_out <= '1';
						next_state <= normal;
				end case;
		end case;
	end process;

	fetched_instruction <= instruction;

	mem_to_reg_out <= internal_mem_to_reg_out;
	reg_write_out <= internal_reg_write_out;
	mem_write_out <= internal_mem_write_out;
	mem_read_out <= internal_mem_read_out;
	data_format_out <= internal_data_format_out;
	ALU_Src_out <= internal_ALU_Src_out;
	ALU_Op_out <= internal_ALU_Op_out;
	branch_control_out <= internal_branch_control_out;
	jump_signal_out <= internal_jump_signal_out;
end architecture logic;