library IEEE;
use ieee.std_logic_1164.all;

package aux_package is

--------------------------------------------------------
-- ALU
--------------------------------------------------------
	component ALU is
		GENERIC (
			n : INTEGER := 8;
			k : integer := 3;   -- k=log2(n)
			m : integer := 4    -- m=2^(k-1)
		);
		PORT (
			Y_i, X_i        : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			ALUFN_i         : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALUout_o        : OUT STD_LOGIC_VECTOR(n-1 downto 0);
			Nflag_o, Cflag_o, Zflag_o, Vflag_o : OUT STD_LOGIC
		);
	end component;

--------------------------------------------------------
-- Full Adder
--------------------------------------------------------
	component FA is
		PORT (
			xi, yi, cin : IN std_logic;
			s, cout     : OUT std_logic
		);
	end component;

--------------------------------------------------------
-- AddSub part of the ALU
--------------------------------------------------------
	component AdderSub is
		GENERIC (n : INTEGER := 8);
		PORT (
			sub_cont : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			x, y     : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			cout     : OUT STD_LOGIC;
			s        : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- Logic part of the ALU
--------------------------------------------------------
	component Logic is
		GENERIC (n: integer := 8);
		PORT (
			X, Y     : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			Alufn    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			LogicOut : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			cout     : OUT STD_LOGIC
		);
	end component;

--------------------------------------------------------
-- Shifter part of the ALU
--------------------------------------------------------
	component Shifter is 
		GENERIC (
			n : INTEGER := 8;
			k : INTEGER := 3
		);
		PORT( 
			y    : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);  
			x    : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);  
			dir  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);    
			res  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);  
			cout : OUT STD_LOGIC
		);
	end component;

