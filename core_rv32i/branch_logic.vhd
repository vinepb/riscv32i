library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity branch_logic is
	port (
		input_0, input_1 : in std_logic_vector(31 downto 0);
        branch :in std_logic;
		branch_control : in std_logic_vector(2 downto 0);
		branch_response : out std_logic
	);
end entity branch_logic;

architecture logic of branch_logic is
	signal result_temp : std_logic_vector(32 downto 0) := "000000000000000000000000000000000";

begin
	process (input_0, input_1, result_temp, branch, branch_control) is
	begin
		result_temp <= "000000000000000000000000000000000";
        if (branch = '1') then
            case branch_control is
                when "000" => --BEQ (branch if equal)
                    result_temp <= std_logic_vector(signed(input_0(31) & input_0) - signed(input_1(31) & input_1));
                    if (result_temp = "000000000000000000000000000000000") then
                        branch_response <= '1';
                    else
                        branch_response <= '0';
                    end if;

                when "001" => --BNE (branch not equal)
                    result_temp <= std_logic_vector(signed(input_0(31) & input_0) - signed(input_1(31) & input_1));
                    if (result_temp = "000000000000000000000000000000000") then
                        branch_response <= '0';
                    else
                        branch_response <= '1';
                    end if;

                when "100" => --BLT (branch less than)
                    result_temp <= std_logic_vector(signed(input_0(31) & input_0) - signed(input_1(31) & input_1));
                    if (result_temp(32) = '1') then
                        branch_response <= '1';
                    else
                        branch_response <= '0';
                    end if;

                when "101" => --BGE (branch greater than equal)
                    result_temp <= std_logic_vector(signed(input_0(31) & input_0) - signed(input_1(31) & input_1));
                    if (result_temp(32) = '0') then
                        branch_response <= '1';
                    else
                        branch_response <= '0';
                    end if;

                when others =>
                    branch_response <= '0';
            end case;
        else
            branch_response <= '0';
        end if;
	end process;
end architecture logic;