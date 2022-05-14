library ieee;
use ieee.std_logic_1164.all;

entity bloco_operativo_bubblesort is
	generic (
		dataWidth: positive := 8;
		addressWidth: positive := 6
	);
	port (
		-- control inputs
		clk		: in std_logic;
		reset_req: in std_logic;
		-- data inputs
		address	: in std_logic_vector(addressWidth-1 downto 0);
		writedata: in std_logic_vector(dataWidth-1 downto 0);
		arraySize: in std_logic_vector(dataWidth-1 downto 0);
		-- data outputs
		readdata	: out std_logic_vector(dataWidth-1 downto 0);
		-- commands from OperativeBlock
		cmdResetI,
		cmdSetI,
		cmdResetSwapped,
		cmdSetSwapped,
		cmdSwap,
		cmdSetVetorI,
		cmdOutputVetorI: in std_logic;
		-- status to OperativeBlock
		sttIMenorSize,
		sttIMaisUmMenorSize,
		sttCompVetor,
		sttSwapped: out std_logic;
		testVetorMaisUm,
		testVetor: out std_logic_vector(dataWidth-1 downto 0)
	);
end entity;

architecture structuralDatapath of bloco_operativo_bubblesort is
	component  multiplexador2 is
		generic(
			width: positive := 8
		);
		port(
			inp0, inp1: in std_logic_vector(width-1 downto 0);
			sel: in std_logic;
			outp: out std_logic_vector(width-1 downto 0)
		);
	end component;
	
	component comparaMenor is
		generic(
			width: positive := 8;
			isSigned: boolean := true
		);
		port(
			inp0, inp1: in std_logic_vector(width-1 downto 0);
			ehMenor: out std_logic
		);
	end component;
	
	component comparaIgual is
		port(
			inp0, inp1: in std_logic;
			ehIgual: out std_logic
		);
	end component;

	component registrador is
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
	end component;
	
	component registrador1 is
		port(
			-- control inputs
			clk, reset, load: in std_logic;
			-- data inputs
			datain: in std_logic;
			-- data outputs
			dataout: out std_logic
		);
	end component;
	
	component incrementador is
		generic(
			width: positive := 8;
			isSigned: boolean := true
		);
		port(
			inp: in std_logic_vector(width-1 downto 0);
			outp: out std_logic_vector(width-1 downto 0)
		);
	end component;
	
	component memoriaRAM is
		generic(
			dataWidth: positive := 8;
			addressWidth: positive := 8
		);
		port(
			address_a: in std_logic_vector (addressWidth-1 downto 0);
			address_b: in std_logic_vector (addressWidth-1 downto 0);
			clock: in std_logic  := '1';
			data_a: in std_logic_vector (dataWidth-1 downto 0);
			data_b: in std_logic_vector (dataWidth-1 downto 0);
			wren_a: in std_logic  := '0';
			wren_b: in std_logic  := '0';
			q_a: out std_logic_vector (dataWidth-1 downto 0);
			q_b: out std_logic_vector (dataWidth-1 downto 0)
		);
	end component;

	signal regI_out, incI_out, vetorI, vetorIPlusOne, muxVetorI_out, swapI_out0, swapI_out1: std_logic_vector(dataWidth-1 downto 0);
	signal regSwapped_out: std_logic;
begin
	testVetorMaisUm <= vetorIPlusOne;
	testVetor <= vetorI;

-- OPERACOES e COMANDOS/STATUS EQUIVALENTES (==>)
	-- i = 0                   ==> cmdResetI
	-- i++                     ==> cmdSetI
	RegI: registrador
		generic map (dataWidth)
		port map (clk=>clk, reset=>cmdResetI, load=>cmdSetI, datain=>incI_out, dataout=>regI_out);
	
	IncI: incrementador
		generic map (dataWidth, true)
		port map (regI_out, incI_out);
	
	-- swapped = false         ==> cmdResetSwapped
	-- swapped = true          ==> cmdSetSwapped
	RegSwapped: registrador1
		port map (clk=>clk, reset=>cmdResetSwapped, load=>cmdSetSwapped, datain=>'1', dataout=>regSwapped_out);
	
	-- vetor[i] = input()           ==> cmdSetVetorI ; cmdSwap=0
	-- swap(vetor[i], vetor[i + 1]) ==> cmdSetVetorI ; cmdSwap=1
	MuxVetorI: multiplexador2
		generic map (dataWidth)
		port map (inp0=>writedata, inp1=>vetorIPlusOne, sel=>cmdSwap, outp=>muxVetorI_out);
	
	RAM: memoriaRAM
		generic map (dataWidth, addressWidth)
		port map (
			address_a=>regI_out(addressWidth-1 downto 0),
			address_b=>incI_out(addressWidth-1 downto 0),
			clock=>clk,
			data_a=>muxVetorI_out,
			data_b=>vetorI,
			wren_a=>cmdSetVetorI,
			wren_b=>cmdSwap,
			q_a=>vetorI,
			q_b=>vetorIPlusOne
		);

	-- i < size                ==> sttIMenorSize
	CompISize: comparaMenor
		generic map (dataWidth, true) 
		port map (regI_out, arraySize, sttIMenorSize);
		
	-- i + 1 < size
	CompIMaisUmsize: comparaMenor
		generic map (dataWidth, true)
		port map (incI_out, arraySize, sttIMaisUmMenorSize);
	
	-- vetor[i + 1] < vetor[i] ==> sttCompVetor
	CompVetor: comparaMenor
		generic map (dataWidth, true)
		port map (vetorIPlusOne, vetorI, sttCompVetor);
	
	-- swapped == true         ==> sttSwapped
	CompSwapped: comparaIgual
		port map (regSwapped_out, '1', sttSwapped);
	
	-- output(vetor[i])        ==> cmdOutputVetorI
	MuxOutput: multiplexador2
		generic map (dataWidth)
		port map (inp0=>(others=>'Z'), inp1=>vetorI, sel=>cmdOutputVetorI, outp=>readdata);
end architecture;