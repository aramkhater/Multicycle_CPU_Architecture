library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.aux_package.all;

entity Top is
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
end Top;

architecture behav of Top is
    -- Internal signals to connect control and datapath
    signal st, ld, mov, done, add, sub, jmp, jc, jnc,jn,jz       : std_logic;
    signal and_op, or_op, xor_op,merge,shl                           : std_logic;
    signal Cflag, Zflag, Nflag                             : std_logic;

    signal DTCM_wr, DTCM_addr_out, DTCM_addr_in, DTCM_out  : std_logic;
    signal RFin, RFout, Imm1_in, Imm2_in, Ain, Pcin, IRin  : std_logic;
    signal RFaddr_rd, RFaddr_wr                            : std_logic_vector(1 downto 0);
    signal PCsel                                           : std_logic_vector(1 downto 0);
    signal ALUFN                                           : std_logic_vector(3 downto 0);
    signal DTCM_addr_sel                                   : std_logic;  
	signal update_flags : std_logic;
begin

    -- Instantiate Control Unit
    Controlmapping: Control --generic		map (
			--Dwidth,
			--4
	--	)
        port map (
            st, ld, mov, done, add, sub,and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz,
            Cflag, Zflag, Nflag,
            rst, ena, clk,
            DTCM_wr,DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out,
            RFin, RFout, Imm1_in, Imm2_in, Ain, Pcin, IRin,
            RFaddr_rd, RFaddr_wr,
            PCsel, ALUFN,
            done_tb,update_flags 
        );

    -- Instantiate Datapath
    Datapathmapping: Datapath 
        generic map(
            Dwidth, Awidth, dept, BusWidth, RegWidth, ImmidWidth, OffsetWidth
        )
        port map (
            st, ld, mov, done, add, sub,and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz,
            Cflag, Zflag, Nflag,
            DTCM_wr, DTCM_addr_sel, DTCM_addr_out, DTCM_addr_in, DTCM_out, RFin, RFout,
            Imm1_in, Imm2_in, Ain, Pcin, IRin,
            RFaddr_rd, RFaddr_wr, PCsel, ALUFN,
            TBactive, DTCM_tb_addr_in, DTCM_tb_addr_out, TBdataindataMem, DTCM_tb_wr, TBdataout,
            ITCM_tb_wr, TBdatainProgMem, ITCM_tb_addr_in,
            clk, ena, rst,update_flags 
        );

end behav;

