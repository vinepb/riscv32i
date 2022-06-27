library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity forwarding_unit is
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
end entity forwarding_unit;

architecture logic of forwarding_unit is
	signal internal_forwardA_out : std_logic_vector(1 downto 0) := "00";
	signal internal_forwardB_out : std_logic_vector(1 downto 0) := "00";
begin
	forwardA : process(register_source_address_1_ID_EX, register_destination_address_EX_MEM, register_destination_address_MEM_WB, mem_to_reg_EX_MEM, mem_to_reg_MEM_WB)
	begin
		if (register_source_address_1_ID_EX = register_destination_address_MEM_WB) and (register_destination_address_MEM_WB /= "00000") then
			internal_forwardA_out <= "01";

		elsif (mem_to_reg_EX_MEM = "00") and (register_source_address_1_ID_EX = register_destination_address_EX_MEM) and (register_destination_address_EX_MEM /= "00000") then
			internal_forwardA_out <= "10";

		elsif (mem_to_reg_EX_MEM = "01") and (register_source_address_1_ID_EX = register_destination_address_EX_MEM) and (register_destination_address_EX_MEM /= "00000") then
			internal_forwardA_out <= "11";

		else
			internal_forwardA_out <= "00";
			
		end if;
	end process;

	forwardB : process(register_source_address_2_ID_EX, register_destination_address_EX_MEM, register_destination_address_MEM_WB, mem_to_reg_EX_MEM, mem_to_reg_MEM_WB)
	begin
		if (register_source_address_2_ID_EX = register_destination_address_MEM_WB) and (register_destination_address_MEM_WB /= "00000") then
			internal_forwardB_out <= "01";

		elsif (mem_to_reg_EX_MEM = "00") and (register_source_address_2_ID_EX = register_destination_address_EX_MEM) and (register_destination_address_EX_MEM /= "00000") then
			internal_forwardB_out <= "10";

		elsif (mem_to_reg_EX_MEM = "01") and (register_source_address_2_ID_EX = register_destination_address_EX_MEM) and (register_destination_address_EX_MEM /= "00000") then
			internal_forwardB_out <= "11";

		else
			internal_forwardB_out <= "00";

		end if;
	end process;

	forwardA_out <= internal_forwardA_out;
	forwardB_out <= internal_forwardB_out;
end architecture logic;