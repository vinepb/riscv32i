library ieee;
use ieee.std_logic_1164.all;

entity delay_driver is
	port (
		reg_in : in std_logic;
		load, clock, clear : in std_logic;
		reg_out : out std_logic
	);
end delay_driver;

architecture description of delay_driver is
	signal internal_value : std_logic := '0';
begin
	process (clock, clear, load, internal_value)
	begin
		if (clear = '1') then
			internal_value <= '0';
		elsif (clock = '1') then
			if (load = '1') then
				internal_value <= reg_in;
			else
				internal_value <= internal_value;
			end if;
		elsif (clock = '0') then
			internal_value <= '0';
		end if;
		reg_out <= internal_value;
	end process;
end description;