--------------------------------------------------------
-- Tristate
--------------------------------------------------------
	component BidirPin is
		GENERIC (width: integer := 16);
		PORT (
			Dout  : IN    STD_LOGIC_VECTOR(width-1 DOWNTO 0);
			en    : IN    STD_LOGIC;
			Din   : OUT   STD_LOGIC_VECTOR(width-1 DOWNTO 0);
			IOpin : INOUT STD_LOGIC_VECTOR(width-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- Data Memory
--------------------------------------------------------
	component dataMem is
		GENERIC (
			Dwidth: INTEGER := 16;
			Awidth: INTEGER := 6;
			dept  : INTEGER := 64
		);
		PORT (
			clk, memEn     : IN  STD_LOGIC;	
			WmemData       : IN  STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0);
			WmemAddr,
			RmemAddr       : IN  STD_LOGIC_VECTOR(Awidth-1 DOWNTO 0);
			RmemData       : OUT STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- Program Memory
--------------------------------------------------------
	component ProgMem is
		GENERIC (
			Dwidth: INTEGER := 16;
			Awidth: INTEGER := 6;
			dept  : INTEGER := 64
		);
		PORT (
			clk, memEn     : IN  STD_LOGIC;	
			WmemData       : IN  STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0);
			WmemAddr,
			RmemAddr       : IN  STD_LOGIC_VECTOR(Awidth-1 DOWNTO 0);
			RmemData       : OUT STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- Register File
--------------------------------------------------------
	component RF is
		GENERIC (
			Dwidth: INTEGER := 16;
			Awidth: INTEGER := 4
		);
		PORT (
			clk, rst, WregEn : IN  STD_LOGIC;	
			WregData         : IN  STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0);
			WregAddr,
			RregAddr         : IN  STD_LOGIC_VECTOR(Awidth-1 DOWNTO 0);
			RregData         : OUT STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- PC
--------------------------------------------------------
	component PC_Update is
		GENERIC (
			Dwidth      : INTEGER := 16;
			OffsetWidth : INTEGER := 8
		);
		PORT (
			clk      : IN  STD_LOGIC;
			PCin     : IN  STD_LOGIC;
			PCsel    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			IRoffset : IN  STD_LOGIC_VECTOR(OffsetWidth-1 DOWNTO 0);
			PC_out   : OUT STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- Operation Decoder
--------------------------------------------------------
component OPCdecoder is
    port(
        st, ld, mov, done, add, sub, jmp, jc, jnc,jn,jz : out std_logic;
        and_op, or_op, xor_op,merge,shl : out std_logic;
        OPC : in std_logic_vector(3 downto 0)
    );
end component;


--------------------------------------------------------
-- IR
--------------------------------------------------------
	component IR is 
		GENERIC ( 
			BusWidth    : INTEGER := 16;
			RegWidth    : INTEGER := 4;
			ImmidWidth  : INTEGER := 8;
			OffsetWidth : INTEGER := 8
		);
		PORT ( 
			RmemData   : IN  STD_LOGIC_VECTOR(BusWidth-1 DOWNTO 0);
			IRin       : IN  STD_LOGIC;
			RFaddr_rd  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
			RFaddr_wr  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            RFaddr_rdR : OUT STD_LOGIC_VECTOR(RegWidth-1 DOWNTO 0);
            RFaddr_wrR : OUT STD_LOGIC_VECTOR(RegWidth-1 DOWNTO 0);
			Offset     : OUT STD_LOGIC_VECTOR(OffsetWidth-1 DOWNTO 0);
			Immid      : OUT STD_LOGIC_VECTOR(ImmidWidth-1 DOWNTO 0);
			OPC        : OUT STD_LOGIC_VECTOR(RegWidth-1 DOWNTO 0)
		);
	end component;

--------------------------------------------------------
-- Datapath
--------------------------------------------------------
component Datapath is
  GENERIC (
    Dwidth      : INTEGER := 16;
    Awidth      : INTEGER := 6;
    dept        : INTEGER := 64;
    BusWidth    : INTEGER := 16;
    RegWidth    : INTEGER := 4;
    ImmidWidth  : INTEGER := 8;
    OffsetWidth : INTEGER := 8
  );
  PORT (
    st, ld, mov, done, add, sub, and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz,
    Cflag, Zflag, Nflag : OUT STD_LOGIC;

    DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in,
    DTCM_out, RFin, RFout,
    Imm1_in, Imm2_in, Ain, Pcin, IRin : IN STD_LOGIC;

    RFaddr_rd : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    RFaddr_wr : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    PCsel     : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALUFN     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

    TBactive        : IN STD_LOGIC;
    DTCM_tb_addr_in : IN STD_LOGIC_VECTOR(Awidth-1 DOWNTO 0);
    DTCM_tb_addr_out: IN STD_LOGIC_VECTOR(Awidth-1 DOWNTO 0);
    DTCM_tb_in      : IN STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0);
    DTCM_tb_wr      : IN STD_LOGIC;
    DTCM_tb_out     : OUT STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0);

    ITCM_tb_wr      : IN STD_LOGIC;
    ITCM_tb_in      : IN STD_LOGIC_VECTOR(Dwidth-1 DOWNTO 0);
    ITCM_tb_addr_in : IN STD_LOGIC_VECTOR(Awidth-1 DOWNTO 0);

    clk, ena, rst,		update_flags   : IN STD_LOGIC
  );
end component;


--------------------------------------------------------
-- Control Unit
--------------------------------------------------------
	component Control is
	--	GENERIC (
		--	Dwidth : INTEGER := 16;
			--Awidth : INTEGER := 4
		--);
		PORT (
			st, ld, mov, done, add, sub, and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz,
			 Cflag, Zflag, Nflag : IN STD_LOGIC;
			rst, ena, clk                         : IN STD_LOGIC;

			DTCM_wr,DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,
			RFin, RFout, Imm1_in, Imm2_in, Ain, Pcin, IRin : OUT STD_LOGIC;
			RFaddr_rd, RFaddr_wr                           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			PCsel                                          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUFN                                          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 tb_done,update_flags : out std_logic
		);
	end component;
--------------------------------------------------------
-- Top 
--------------------------------------------------------
component Top is
    generic( 
        Dwidth       : integer := 16;
        Awidth       : integer := 6;
        dept         : integer := 64;
        BusWidth     : integer := 16;
        RegWidth     : integer := 4;
        ImmidWidth   : integer := 8;
        OffsetWidth  : integer := 8
    );
    port(	
        clk                 : in std_logic;
        ena                 : in std_logic;	
        rst                 : in std_logic;
        done_tb             : out std_logic;


        -- Datapath Output
        TBdataout           : out std_logic_vector(Dwidth-1 downto 0);

        -- Input to dataMem
        TBactive            : in std_logic;
        DTCM_tb_wr          : in std_logic;
        DTCM_tb_addr_in     : in std_logic_vector(Awidth-1 downto 0);
        DTCM_tb_addr_out    : in std_logic_vector(Awidth-1 downto 0);
        TBdataindataMem     : in std_logic_vector(Dwidth-1 downto 0);

        -- Input to progMem
        ITCM_tb_wr          : in std_logic;
        ITCM_tb_addr_in     : in std_logic_vector(Awidth-1 downto 0);
        TBdatainProgMem     : in std_logic_vector(Dwidth-1 downto 0)
    );
end component;

end aux_package;


