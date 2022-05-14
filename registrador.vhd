library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
	generic(
		width: positive := 8
	);
	port(
		-- control inputs
		clk, reset, load: in std_logic;
		-- data inputs
		datain: in std_logic_vector(width-1 downto 0);
		-- data outputs
		dataout: out std_logic_vector(width-1 downto 0)
	);
end entity;

architecture behavioural of registrador is
	subtype Estado is std_logic_vector(width-1 downto 0);
	signal estadoAtual, proximoEstado: Estado;
begin
	-- net-state logic
	proximoEstado <= datain when load='1' else estadoAtual 
		;--after 2.740 ns; -- :-( for gate-level simulation
	
	-- internal state
	process(clk, reset) is
	begin
		if reset='1' then
			estadoAtual <= (others=>'0');
		elsif rising_edge(clk) then
			estadoAtual <= proximoEstado;
		end if;
	end process;
	
	-- output logic(s)
	dataout <= estadoAtual;
end;