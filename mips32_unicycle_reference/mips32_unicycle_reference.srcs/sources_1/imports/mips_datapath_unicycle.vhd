---------------------------------------------------------------------------------------------
--
--	Université de Sherbrooke 
--  Département de génie électrique et génie informatique
--
--	S4i - APP4 
--	
--
--	Auteurs: 		Marc-André Tétrault
--					Daniel Dalle
--					Sébastien Roy
-- 
---------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS32_package.all;


entity mips_datapath_unicycle is
Port ( 
	clk 			: in std_ulogic;
	reset 			: in std_ulogic;

	i_alu_funct   	: in std_ulogic_vector(3 downto 0);
	i_RegWrite    	: in std_ulogic;
	i_RegWriteV    	: in std_ulogic;
	i_RegDst      	: in std_ulogic;
	i_MemtoReg    	: in std_ulogic;
	i_MemtoRegV    	: in std_ulogic;
	i_branch      	: in std_ulogic;
	i_ALUSrc      	: in std_ulogic;
	i_MemRead 		: in std_ulogic;
	i_MemWrite	  	: in std_ulogic;
	i_MemReadWide 	: in std_ulogic;
	i_MemWriteWide	: in std_ulogic;
    
	i_jump   	  	: in std_ulogic;
	i_jump_register : in std_ulogic;
	i_jump_link   	: in std_ulogic;
	i_SignExtend 	: in std_ulogic;
    i_ControleMuxAddvs : in std_logic;
    i_ControleMuxSltv : in std_logic;
	o_Instruction 	: out std_ulogic_vector (31 downto 0);
	o_PC		 	: out std_ulogic_vector (31 downto 0)
	
	
	--addvs
	
);
end mips_datapath_unicycle;

architecture Behavioral of mips_datapath_unicycle is


component MemInstructions is
    Port ( i_addresse : in std_ulogic_vector (31 downto 0);
           o_instruction : out std_ulogic_vector (31 downto 0));
end component;

	component BancRegistres is
	Port ( 
		clk : in std_ulogic;
		reset : in std_ulogic;
		i_RS1 : in std_ulogic_vector (4 downto 0);
		i_RS2 : in std_ulogic_vector (4 downto 0);
		i_Wr_DAT : in std_ulogic_vector (31 downto 0);
		i_WDest : in std_ulogic_vector (4 downto 0);
		i_WE : in std_ulogic;
		o_RS1_DAT : out std_ulogic_vector (31 downto 0);
		o_RS2_DAT : out std_ulogic_vector (31 downto 0)
		);
	end component;
	
	component registrevector is
	Port ( 
		clk : in std_ulogic;
		reset : in std_ulogic;
		i_RS1 : in std_ulogic_vector (4 downto 0);
		i_RS2 : in std_ulogic_vector (4 downto 0);
		i_Wr_DAT : in std_ulogic_vector (127 downto 0);
		i_WDest : in std_ulogic_vector (4 downto 0);
		i_WE : in std_ulogic;
		o_RS1_DAT : out std_ulogic_vector (127 downto 0);
		o_RS2_DAT : out std_ulogic_vector (127 downto 0)
		);
	end component;

	component alu is
	Port ( 
		i_a			: in std_ulogic_vector (31 downto 0);
		i_b			: in std_ulogic_vector (31 downto 0);
		i_alu_funct	: in std_ulogic_vector (3 downto 0);
		i_shamt		: in std_ulogic_vector (4 downto 0);
		o_result	: out std_ulogic_vector (31 downto 0);
		o_zero		: out std_ulogic
		);
	end component;

    component MemDonneesWideDual is
    Port ( 
	   clk 		: in std_ulogic;
	   reset 		: in std_ulogic;
	   i_MemRead	: in std_ulogic;
	   i_MemWrite 	: in std_ulogic;
       i_Addresse 	: in std_ulogic_vector (31 downto 0);
	   i_WriteData : in std_ulogic_vector (31 downto 0);
       o_ReadData 	: out std_ulogic_vector (31 downto 0);
	
	   -- ports pour acc?s ? large bus, adresse partag?e
	   i_MemReadWide       : in std_ulogic;
	   i_MemWriteWide 		: in std_ulogic;
	   i_WriteDataWide 	: in std_ulogic_vector (127 downto 0);
        o_ReadDataWide 		: out std_ulogic_vector (127 downto 0)
    );
    end component;

	constant c_Registre31		 : std_ulogic_vector(4 downto 0) := "11111";
	signal s_zero        : std_ulogic;
	signal s_zero1        : std_ulogic;
	signal s_zero2       : std_ulogic;
	signal s_zero3        : std_ulogic;
	
    signal s_WriteRegDest_muxout: std_ulogic_vector(4 downto 0);
	
    signal r_PC                    : std_ulogic_vector(31 downto 0);
    signal s_PC_Suivant            : std_ulogic_vector(31 downto 0);
    signal s_adresse_PC_plus_4     : std_ulogic_vector(31 downto 0);
    signal s_adresse_jump          : std_ulogic_vector(31 downto 0);
    signal s_adresse_branche       : std_ulogic_vector(31 downto 0);
    
    signal s_Instruction : std_ulogic_vector(31 downto 0);

    signal s_opcode      : std_ulogic_vector( 5 downto 0);
    signal s_RS          : std_ulogic_vector( 4 downto 0);
    signal s_RT          : std_ulogic_vector( 4 downto 0);
    signal s_RD          : std_ulogic_vector( 4 downto 0);
    signal s_shamt       : std_ulogic_vector( 4 downto 0);
    signal s_instr_funct : std_ulogic_vector( 5 downto 0);
    signal s_imm16       : std_ulogic_vector(15 downto 0);
    signal s_jump_field  : std_ulogic_vector(25 downto 0);
    signal s_reg_data1        : std_ulogic_vector(31 downto 0);
    signal s_reg_data2        : std_ulogic_vector(31 downto 0);
    
    signal s_regV_data1        : std_ulogic_vector(127 downto 0);
    signal s_regV_data2        : std_ulogic_vector(127 downto 0);
    
    signal s_AluResult             : std_ulogic_vector(31 downto 0);
    signal s_AluResultV            : std_ulogic_vector(127 downto 0);
    
    signal s_Data2Reg_muxout       : std_ulogic_vector(31 downto 0);
    signal s_Data2RegV_muxout      : std_ulogic_vector(127 downto 0);
    
    signal s_imm_extended          : std_ulogic_vector(31 downto 0);
    signal s_imm_extended_shifted  : std_ulogic_vector(31 downto 0);
	
    signal s_Reg_Wr_Data           : std_ulogic_vector(31 downto 0);
    signal s_MemoryReadData        : std_ulogic_vector(31 downto 0);
    signal s_MemoryReadDataV    : std_ulogic_vector(127 downto 0);
    signal s_AluB_data             : std_ulogic_vector(31 downto 0);
     signal s_AluB_data2            : std_ulogic_vector(31 downto 0);
      signal s_AluB_data3             : std_ulogic_vector(31 downto 0);
       signal s_AluB_data4             : std_ulogic_vector(31 downto 0);
	
    --addvs
    signal s_muxReadData1 : std_logic_vector(31 downto 0);
    --sltv
    signal s_muxRead2SouV1 : std_logic_vector(31 downto 0);
    signal s_muxRead2SouV2 : std_logic_vector(31 downto 0);
    signal s_muxRead2SouV3 : std_logic_vector(31 downto 0);
    signal s_muxRead2SouV4 : std_logic_vector(31 downto 0);
