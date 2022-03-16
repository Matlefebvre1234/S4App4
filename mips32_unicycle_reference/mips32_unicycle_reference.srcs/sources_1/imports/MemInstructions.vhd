---------------------------------------------------------------------------------------------
--
--	Universit� de Sherbrooke 
--  D�partement de g�nie �lectrique et g�nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr� T�trault
--					Daniel Dalle
--					S�bastien Roy
-- 
---------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all; -- requis pour la fonction "to_integer"
use work.MIPS32_package.all;

entity MemInstructions is
Port ( 
    i_addresse 		: in std_ulogic_vector (31 downto 0);
    o_instruction 	: out std_ulogic_vector (31 downto 0)
);
end MemInstructions;

architecture Behavioral of MemInstructions is
    signal ram_Instructions : RAM(0 to 255) := (
------------------------
-- Ins�rez votre code ici
------------------------
--  TestMirroir
X"34240000",
X"3c011001",
X"34250040",
X"3c011001",
X"34260050",
X"0c10001b",
X"2002000a",
X"0000000c",
X"3c011001",
X"8c2f0060",
X"00004820",
X"112f000d",
X"20010004",
X"71214002",
X"21290001",
X"01045020",
X"01055820",
X"B14A0000", 
X"8d6b0000", 
X"BD4B6020", 
X"B0CD0000", 
X"FD8D702A", 
X"C1CC680B", 
X"B4CD0000", 
X"0810000c",
X"03e00008",
X"23bdfffc",
X"afbf0000",
X"200800fa",
X"BD004820", 
X"00065020",
X"B5490000", 
X"23bdfff4",
X"afa40008",
X"afa50004",
X"afa60000",
X"34010000",
X"01413020",
X"0c100009",
X"8fa60000",
X"8fa50004",
X"8fa40008",
X"23bd000c",
X"8fbf0000",
X"23bd0004",
X"03e00008",




------------------------
-- Fin de votre code
------------------------
    others => X"00000000"); --> SLL $zero, $zero, 0  

    signal s_MemoryIndex : integer range 0 to 255;

begin
    -- Conserver seulement l'indexage des mots de 32-bit/4 octets
    s_MemoryIndex <= to_integer(unsigned(i_addresse(9 downto 2)));

    -- Si PC vaut moins de 127, pr�senter l'instruction en m�moire
    o_instruction <= ram_Instructions(s_MemoryIndex) when i_addresse(31 downto 10) = (X"00400" & "00")
                    -- Sinon, retourner l'instruction nop X"00000000": --> AND $zero, $zero, $zero  
                    else (others => '0');

end Behavioral;

