library ieee;
use ieee.std_logic_1164.all;
use work.Pkg_bubblesort_BC_Estado.all;

entity bloco_controle_bubblesort is
	port (
		-- control inputs
		clk,
		reset_req,
		chipselect,
		readd,
		writee: in std_logic;
		-- status from OperativeBlock
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
end entity;

architecture behaviouralFSM of bloco_controle_bubblesort is
	signal estadoAtual, proximoEstado: Estado;
begin
	testEstadoAtual <= estadoAtual;
	-- next-state logic
	process(estadoAtual, chipselect, readd, writee, sttIMenorSize, sttIMaisUmMenorSize, sttSwapped, sttCompVetor) is
	begin
		proximoEstado <= estadoAtual;
		
		case estadoAtual is
			-- 01: inicio do algoritmo                   -- 02
			when SL01 =>
				proximoEstado <= SL02;
			--     // recebe entradas
			-- 02: uint i = 0                            -- 03
			when SL02 =>
				proximoEstado <= SL03;
			-- 03: for (i < size, i++) {                 -- sttIMenorSize/04 ; !sttIMenorSize/06
			when SL03 =>
				if sttIMenorSize='1' then
					proximoEstado <= SL04;
				else
					proximoEstado <= SL06;
				end if;
			-- 04:    vetor[i] = input()                 -- 04a
			when SL04 =>
				if chipselect='1' and writee='1' then
					proximoEstado <= SL04a;
				end if;
			-- 04a:                                      -- 05
			when SL04a =>
				proximoEstado <= SL05;
			-- 05: }                                     -- 03
			when SL05 =>
				proximoEstado <= SL03;
			--     // processa
			-- 06: do {                                  -- 07
			when SL06 =>
				proximoEstado <= SL07;
			-- 07:    swapped = false                    -- 08
			--        i = 0
			when SL07 =>
				proximoEstado <= SL08;
			-- 08:    for (i < size - 1, i++) {          -- sttIMaisUmMenorSize/09 ; !sttIMaisUmMenorSize/12
			when SL08 =>
				if sttIMaisUmMenorSize='1' then
					proximoEstado <= SL09;
				else
					proximoEstado <= SL12;
				end if;
			-- 09:       (wait for RAM)                  -- 09a
			when SL09 =>
				proximoEstado <= SL09a;
			-- 09a:      if vetor[i + 1] < vetor[i] {    -- sttCompVetor/10 ; !sttCompVetor/11
			when SL09a =>
				if sttCompVetor='1' then
					proximoEstado <= SL10;
				else
					proximoEstado <= SL11;
				end if;
			-- 10:          swap(vetor[i], vetor[i + 1]) -- 11
			--              swapped = true
			--           }
			when SL10 =>
				proximoEstado <= SL11;
			-- 11:    }                                  -- 08
			when SL11 =>
				proximoEstado <= SL08;
			-- 12: } while swapped                       -- sttSwapped/06 ; !sttSwapped/13
			when SL12 =>
				if sttSwapped='1' then
					proximoEstado <= SL06;
				else
					proximoEstado <= SL13;
				end if;
			-- 13: i = 0                                 -- 14
			when SL13 =>
				proximoEstado <= SL14;
			-- 14: for (i < size, i++) {                 -- sttIMenorSize/15 ; sttIMenorSize/17
			when SL14 =>
				if sttIMenorSize='1' then
					proximoEstado <= SL15;
				else
					proximoEstado <= SL17;
				end if;
			-- 15:    output(vetor[i])                   -- output_read/15a
			when SL15 =>
				if chipselect='1' and readd='1' then
					proximoEstado <= SL15a;
				end if;
			-- 15a:                                      -- 16
			when SL15a =>
				proximoEstado <= SL16;
			-- 16: }                                     -- 14
			when SL16 =>
				proximoEstado <= SL14;
			-- 17: fim do algoritmo                      -- 01
			when SL17 =>
				proximoEstado <= SL01;
		end case;
	end process;
	
	process(clk, reset_req) is
	begin
		if reset_req='1' then
			estadoAtual <= SL01;
		elsif rising_edge(clk) then
			estadoAtual <= proximoEstado;
		end if;
	end process;
	
	-- output logic(s)
	process(estadoAtual) is
	begin
		cmdResetI <= '0';
		cmdSetI <= '0';
		cmdResetSwapped <= '0';
		cmdSetSwapped <= '0';
		cmdSwap <= '0';
		cmdSetVetorI <= '0';
		cmdOutputVetorI <= '0';
		interrupt <= '0';
		
		case estadoAtual is
			-- 01: inicio do algoritmo                  
			--     // recebe entradas
			-- 02: uint i = 0                            -- cmdResetI
			when SL02 =>
				cmdResetI <= '1';
			-- 03: for (i < size, i++) {                
			-- 04:    vetor[i] = input()                 -- interrupt
			when SL04 =>
				interrupt <= '1';
			-- 04a:                                      -- cmdSetVetorI ; cmdSwap=0
			when SL04a =>
				interrupt <= '1';
				cmdSetVetorI <= '1';
			-- 05: }                                     -- cmdSetI
			when SL05 =>
				cmdSetI <= '1';
			--     // processa
			-- 06: do {                                  
			-- 07:    swapped = false                    -- cmdResetSwapped
			--        i = 0                              -- cmdResetI
			when SL07 =>
				cmdResetSwapped <= '1';
				cmdResetI <= '1';
			-- 08:    for (i < size - 1, i++) {         
			-- 09:       (wait for RAM)                  
			-- 09a:      if vetor[i + 1] < vetor[i] {    
			-- 10:          swap(vetor[i], vetor[i + 1]) -- cmdSetVetorI ; cmdSwap=1
			--              swapped = true               -- cmdSetSwapped
			--           }
			when SL10 =>
				cmdSetVetorI <= '1';
				cmdSwap <= '1';
				cmdSetSwapped <= '1';
			-- 11:    }                                  -- cmdSetI                     
			when SL11 =>
				cmdSetI <= '1';
			-- 12: } while swapped                      
			-- 13: i = 0                                 -- cmdResetI
			when SL13 =>
				cmdResetI <= '1';
			-- 14: for (i < size, i++) {                 
			-- 15:    output(vetor[i])                   -- interrupt
			when SL15 =>
				interrupt <= '1';
			-- 15a:                                      -- cmdOutputVetorI
			when SL15a =>
				cmdOutputVetorI <= '1';
			-- 16: }                                     -- cmdSetI
			when SL16 =>
				cmdSetI <= '1';
			-- 17: fim do algoritmo  
			when others =>
				null;
		end case;
	end process;
end architecture;