---------------------------------------------------------------------------------------------
--
--	Universit? de Sherbrooke 
--  D?partement de g?nie ?lectrique et g?nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Mathias Gagnon
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity registrevector is
    Port ( clk       : in  std_ulogic;
           reset     : in  std_ulogic;
           i_RS1     : in  std_ulogic_vector (4 downto 0);
           i_RS2     : in  std_ulogic_vector (4 downto 0);
           i_Wr_DAT  : in  std_ulogic_vector (127 downto 0);
           i_WDest   : in  std_ulogic_vector (4 downto 0);
           i_WE 	 : in  std_ulogic;
           o_RS1_DAT : out std_ulogic_vector (127 downto 0);
           o_RS2_DAT : out std_ulogic_vector (127 downto 0));
end registrevector;

architecture comport of registrevector is
    signal regs: RAMV(0 to 31) := (29 => X"100103F0100103F0100103F0100103F0", -- registre $SP jsp si on le garde, au pire on en prend moins
                                others => (others => '0'));
begin
    process( clk )
    begin
        if clk='1' and clk'event then
            if i_WE = '1' and reset = '0' and i_WDest /= "00000" then
                regs( to_integer( unsigned(i_WDest))) <= i_Wr_DAT;
            end if;
        end if;
    end process;
    
    o_RS1_DAT <= regs( to_integer(unsigned(i_RS1)));
    o_RS2_DAT <= regs( to_integer(unsigned(i_RS2)));
    
end comport;

