library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador1 is
	port(
		-- control inputs
		clk, reset, load: in std_logic;
		-- data inputs
		datain: in std_logic;
		-- data outputs
		dataout: out std_logic
	);
end entity;

architecture behavioural of registrador1 is
begin
	process(clk, reset)
	begin
		if reset = '1' then
			dataout <= '0';
		elsif rising_edge(clk) then
			if load = '1' then
				dataout <= datain;
			end if;
		end if;
	end process;
end;