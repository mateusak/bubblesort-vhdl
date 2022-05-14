library ieee;
use ieee.std_logic_1164.all;

	-- 01: inicio do algoritmo               
	--     // recebe entradas
	-- 02: uint i = 0                            
	-- 03: for (i < size, i++) {               
	-- 04:    vetor[i] = input()               
	-- 04a:                                     
	-- 05: }                                    
	--     // processa
	-- 06: do {                                
	-- 07:    swapped = false                   
	--        i = 0
	-- 08:    for (i < size - 1, i++) {         
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

package Pkg_bubblesort_BC_Estado is
	type Estado is (
		SL01, SL02, SL03, SL04, SL04a, SL05, SL06,
		SL07, SL08, SL09, SL09a, SL10, SL11, SL12, 
		SL13, SL14, SL15, SL15a, SL16, SL17
	);
end package;