LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.aux_package.ALL;

----------------------------------------
ENTITY IR IS
    GENERIC( 
        BusWidth     : INTEGER := 16;
        RegWidth     : INTEGER := 4;
        ImmidWidth   : INTEGER := 8;
        OffsetWidth  : INTEGER := 8
    );
    PORT( 
        RmemData     : IN  STD_LOGIC_VECTOR(BusWidth-1 DOWNTO 0);
        IRin         : IN  STD_LOGIC;
        RFaddr_rd    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        RFaddr_wr    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        RFaddr_rdR   : OUT STD_LOGIC_VECTOR(RegWidth-1 DOWNTO 0);
        RFaddr_wrR   : OUT STD_LOGIC_VECTOR(RegWidth-1 DOWNTO 0);
        Offset       : OUT STD_LOGIC_VECTOR(OffsetWidth-1 DOWNTO 0);
        Immid        : OUT STD_LOGIC_VECTOR(ImmidWidth-1 DOWNTO 0);
        OPC          : OUT STD_LOGIC_VECTOR(RegWidth-1 DOWNTO 0)
    );
END IR;

ARCHITECTURE behav OF IR IS 
    SIGNAL IRreg : STD_LOGIC_VECTOR(BusWidth-1 DOWNTO 0);
BEGIN

    -- Load instruction register on IR
    PROCESS(IRin, RmemData)
    BEGIN
        IF IRin = '1' THEN
            IRreg <= RmemData;
        END IF;
    END PROCESS;

    -- Extract opcode
    OPC <= IRreg(4*RegWidth-1 DOWNTO 3*RegWidth);

    -- MUX for reading register address
    WITH RFaddr_rd SELECT
        RFaddr_rdR <= IRreg(RegWidth-1 DOWNTO 0)                 WHEN "00", -- R[rc]
                      IRreg(2*RegWidth-1 DOWNTO RegWidth)        WHEN "01", -- R[rb]
                      IRreg(3*RegWidth-1 DOWNTO 2*RegWidth)      WHEN OTHERS; -- R[ra] 

    -- MUX for writing register address
    WITH RFaddr_wr SELECT
        RFaddr_wrR <= IRreg(RegWidth-1 DOWNTO 0)                 WHEN "00", -- R[rc]
                      IRreg(2*RegWidth-1 DOWNTO RegWidth)        WHEN "01", -- R[rb]
                      IRreg(3*RegWidth-1 DOWNTO 2*RegWidth)      WHEN OTHERS; -- R[ra]

    -- Immediate and Offset outputs
    Offset <= IRreg(OffsetWidth-1 DOWNTO 0);
    Immid  <= IRreg(ImmidWidth-1 DOWNTO 0);

END behav;

