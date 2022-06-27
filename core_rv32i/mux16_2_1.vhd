library ieee;
use ieee.std_logic_1164.all;

entity mux16_2_1 is
	port (
		selection : in std_logic;
		input_0, input_1 : in std_logic_vector(15 downto 0);
		output_0 : out std_logic_vector(15 downto 0)
	);
end mux16_2_1;

architecture behavioral of mux16_2_1 is
begin
	with selection select
		output_0 <=
		input_0 when '0',
		input_1 when '1',
		"0000000000000000" when others;
end behavioral;