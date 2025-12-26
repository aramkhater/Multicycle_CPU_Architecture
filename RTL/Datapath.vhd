library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aux_package.all; 
--------------------------------------------------------------
entity Datapath is
generic( Dwidth: integer:=16;
		 Awidth: integer:=6;
		 dept:   integer:=64;
		 BusWidth      : integer := 16;
         RegWidth      : integer := 4;
         ImmidWidth    : integer := 8;
         OffsetWidth   : integer := 8
		 );
port( 	--status signals	
		st, ld, mov, done, add, sub,and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz,
         Cflag, Zflag, Nflag  : out std_logic;	
		--control signals
        DTCM_wr,DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,RFin, RFout,
		Imm1_in, Imm2_in, Ain, Pcin, IRin  : in std_logic;
		
	    RFaddr_rd : in std_logic_vector(1 downto 0);
		RFaddr_wr : in std_logic_vector(1 downto 0);
		PCsel: in std_logic_vector(1 downto 0);
		
		ALUFN: in std_logic_vector(3 downto 0);
		
	--Testbench signals
	    --for data memory
	    TBactive: in std_logic;
        DTCM_tb_addr_in: in std_logic_vector(Awidth-1 downto 0); --Address width
        DTCM_tb_addr_out: in std_logic_vector(Awidth-1 downto 0); --Address width		
	    DTCM_tb_in: in std_logic_vector(Dwidth-1 downto 0);
		DTCM_tb_wr: in std_logic;
		DTCM_tb_out: out std_logic_vector(Dwidth-1 downto 0); 
		
	    --for program memory	
		ITCM_tb_wr:in std_logic;
		ITCM_tb_in:in std_logic_vector(Dwidth-1 downto 0); --Data width
		ITCM_tb_addr_in:in std_logic_vector(Awidth-1 downto 0); --Address width 
		
		--for overall system
		clk: in std_logic;	
		ena: in std_logic;	
		rst: in std_logic;
		update_flags : in std_logic
		
		
		
); 
end Datapath ;

architecture behav of Datapath is
--------------------------------------------------------------
--program memory
signal RmemDataPM: std_logic_vector(Dwidth-1 downto 0);

--data memory
signal memEnDM: std_logic;
signal WmemDataDM: std_logic_vector(Dwidth-1 downto 0);
signal WmemAddrDM: std_logic_vector(Awidth-1 downto 0);
signal RmemAddrDM: std_logic_vector(Awidth-1 downto 0);
signal RmemDataDM: std_logic_vector(Dwidth-1 downto 0);
----------For data memory selection-----------
signal DFF_WMUXaddr  : std_logic_vector(Awidth-1 downto 0);
signal DFF_RMUXaddr  : std_logic_vector(Awidth-1 downto 0);
signal WMUXaddr      : std_logic_vector(Awidth-1 downto 0);
signal RMUXaddr      : std_logic_vector(Awidth-1 downto 0);

--RF 
signal RregData: std_logic_vector(Dwidth-1 downto 0);

--PC
signal PC :std_logic_vector(Dwidth-1 downto 0);

--IR
signal IRoffset : std_logic_vector(OffsetWidth-1 downto 0);
signal RFaddr_rdR: std_logic_vector(RegWidth-1 downto 0);
signal RFaddr_wrR: std_logic_vector(RegWidth-1 downto 0);
signal Offset       :  std_logic_vector(OffsetWidth-1 downto 0);
signal Immid        :  std_logic_vector(ImmidWidth-1 downto 0);
signal OPC          :  std_logic_vector(RegWidth-1 downto 0);
signal immid_ext : std_logic_vector(Dwidth-1 downto 0); 

--BUS A and B
signal BusB : std_logic_vector(BusWidth-1 downto 0);
signal BusA : std_logic_vector(BusWidth-1 downto 0);

--ALU
signal RegA :std_logic_vector(BusWidth-1 downto 0);
signal ALUFN_lab1: std_logic_vector(4 downto 0);

