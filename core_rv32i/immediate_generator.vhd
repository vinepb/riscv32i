library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity immediate_generator is
    port (
        clock : in std_logic;
        reset : in std_logic;

        instruction : in std_logic_vector(31 downto 0);
        immediate : out std_logic_vector(31 downto 0)
    );
end entity immediate_generator;

architecture logic of immediate_generator is
    type operational_states is (normal);
	signal current_state, next_state : operational_states := normal;

    type instruction_cluster is (INVALID, R_type, I_type, S_type, SB_type, U_type, UJ_type);
	signal decoded_cluster : instruction_cluster;
    signal fetched_instruction : std_logic_vector (31 downto 0) := X"00000000";
    signal internal_immediate : std_logic_vector(31 downto 0) := X"00000000";
begin
    synchronism : process (clock, reset)
	begin
		if (reset = '1') then
			current_state <= normal;
		elsif rising_edge(clock) then
			current_state <= next_state;
		end if;
	end process;

    logic : process (fetched_instruction, decoded_cluster, current_state)
    begin
        case (current_state) is
            when normal =>
                case (fetched_instruction(6 downto 0)) is
                    when "0110011" =>
                        decoded_cluster <= R_type;
                    when "0000011" =>
                        decoded_cluster <= I_type;
                    when "0010011" =>
                        if (fetched_instruction = "00000000000000000000000000010011") then
                            decoded_cluster <= INVALID;
                        else
                            decoded_cluster <= I_type;
                        end if;
                    when "1100111" =>
                        decoded_cluster <= I_type;
                    when "0100011" =>
                        decoded_cluster <= S_type;
                    when "1100011" =>
                        decoded_cluster <= SB_type;
                    when "0110111" =>
                        decoded_cluster <= U_type;
                    when "1101111" =>
                        decoded_cluster <= UJ_type;
                    when others =>
                        decoded_cluster <= INVALID;
                end case;

                case (decoded_cluster) is
                    when INVALID =>
                        internal_immediate <= X"00000000";
                    when R_type =>
                        internal_immediate <= X"00000000";
                    when I_type =>
                        if fetched_instruction(31) = '1' then
                            internal_immediate <= std_logic_vector("11111111111111111111" & fetched_instruction(31 downto 20));
                        else
                            internal_immediate <= std_logic_vector("00000000000000000000" & fetched_instruction(31 downto 20));
                        end if;
                    when S_type =>
                        if fetched_instruction(31) = '1' then
                            internal_immediate <= std_logic_vector("11111111111111111111" & fetched_instruction(31 downto 25) & fetched_instruction(11 downto 7));
                        else
                            internal_immediate <= std_logic_vector("00000000000000000000" & fetched_instruction(31 downto 25) & fetched_instruction(11 downto 7));
                        end if;
                    when SB_type =>
                        if fetched_instruction(31) = '1' then
                            internal_immediate <= std_logic_vector("1111111111111111111" & fetched_instruction(31) & fetched_instruction(7) & fetched_instruction(30 downto 25) & fetched_instruction(11 downto 8) & '0');
                        else
                            internal_immediate <= std_logic_vector("0000000000000000000" & fetched_instruction(31) & fetched_instruction(7) & fetched_instruction(30 downto 25) & fetched_instruction(11 downto 8) & '0');
                        end if;
                    when UJ_type =>
                        if fetched_instruction(31) = '1' then
                            internal_immediate <= std_logic_vector("11111111111" & fetched_instruction(31) & fetched_instruction(19 downto 12) & fetched_instruction(20) & fetched_instruction(30 downto 21) & '0');
                        else
                            internal_immediate <= std_logic_vector("00000000000" & fetched_instruction(31) & fetched_instruction(19 downto 12) & fetched_instruction(20) & fetched_instruction(30 downto 21) & '0');
                        end if;
                    when U_type =>
                        if fetched_instruction(31) = '1' then
                            internal_immediate <= std_logic_vector(fetched_instruction(31 downto 12) & "000000000000");
                        else
                            internal_immediate <= std_logic_vector(fetched_instruction(31 downto 12) & "000000000000");
                        end if;
                    when others =>
                end case;
                next_state <= normal;
        end case;
    end process;

    immediate <= internal_immediate;
    fetched_instruction <= instruction;

end architecture logic;