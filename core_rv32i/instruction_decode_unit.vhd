library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity instruction_decode_unit is
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
end entity instruction_decode_unit;

architecture logic of instruction_decode_unit is
    type operational_states is (normal);
	signal current_state, next_state : operational_states := normal;

	type instruction_cluster is (INVALID, R_type, I_type, S_type, SB_type, U_type, UJ_type);
	signal decoded_cluster : instruction_cluster;

	type instruction_opcode is (INVALID, LUI, JAL, JALR, BEQ, BNE, BLT, BGE, LB, LW, SB, SW,
		ADDI, ANDI, XORI, ORI, ADD, SUB, inst_AND, inst_XOR, inst_OR , inst_SLL, inst_SRL, inst_SLT);
	signal decoded_opcode : instruction_opcode;

    signal fetched_instruction : std_logic_vector(31 downto 0) := X"00000000";

    signal internal_opcode : std_logic_vector(6 downto 0) := "0000000";
    signal internal_funct7 : std_logic_vector(6 downto 0) := "0000000";
    signal internal_funct3 : std_logic_vector(2 downto 0) := "000";
    signal internal_register_source_address_1 : std_logic_vector(4 downto 0) := "00000";
    signal internal_register_source_address_2 : std_logic_vector(4 downto 0) := "00000";
    signal internal_register_destination_address : std_logic_vector(4 downto 0) := "00000";
	signal internal_jump_target_sel : std_logic := '0';
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
                        internal_opcode <= "0000000";
                        internal_funct7 <= "0000000";
                        internal_funct3 <= "000";
                        internal_register_destination_address <= "00000";
                        internal_register_source_address_1 <= "00000";
                        internal_register_source_address_2 <= "00000";
						internal_jump_target_sel <= '0';
                    when R_type =>
                        internal_opcode <= fetched_instruction(6 downto 0);
                        internal_funct7 <= fetched_instruction(31 downto 25);
                        internal_funct3 <= fetched_instruction(14 downto 12);
                        internal_register_destination_address <= fetched_instruction(11 downto 7);
                        internal_register_source_address_1 <= fetched_instruction(19 downto 15);
                        internal_register_source_address_2 <= fetched_instruction(24 downto 20);
						internal_jump_target_sel <= '0';
                    when I_type =>
                        internal_opcode <= fetched_instruction(6 downto 0);
                        internal_funct7 <= "0000000";
                        internal_funct3 <= fetched_instruction(14 downto 12);
                        internal_register_destination_address <= fetched_instruction(11 downto 7);
                        internal_register_source_address_1 <= fetched_instruction(19 downto 15);
                        internal_register_source_address_2 <= "00000";
						case (decoded_opcode) is
							when JALR =>
								internal_jump_target_sel <= '1';
							when others =>
								internal_jump_target_sel <= '0';
						end case;
                    when S_type =>
                        internal_opcode <= fetched_instruction(6 downto 0);
                        internal_funct7 <= "0000000";
                        internal_funct3 <= fetched_instruction(14 downto 12);
                        internal_register_destination_address <= "00000";
                        internal_register_source_address_1 <= fetched_instruction(19 downto 15);
                        internal_register_source_address_2 <= fetched_instruction(24 downto 20);
						internal_jump_target_sel <= '0';
                    when SB_type =>
                        internal_opcode <= fetched_instruction(6 downto 0);
                        internal_funct7 <= "0000000";
                        internal_funct3 <= fetched_instruction(14 downto 12);
                        internal_register_destination_address <= "00000";
                        internal_register_source_address_1 <= fetched_instruction(19 downto 15);
                        internal_register_source_address_2 <= fetched_instruction(24 downto 20);
						internal_jump_target_sel <= '0';
                    when U_type =>
                        internal_opcode <= fetched_instruction(6 downto 0);
                        internal_funct7 <= "0000000";
                        internal_funct3 <= "000";
                        internal_register_destination_address <= fetched_instruction(11 downto 7);
                        internal_register_source_address_1 <= "00000";
                        internal_register_source_address_2 <= "00000";
						internal_jump_target_sel <= '0';
                    when UJ_type =>
                        internal_opcode <= fetched_instruction(6 downto 0);
                        internal_funct7 <= "0000000";
                        internal_funct3 <= "000";
                        internal_register_destination_address <= fetched_instruction(11 downto 7);
                        internal_register_source_address_1 <= "00000";
                        internal_register_source_address_2 <= "00000";
						internal_jump_target_sel <= '0';
                    when others =>
                end case;
                next_state <= normal;
        end case;
    end process;

    fetched_instruction <= instruction;
    opcode <= internal_opcode;
    funct7 <= internal_funct7;
    funct3 <= internal_funct3;
    register_source_address_1 <= internal_register_source_address_1;
    register_source_address_2 <= internal_register_source_address_2;
    register_destination_address <= internal_register_destination_address;
	jump_target_sel <= internal_jump_target_sel;

end architecture logic;