begin


o_PC	<= r_PC; -- permet au synthétiseur de sortir de la logique. Sinon, il enlève tout...

------------------------------------------------------------------------
-- simplification des noms de signaux et transformation des types
------------------------------------------------------------------------
s_opcode        <= s_Instruction(31 downto 26);
s_RS            <= s_Instruction(25 downto 21);
s_RT            <= s_Instruction(20 downto 16);
s_RD            <= s_Instruction(15 downto 11);
s_shamt         <= s_Instruction(10 downto  6);
s_instr_funct   <= s_Instruction( 5 downto  0);
s_imm16         <= s_Instruction(15 downto  0);
s_jump_field	<= s_Instruction(25 downto  0);
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Compteur de programme et mise à jour de valeur
------------------------------------------------------------------------
process(clk)
begin
    if(clk'event and clk = '1') then
        if(reset = '1') then
            r_PC <= X"00400000";
        else
            r_PC <= s_PC_Suivant;
        end if;
    end if;
end process;

s_adresse_PC_plus_4				<= std_ulogic_vector(unsigned(r_PC) + 4);
s_adresse_jump					<= s_adresse_PC_plus_4(31 downto 28) & s_jump_field & "00";
s_imm_extended_shifted			<= s_imm_extended(29 downto 0) & "00";
s_adresse_branche				<= std_ulogic_vector(unsigned(s_imm_extended_shifted) + unsigned(s_adresse_PC_plus_4));

-- note, "i_jump_register" n'est pas dans les figures de COD5
s_PC_Suivant		<= s_adresse_jump when i_jump = '1' else
                       s_reg_data1 when i_jump_register = '1' else
					   s_adresse_branche when (i_branch = '1' and s_zero = '1') else
					   s_adresse_PC_plus_4;
					   

------------------------------------------------------------------------
-- Mémoire d'instructions
------------------------------------------------------------------------
inst_MemInstr: MemInstructions
Port map ( 
	i_addresse => r_PC,
    o_instruction => s_Instruction
    );

-- branchement vers le décodeur d'instructions
o_instruction <= s_Instruction;
	
------------------------------------------------------------------------
-- Banc de Registres
------------------------------------------------------------------------
-- Multiplexeur pour le registre en écriture
s_WriteRegDest_muxout <= c_Registre31 when i_jump_link = '1' else 
                         s_rt         when i_RegDst = '0' else 
						 s_rd;
       
inst_Registres: BancRegistres 
port map ( 
	clk          => clk,
	reset        => reset,
	i_RS1        => s_rs,
	i_RS2        => s_rt,
	i_Wr_DAT     => s_Data2Reg_muxout,
	i_WDest      => s_WriteRegDest_muxout,
	i_WE         => i_RegWrite,
	o_RS1_DAT    => s_reg_data1,
	o_RS2_DAT    => s_reg_data2
	);
	
	inst_RegistresVector: registrevector 
port map ( 
	clk          => clk,
	reset        => reset,
	i_RS1        => s_rs,
	i_RS2        => s_rt,
	i_Wr_DAT     => s_Data2RegV_muxout,--les donnees sont changees, pcq il faut en envoyer 128 a la place de 32
	i_WDest      => s_WriteRegDest_muxout, -- reste le m?me, pcq on a le m?me nombre de registres pour notre bacn vectoriel
	i_WE         => i_RegWriteV, --signal du controleur si on ecrit dans le registre vectoriel
	o_RS1_DAT    => s_regV_data1, --registre vectoriel dans lequel on va chercher des valeurs
	o_RS2_DAT    => s_regV_data2 --same
	);
	

------------------------------------------------------------------------
-- ALU (instance, extension de signe et mux d'entrée pour les immédiats)
------------------------------------------------------------------------
-- extension de signe
s_imm_extended <= std_ulogic_vector(resize(  signed(s_imm16),32)) when i_SignExtend = '1' else -- extension de signe à 32 bits
				  std_ulogic_vector(resize(unsigned(s_imm16),32)); 


--sltv
s_muxRead2SouV1 <= s_reg_data2 when i_ControleMuxSltv = '0' else s_regV_data2(31 downto 0) ;
s_muxRead2SouV2 <= s_reg_data2 when i_ControleMuxSltv = '0' else s_regV_data2(63 downto 32) ;
s_muxRead2SouV3 <= s_reg_data2 when i_ControleMuxSltv = '0' else s_regV_data2(95 downto 64) ;
s_muxRead2SouV4 <= s_reg_data2 when i_ControleMuxSltv = '0' else s_regV_data2(127 downto 96) ;

-- Mux pour immédiats
s_AluB_data <= s_muxRead2SouV1 when i_ALUSrc = '0' else s_imm_extended;
s_AluB_data2 <= s_muxRead2SouV2 when i_ALUSrc = '0' else s_imm_extended;
s_AluB_data3 <= s_muxRead2SouV3 when i_ALUSrc = '0' else s_imm_extended;
s_AluB_data4 <= s_muxRead2SouV4 when i_ALUSrc = '0' else s_imm_extended;



-----------------------------------------------------------------------------
--ADDVS
-----------------------------------------------------------------------------
s_AluResultV(31 downto 0) <= s_AluResult; 
s_muxReadData1 <= s_reg_data1 when i_ControleMuxAddvs = '0' else  s_regV_data1(31 downto 0);

inst_Alu0: alu
port map(

    i_a         => s_muxReadData1,
	i_b         => s_AluB_data,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_AluResult,
	o_zero      => s_zero
	);

inst_Alu1: alu 
port map( 
	i_a         => s_regV_data1(63 downto 32),
	i_b         => s_AluB_data2,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_AluResultV(63 downto 32),
	o_zero      => s_zero1
	);
	

inst_Alu2: alu 
port map( 
	i_a         => s_regV_data1(95 downto 64),
	i_b         => s_AluB_data3,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_AluResultV(95 downto 64),
	o_zero      => s_zero2
	);

inst_Alu3: alu 
port map( 
	i_a         => s_regV_data1(127 downto 96),
	i_b         => s_AluB_data4,
	i_alu_funct => i_alu_funct,
	i_shamt     => s_shamt,
	o_result    => s_AluResultV(127 downto 96),
	o_zero      => s_zero3
	);













------------------------------------------------------------------------
-- Mémoire de données
------------------------------------------------------------------------
	
inst_MemDonneesWide: MemDonneesWideDual
Port map(
    clk 		=> clk,
	reset 		=> reset,
	i_MemRead	=> i_MemRead,
	i_MemWrite	=> i_MemWrite,
    i_Addresse	=> s_AluResult,
	i_WriteData => s_reg_data2,
    o_ReadData	=> s_MemoryReadData,
	
	   -- ports pour acc?s ? large bus, adresse partag?e
	i_MemReadWide => i_MemReadWide,
	i_MemWriteWide => i_MemWriteWide,
	i_WriteDataWide => s_regV_data2,
    o_ReadDataWide => s_MemoryReadDataV
);
	

------------------------------------------------------------------------
-- Mux d'écriture vers le banc de registres
------------------------------------------------------------------------

s_Data2Reg_muxout    <= s_adresse_PC_plus_4 when i_jump_link = '1' else
					    s_AluResult         when i_MemtoReg = '0' else 
						s_MemoryReadData;
						
s_Data2RegV_muxout    <= s_AluResultV         when i_MemtoRegV = '0' else 
						 s_MemoryReadDataV;
        
end Behavioral;
