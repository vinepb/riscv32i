library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use work.all;

entity core_rv32i_tb is
end entity core_rv32i_tb;

architecture testbench1 of core_rv32i_tb is
	component core_rv32i
		port (
			clock : in std_logic;
			reset : in std_logic;
			debug_instruction : out std_logic_vector(31 downto 0)
		);
	end component core_rv32i;
	
    signal internal_clock : std_logic;
    signal internal_reset : std_logic;
begin
    core : core_rv32i port map(internal_clock, internal_reset);

    clock_process : process
	begin
		internal_clock <= '0';
		wait for 25 ns;
		internal_clock <= '1';
		wait for 25 ns;
	end process clock_process;

    internal_reset <= '1', '0' after 20 ns;
end architecture;