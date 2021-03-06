---------------------------------------------------------------------------------------------
--
--	Universit? de Sherbrooke 
--  D?partement de g?nie ?lectrique et g?nie informatique
--
--	S4i - APP4 
--	
--
--	Auteur: 		Marc-Andr? T?trault
--					Daniel Dalle
--					S?bastien Roy
-- 
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;

entity controleur is
Port (
    i_Op          	: in std_ulogic_vector(5 downto 0);
    i_funct_field 	: in std_ulogic_vector(5 downto 0);
    
    o_RegDst    	: out std_ulogic;
    o_Branch    	: out std_ulogic;
    o_MemtoReg  	: out std_ulogic;
    o_MemtoRegV  	: out std_ulogic;
    o_AluFunct  	: out std_ulogic_vector (3 downto 0);
    o_MemRead   	: out std_ulogic;
    o_MemWrite  	: out std_ulogic;
    o_MemReadWide  	: out std_ulogic;
    o_MemWriteWide 	: out std_ulogic;
    o_ALUSrc    	: out std_ulogic;
    o_RegWrite  	: out std_ulogic;
    o_RegWriteV  	: out std_ulogic;
	
	-- Sorties supp. vs 4.17
    o_Jump 			: out std_ulogic;
	o_jump_register : out std_ulogic;
	o_jump_link 	: out std_ulogic;
	o_SignExtend 	: out std_ulogic;
	
	--addv
	o_ControleMuxAddvs : out std_logic;
	o_ControleMuxSltv : out std_logic
    );
end controleur;

architecture Behavioral of controleur is

    signal s_R_funct_decode   : std_ulogic_vector(3 downto 0);

begin

    -- Contr?les pour les diff?rents types d'instructions
    -- 
    process( i_Op, s_R_funct_decode )
    begin
        
        case i_Op is
			-- pour tous les types R
            when OP_Rtype => 
                o_AluFunct <= s_R_funct_decode;
			when OP_ADDI => 
				o_AluFunct <= ALU_ADD;
			when OP_ORI => 
				o_AluFunct <= ALU_OR;
			when OP_LUI => 
				o_AluFunct <= ALU_SLL16;
			when OP_BEQ => 
				o_AluFunct <= ALU_SUB;
			when OP_JAL =>
				o_AluFunct <= ALU_NULL;
			when OP_SW => 
				o_AluFunct <= ALU_ADD;
			when OP_LW => 
				o_AluFunct <= ALU_ADD;
            -- when OP_??? =>   -- autres cas?
			-- sinon
			when OP_ADDVS =>
			o_AluFunct <= ALU_ADD;
			when OP_SLTV =>
			o_AluFunct <=  ALU_SLT;
			when OP_LWV =>
			o_AluFunct <= ALU_ADD;
			when OP_SWV =>
			o_AluFunct <= ALU_ADD;
            when others =>
				o_AluFunct <= (others => '0');
        end case;
    end process; 
    
    -- Commande ? l'ALU pour les instructions "R"
    process(i_funct_field)
    begin
        case i_funct_field is
            when ALUF_AND => 
                s_R_funct_decode <= ALU_AND;
            when ALUF_OR => 
                s_R_funct_decode <= ALU_OR;
            when ALUF_NOR =>
                s_R_funct_decode <= ALU_NOR;
            when ALUF_ADD => 
                s_R_funct_decode <= ALU_ADD;
            when ALUF_SUB => 
                s_R_funct_decode <= ALU_SUB;                
            when ALUF_SLL => 
                s_R_funct_decode <= ALU_SLL;  
            when ALUF_SRL => 
                s_R_funct_decode <= ALU_SRL; 
            when ALUF_ADDU => 
                s_R_funct_decode <= ALU_ADD;
            when ALUF_SLT => 
                s_R_funct_decode <= ALU_SLT; 
            when ALUF_SLTU => 
                s_R_funct_decode <= ALU_SLTU; 
            when others =>
                s_R_funct_decode <= ALU_NULL;
         end case;
     end process;
	
	o_ControleMuxAddvs <= '1' when i_Op = OP_ADDVS or i_Op = OP_SLTV
	 else '0';
	 
	o_ControleMuxSltv <= '1' when i_Op = OP_SLTV else '0';
	o_RegWrite		<= '1' when i_Op = OP_Rtype or 
								i_Op = OP_ADDI or 
								i_Op = OP_ORI or 
								i_Op = OP_LUI or 
								i_Op = OP_LW or 
								i_Op = OP_JAL
						else '0';
						
    o_RegWriteV     <= '1' when i_Op = OP_LWV or
                                i_Op = OP_ADDVS or 
                                i_Op = OP_SLTV
                        else '0';
	
	o_RegDst 		<= '1' when i_Op = OP_Rtype or
	                            i_Op = OP_ADDVS or
	                             i_Op = OP_SLTV
	                                else '0';
	                            
	
	o_ALUSrc 		<= '0' when i_Op = OP_Rtype or
								i_Op = OP_BEQ or 
								i_Op = OP_ADDVS or
								i_Op = OP_SLTV
						else '1';
	o_Branch 		<= '1' when i_Op = OP_BEQ   else '0';
	o_MemRead 		<= '1' when i_Op = OP_LW else '0';
	o_MemWrite 		<= '1' when i_Op = OP_SW else '0';
	o_MemReadWide 	<= '1' when i_Op = OP_LWV else '0';
	o_MemWriteWide	<= '1' when i_Op = OP_SWV else '0';
	o_MemtoReg 		<= '1' when i_Op = OP_LW else '0';
	o_MemtoRegV     <= '1' when i_Op = OP_LWV else '0';
	o_SignExtend	<= '1' when i_OP = OP_ADDI or
	                           i_OP = OP_BEQ 
	                     else '0';
	
	
	o_Jump	 		<= '1' when i_Op = OP_J or 
	                            i_Op = OP_JAL 
						else '0';
				
				
	o_jump_link 	<= '1' when i_Op = OP_JAL else '0';
	o_jump_register <= '1' when i_Op = OP_Rtype and 
								i_funct_field = ALUF_JR 
						else '0';

end Behavioral;
