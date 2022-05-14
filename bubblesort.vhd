library ieee;
use ieee.std_logic_1164.all;
use work.Pkg_bubblesort_BC_Estado.all;

-- DESCRICÂO:
	-- Sistema digital que lê um vetor de N posições (N é um parâmetro genérico) e 
	-- retorne-o ordenado em ordem crescente, utilizando o algoritmo da bolha.

-- ALGORITMO:
-- inicio do algoritmo               
	-- // recebe entradas
	-- uint i = 0                            
	-- for (i < size, i++) {               
	--    vetor[i] = input()               
	--                                      
	-- }                                    
	-- // processa
	-- do {                                
	--    bool swapped = false               
	--    i = 0
	--    for (i + 1 < size, i++) {         
	--       (wait for RAM)                 
	--       if vetor[i + 1] < vetor[i] {   
	--          swap(vetor[i], vetor[i + 1]) 
	--          swapped = true
	--       }
	--    }                                
	-- } while swapped                     
	-- i = 0                                 
	-- for (i < size, i++) {               
	--    output(vetor[i])                  
	--                                       
	-- }                                     
-- fim do algoritmo      
	
-- VARIAVEIS:
	-- uint i
	-- bool swapped

-- OPERACOES e COMANDOS/STATUS EQUIVALENTES (==>)
	-- COMANDOS:
		-- i = 0                        ==> cmdResetI
		-- i++                          ==> cmdSetI
		-- swapped = false              ==> cmdResetSwapped
		-- swapped = true               ==> cmdSetSwapped
		-- vetor[i] = input()           ==> cmdSetVetorI ; cmdSwap=0
		-- swap(vetor[i], vetor[i + 1]) ==> cmdSetVetorI ; cmdSwap=1
		-- output(vetor[i])             ==> cmdOutputVetorI

	-- STATUS:
		-- i < size                ==> sttIMenorSize
		-- i + 1 < size            ==> sttIMaisUmMenorSize
		-- vetor[i + 1] < vetor[i] ==> sttCompVetor
		-- swapped == true         ==> sttSwapped

-- FSMD DO BLOCO DE CONTROLE
	-- 01: inicio do algoritmo               
	--     // recebe entradas
	-- 02: uint i = 0                            
	-- 03: for (i < size, i++) {               
	-- 04:    vetor[i] = input()               
	-- 04a:                                     
	-- 05: }                                    
	--     // processa
	-- 06: do {                                
	-- 07:    bool swapped = false             
	--        i = 0
	-- 08:    for (i + 1 < size, i++) {         
	-- 09:       (wait for RAM)                 
	-- 09a:      if vetor[i + 1] < vetor[i] {   
	-- 10:          swap(vetor[i], vetor[i + 1]) 
	--              swapped = true
	--           }
	-- 11:    }                                
	-- 12: } while swapped                     
	-- 13: i = 0                                 
	-- 14: for (i < size, i++) {               
	-- 15:    output(vetor[i])                  
	-- 15a:                                      
	-- 16: }                                     
	-- 17: fim do algoritmo                     
	
-- BLOCO OPERATIVO:
	-- CIRCUITOS COMBINACIONAIS:
		-- Comparador Menor: i < size                               ==> sttIMenorSize
		-- Comparador Menor: vetor[i + 1] < vetor[i]                ==> sttCompVetor
		-- Comparador Igual: swapped == true                        ==> sttSwapped
		-- Incrementador:    i++                                    ==> cmdSetI
		-- Multiplexador:    vetor[i] = [0:input(); 1:vetor[i + 1]] ==> cmdSwap
	
	-- CIRCUITOS SEQUENCIAIS:
		-- Registrador (reset): i = 0
		-- Registrador (reset): swapped = false
		-- Registrador (carga): swapped = true
		-- MemoriaRAM
			-- (write):          vetor[i] = input()
			-- (write):          swap(vetor[i], vetor[i + 1])
			-- (read):           vetor[i + 1] < vetor[i]
			-- (read):           output(vetor[i])
	
-- DIAGRAMA DE TRANSICAO DE ESTADOS DO BLOCO DE CONTROLE
	-- 01: inicio do algoritmo                   -- 02
	--     // recebe entradas
	-- 02: uint i = 0                            -- 03
	-- 03: for (i < size, i++) {                 -- sttIMenorSize/04 ; !sttIMenorSize/06
	-- 04:    vetor[i] = input()                 -- 04a
	-- 04a:                                      -- 05
	-- 05: }                                     -- 03
	--     // processa
	-- 06: do {                                  -- 07
	-- 07:    bool swapped = false               -- 08
	--        i = 0
	-- 08:    for (i + 1 < size, i++) {          -- sttIMenorSize/09 ; !sttIMenorSize/12
	-- 09:       (wait for RAM)                  -- 09a
	-- 09a:      if vetor[i + 1] < vetor[i] {    -- sttCompVetor/10 ; !sttCompVetor/11
	-- 10:          swap(vetor[i], vetor[i + 1]) -- 11
	--              swapped = true
	--           }
	-- 11:    }                                  -- 08
	-- 12: } while swapped                       -- sttSwapped/06 ; !sttSwapped/13
	-- 13: i = 0                                 -- 14
	-- 14: for (i < size, i++) {                 -- sttIMenorSize/15 ; sttIMenorSize/17
	-- 15:    output(vetor[i])                   -- output_read/15a
	-- 15a:                                      -- 16
	-- 16: }                                     -- 14
	-- 17: fim do algoritmo                      -- 01