signal Cflag_reg, Zflag_reg, Nflag_reg : std_logic;
signal Cflag_alu: std_logic;
signal  Zflag_alu: std_logic;
signal Nflag_alu: std_logic;

  
begin
------------------------------------
----------PC mapping----------------
PCupdateModule: PC_Update
    generic map (
        Dwidth      => Dwidth,
        OffsetWidth => ImmidWidth
    )
    port map (
        clk      => clk,
        PCin     => Pcin,
        PCsel    => PCsel,
        IRoffset => Immid,
        PC_out   => PC
    );
--------------------------------------------	
----------------program memory mapping------------
ProgramMemoryModule: ProgMem
    generic map (
        Dwidth => Dwidth,
        Awidth => Awidth,
        dept   => dept
    )
    port map (
        clk       => clk,
        memEn     => ITCM_tb_wr,
        WmemData  => ITCM_tb_in,
        WmemAddr  => ITCM_tb_addr_in,
        RmemAddr  => PC(5 downto 0),
        RmemData  => RmemDataPM
    );
-----------------------------------------------
--------Data Memory mapping--------------
DataMemoryModule: dataMem
    generic map (
        Dwidth => Dwidth,
        Awidth => Awidth,
        dept   => dept
    )
    port map (
        clk       => clk,
        memEn     => memEnDM,
        WmemData  => WmemDataDM,
        WmemAddr  => WmemAddrDM,--DFF_WMUXaddr,
        RmemAddr  => RmemAddrDM,--DFF_RMUXaddr,
        RmemData  => RmemDataDM
    );
-----------------------------------------------
----------RF mapping-------------------------------------
RFmodule: RF 
  generic map(
    Dwidth => Dwidth,
    Awidth => RegWidth
  )
  port map (
    clk        => clk,
    rst        => rst,
    WregEn     => RFin,
    WregData   => BusA,
    WregAddr   => RFaddr_wrR,
    RregAddr   => RFaddr_rdR,
    RregData   => RregData
  );

---------IR mapping-----------------------
IRmodule: IR 
  generic map( BusWidth, RegWidth, OffsetWidth, ImmidWidth )
  port map(  
    RmemData    => RmemDataPM,
    IRin        => IRin,
    RFaddr_rd   => RFaddr_rd,
    RFaddr_wr   => RFaddr_wr,
    RFaddr_rdR  => RFaddr_rdR,
    RFaddr_wrR  => RFaddr_wrR,
    Offset      => Offset,
    Immid       => Immid, 
    OPC         => OPC 
  );
----------------------------------------------			
-----------OPC Decoder mapping-----------------
OPCdecoderModule: OPCdecoder 
  generic map (
    RegSize => RegWidth
  )
  port map (
    OPC => OPC,
    st       => st,
    ld       => ld,
    mov      => mov,
    done     => done,
    add      => add,
    sub      => sub,
    jmp      => jmp,
    jc   => jc,
    jnc  => jnc,
	jn => jn,
	jz => jz,
    and_op   => and_op,
    or_op    => or_op,
    xor_op   => xor_op,
	merge=>merge,
	shl => shl
  );

---------------------------------------------
--ALU mapping
---------------------------------------------
ALUmapping: ALU 
  generic map (BusWidth, RegWidth, 8)
  port map (
    Y_i       => BusB,   
    X_i       => RegA,
    ALUFN_i   => ALUFN_lab1,
    ALUout_o  => BusA,
    Nflag_o   => Nflag_alu,  -- Raw ALU output
    Cflag_o   => Cflag_alu,  -- Raw ALU output
    Zflag_o   =>  Zflag_alu,  -- Raw ALU output
    Vflag_o   => open    -- Unused
  );
  



