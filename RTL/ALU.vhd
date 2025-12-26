LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- Standard arithmetic library
USE work.aux_package.all;

ENTITY ALU IS
  GENERIC (
    n : INTEGER := 8;
    k : INTEGER := 3;   -- k=log2(n)
    m : INTEGER := 4    -- m=2^(k-1)
  );
  PORT (
    Y_i, X_i : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
    ALUFN_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    ALUout_o : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0);  -- Changed from OUT to BUFFER
    Nflag_o, Cflag_o, Zflag_o, Vflag_o : OUT STD_LOGIC
  );
END ALU;

ARCHITECTURE struct OF ALU IS
  SIGNAL ALUout_addsub, ALUout_shifter, ALUout_logic : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  SIGNAL Cflag_addsub, Cflag_shifter, Cflag_logic : STD_LOGIC;

  -- Component Declarations
  COMPONENT AdderSub
    GENERIC (n : INTEGER := 8);
    PORT (
      sub_cont : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      x, y     : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);
      cout     : OUT STD_LOGIC;
      s        : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT Shifter
    GENERIC (n : INTEGER := 8; k : INTEGER := 3);
    PORT (
      y    : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
      x    : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
      dir  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      res  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
      cout : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT Logic
    GENERIC (n : INTEGER := 8);
    PORT (
      X, Y     : IN  STD_LOGIC_VECTOR(n-1 DOWNTO 0);
      Alufn    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      LogicOut : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
      cout     : OUT STD_LOGIC
    );
  END COMPONENT;

BEGIN
  -- Instantiate AdderSub
  U1: AdderSub
    GENERIC MAP (n => n)
    PORT MAP (
      sub_cont => ALUFN_i(2 DOWNTO 0),
      x => X_i,
      y => Y_i,
      cout => Cflag_addsub,
      s => ALUout_addsub
    );

  -- Instantiate Shifter
  U2: Shifter
    GENERIC MAP (n => n, k => k)
    PORT MAP (
      x => X_i,
      y => Y_i,
      dir => ALUFN_i(2 DOWNTO 0),
      res => ALUout_shifter,
      cout => Cflag_shifter
    );

  -- Instantiate Logic
  U3: Logic
    GENERIC MAP (n => n)
    PORT MAP (
      X => X_i,
      Y => Y_i,
      Alufn => ALUFN_i(2 DOWNTO 0),
      LogicOut => ALUout_logic,
      cout => Cflag_logic
    );

  -- ALU operation selection based on ALUFN_i
  WITH ALUFN_i(4 DOWNTO 3) SELECT
    ALUout_o <= ALUout_addsub WHEN "01",
                ALUout_shifter WHEN "10",
                ALUout_logic   WHEN "11",
                (others => '0') WHEN others;

  -- Set Cflag based on operation
  Cflag_o <= Cflag_addsub WHEN ALUFN_i(4 DOWNTO 3) = "01" ELSE
             Cflag_shifter WHEN ALUFN_i(4 DOWNTO 3) = "10" ELSE
             Cflag_logic WHEN ALUFN_i(4 DOWNTO 3) = "11" ELSE
             '0';

  -- Compute flags
  Nflag_o <= ALUout_o(n-1);  -- Negative flag (MSB of result)
  Zflag_o <= '1' WHEN ALUout_o = (ALUout_o'RANGE => '0') ELSE '0';

Vflag_o <= '1' WHEN 
  (ALUFN_i(4 DOWNTO 3) = "01") AND (
    ( (ALUFN_i(2 DOWNTO 0) = "000" OR ALUFN_i(2 DOWNTO 0) = "001") AND 
      ( (X_i(n-1) = '0' AND Y_i(n-1) = '0' AND ALUout_o(n-1) = '1') OR 
        (X_i(n-1) = '0' AND Y_i(n-1) = '1' AND ALUout_o(n-1) = '0') )
    ) OR
    ( (ALUFN_i(2 DOWNTO 0) = "011" OR ALUFN_i(2 DOWNTO 0) = "100") AND 
      ( (Y_i(n-1) = '0' AND ALUout_o(n-1) = '1') OR 
        (Y_i(n-1) = '1' AND ALUout_o(n-1) = '0') )
    ) OR
    ( (ALUFN_i(2 DOWNTO 0) = "010") AND 
      (X_i(n-1) = '1' AND ALUout_o(n-1) = '1')
    )
  ) ELSE '0';
  
  

END struct;
