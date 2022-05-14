library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparaIgual is
	port(
		inp0, inp1: in std_logic;
		ehIgual: out std_logic
	);
end entity;

architecture behavioural of comparaIgual is
begin
	ehIgual <= '1' when inp0 = inp1 else '0';
end;