----------------------------------------------
--ALUFN update to match ALU in Lab 1
----------------------------------------------
-- Reuse what done in lab 1.
with ALUFN select
  ALUFN_lab1 <=

    "01000" when "0000",  -- add
    "01001" when "0001",  -- sub
    "11010" when "0010",  -- and
    "11001" when "0011",  -- or
    "11011" when "0100",  -- xor
	"01111" when "0110", --C=B
	"10000" when "0101", -- 
    "00000" when others;

			  --will add more ops in future
----------------------------------------------	
-----------For Data Memory--------------------
memEnDM <= DTCM_tb_wr when TBactive='1' else DTCM_wr;
WmemDataDM <= DTCM_tb_in when TBactive='1' else BusB;
WmemAddrDM <= DTCM_tb_addr_in when TBactive='1' else DFF_WMUXaddr;-- feed from external file external files
RmemAddrDM <= DTCM_tb_addr_out when TBactive='1' else DFF_RMUXaddr;

-----------For TB------
DTCM_tb_out <= RmemDataDM;--

----------------------------------------
-------sign extension-------------------
immid_ext <= std_logic_vector(resize(signed(Immid), Dwidth)) when Imm1_in = '1' else --8bit
             std_logic_vector(resize(signed(Immid(RegWidth-1 downto 0)), Dwidth)) when Imm2_in = '1' else--4bit
             (others => '0');

----------------------------------------------------------------
-------------TristateConnections--------------------------------
-- TristateRFconnToBussB: BidirPin generic map(Dwidth) Port map (RregData, RFout, open, BusB);
-- TristateOffsetconnToBussB: BidirPin generic map(Dwidth) Port map (immid_ext, Imm1_in , open, BusB);
-- TristateImmedconnToBussB: BidirPin generic map(Dwidth) Port map (immid_ext, Imm2_in , open, BusB);
-- TristateDMconnToBussB: BidirPin generic map(Dwidth) Port map ( RmemDataDM,DTCM_out, open, BusB);

----------------------------------------------------------------
---------Choose bus to write/read Address: BUS B or BUS A------
--DFF_WMUXaddr  <= BusA(5 downto 0);-- when DTCM_addr_sel = '1' else (others=>'Z');
--DFF_RMUXaddr   <= BusA(5 downto 0);-- when DTCM_addr_sel = '1' else (others=>'Z');

--BusA <= busB when ALUFN="0101" else unaffected;
BusB <= RregData when RFout='1' else (others=>'Z');
BusB <= immid_ext when Imm1_in='1' else (others=>'Z');
BusB <= immid_ext when Imm2_in='1' else (others=>'Z');
BusB <= RmemDataDM when DTCM_out='1' else (others=>'Z');
-------------------------------------------------------
--------------- RegA Write ----------------
RegA_Write: process(clk)
begin
  if rising_edge(clk) then
    if Ain = '1' then
      RegA <= BusA;
    end if;
  end if;
end process;

-------------------------------------------------------
--------------- Data Memory Write Address -------------
DataMem_Write: process(clk) 
 begin
	if rising_edge(clk) then
		if (DTCM_addr_in = '1') then
			DFF_WMUXaddr <= BusA(5 downto 0);
		end if;
	end if;	
end process;

-------------------------------------------------------
--------------- Data Memory Read Address --------------
DataMem_read: process(clk) 
begin
	if rising_edge(clk) then
		if (DTCM_addr_out = '1') then
			DFF_RMUXaddr <= BusA(5 downto 0);
		end if;
	end if;
end process;
-------------------------------------------------------
process(clk, rst)
begin
  if rst = '1' then
    Cflag_reg <= '0';
    Zflag_reg <= '0';
    Nflag_reg <= '0';
  elsif rising_edge(clk) then
    if update_flags = '1' then
      Cflag_reg <= Cflag_alu;
      Zflag_reg <= Zflag_alu;
      Nflag_reg <= Nflag_alu;
    end if;
  end if;
end process;

-- Connect registers to outputs
Cflag <= Cflag_reg;
Zflag <= Zflag_reg;
Nflag <= Nflag_reg;

end behav;