-- DIAGRAMA DE SAIDAS DO BLOCO DE CONTROLE
	-- 01: inicio do algoritmo                  
	--     // recebe entradas
	-- 02: uint i = 0                            -- cmdResetI
	-- 03: for (i < size, i++) {                
	-- 04:    vetor[i] = input()                 -- interrupt
	-- 04a:                                      -- cmdSetVetorI ; cmdSwap=0
	-- 05: }                                     -- cmdSetI
	--     // processa
	-- 06: do {                                  
	-- 07:    bool swapped = false               -- cmdResetSwapped
	--        i = 0                              -- cmdResetI
	-- 08:    for (i + 1 < size, i++) {         
	-- 09:       (wait for RAM)                  
	-- 09a:      if vetor[i + 1] < vetor[i] {    
	-- 10:          swap(vetor[i], vetor[i + 1]) -- cmdSetVetorI ; cmdSwap=1
	--              swapped = true               -- cmdSetSwapped
	--           }
	-- 11:    }                                  -- cmdSetI                
	-- 12: } while swapped                      
	-- 13: i = 0                                 -- cmdResetI
	-- 14: for (i < size, i++) {                 
	-- 15:    output(vetor[i])                   -- interrupt
	-- 15a:                                      -- cmdOutputVetorI
	-- 16: }                                     -- cmdSetI
	-- 17: fim do algoritmo                                   

entity bubblesort is
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
end entity;

architecture structural of bubblesort is
	component bloco_controle_bubblesort is
		port(
			-- control inputs
			clk,
			reset_req,
			chipselect,
			readd,
			writee: in std_logic;
			-- status from OperativeBlock
			signal
				sttIMenorSize,
				sttIMaisUmMenorSize,
				sttCompVetor,
				sttSwapped: in std_logic;
			-- control outputs
			interrupt: out std_logic;
			-- commands to OperativeBlock
			cmdResetI,
			cmdSetI,
			cmdResetSwapped,
			cmdSetSwapped,
			cmdSwap,
			cmdSetVetorI,
			cmdOutputVetorI: out std_logic;
			testEstadoAtual: out Estado
		);
	end component;
	
	component bloco_operativo_bubblesort is
		generic(
			dataWidth: positive := 8;
			addressWidth: positive := 6
		);
		port(
			-- control inputs
			clk,
			reset_req: in std_logic;
			-- data inputs
			address	: in std_logic_vector(addressWidth-1 downto 0);
			writedata: in std_logic_vector(dataWidth-1 downto 0);
			arraySize: in std_logic_vector(dataWidth-1 downto 0);
			-- data outputs
			readdata	: out std_logic_vector(dataWidth-1 downto 0);
			-- commands from OperativeBlock
			signal
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
	end component;

	-- comandos
	signal
		cmdResetI,
		cmdSetI,
		cmdResetSwapped,
		cmdSetSwapped,
		cmdSwap,
		cmdSetVetorI,
		cmdOutputVetorI: std_logic;

	-- status
	signal
		sttIMenorSize,
		sttIMaisUmMenorSize,
		sttCompVetor,
		sttSwapped: std_logic;
begin
	blocoControle: bloco_controle_bubblesort 
		port map (
			clk,
			reset_req,
			chipselect,
			readd,
			writee,
			sttIMenorSize,
			sttIMaisUmMenorSize,
			sttCompVetor,
			sttSwapped,
			interrupt,
			cmdResetI,
			cmdSetI,
			cmdResetSwapped,
			cmdSetSwapped,
			cmdSwap,
			cmdSetVetorI,
			cmdOutputVetorI,
			testEstadoAtual
		);

	blocoOperativo: bloco_operativo_bubblesort
		generic map (dataWidth, addressWidth) 
		port map (
			clk, 
			reset_req,
			address, 
			writedata,
			arraySize,
			readdata,
			cmdResetI,
			cmdSetI,
			cmdResetSwapped,
			cmdSetSwapped,
			cmdSwap,
			cmdSetVetorI,
			cmdOutputVetorI,
			sttIMenorSize,
			sttIMaisUmMenorSize,
			sttCompVetor,
			sttSwapped,
			testVetorMaisUm,
			testVetor
		);
end architecture;