library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Pkg_bubblesort_BC_Estado.all;

entity bubblesort_Testbench is
	generic(
		dataWidth: positive := 8;
		addressWidth: positive := 6;
		latencia: time := 10 ns
	);
	port (
		arraySize: in std_logic_vector(dataWidth-1 downto 0)
	);
end entity;

architecture testbench of bubblesort_Testbench is
	component bubblesort is
		generic(
			dataWidth: positive := 8;
			addressWidth: positive := 6
		);
		port(
			-- control inputs
			clk: in std_logic;
			reset_req: in std_logic;
			chipselect: in std_logic;
			readd: in std_logic;
			writee: in std_logic;
			-- data inputs
			address: in std_logic_vector(addressWidth-1 downto 0);
			writedata: in std_logic_vector(dataWidth-1 downto 0);
			arraySize: in std_logic_vector(dataWidth-1 downto 0);
			-- control outputs
			interrupt: out std_logic;
			-- data outputs
			readdata: out std_logic_vector(dataWidth-1 downto 0);
			testEstadoAtual: out Estado;
			testVetorMaisUm,
			testVetor: out std_logic_vector(dataWidth-1 downto 0)
		);
	end component;

	signal clk, reset_req, chipselect, readd, writee: std_logic;
	signal address: std_logic_vector(addressWidth-1 downto 0);
	signal writedata: std_logic_vector(dataWidth-1 downto 0);
	signal interrupt: std_logic;
	signal readdata: std_logic_vector(dataWidth-1 downto 0);

	signal testEstadoAtual: Estado;
	signal testVetorMaisUm, testVetor: std_logic_vector(dataWidth-1 downto 0);
begin
	uut: bubblesort
		generic map (dataWidth, addressWidth)
		port map (
			clk,
			reset_req,
			chipselect,
			readd,
			writee,
			address,
			writedata,
			arraySize,
			interrupt,
			readdata,
			testEstadoAtual,
			testVetorMaisUm,
			testVetor
		);
	
	setClock: process is
	begin
		clk <= '1';
		wait for latencia/2;
		clk <= '0';
		wait for latencia/2;
	end process;
	
	inputTestVector: process is
	begin
		reset_req <= '1';
		
		wait for latencia/2;
		
		reset_req <= '0';
		chipselect <= '0';
		writee <= '0';
		readd <= '0';
		address <= (others=>'Z');
		
		-- input vetor
		for i in to_integer(unsigned(arraySize)) downto 1 loop
			wait until interrupt='1';
			
			writedata <= std_logic_vector(to_unsigned((5-abs(i-5))*10, dataWidth));
			chipselect <= '1';
			writee <= '1';
			
			wait until interrupt='0';
			
			chipselect <= '0';
			writee <= '0';
			writedata <= (others=>'Z');
		end loop;
		
		-- le saidas
		for i in 1 to to_integer(unsigned(arraySize)) loop
			wait until interrupt='1';
			
			chipselect <= '1';
			readd <= '1';
			
			wait until interrupt='0';
			
			chipselect <= '0';
			readd <= '0';
		end loop;
		wait;
	end process;
end architecture;

