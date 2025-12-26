LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Shifter is 
  GENERIC (
    n : INTEGER := 8;  -- Data width
    k : INTEGER := 3   -- Shift amount width
  );
  port( 
    y    : IN  STD_LOGIC_VECTOR(n-1 downto 0);  
    x    : IN  STD_LOGIC_VECTOR(n-1 downto 0);  
    dir  : IN  STD_LOGIC_VECTOR(2 downto 0);    
    res  : OUT STD_LOGIC_VECTOR(n-1 downto 0);  
    cout : OUT STD_LOGIC                        
  );
end Shifter;

ARCHITECTURE op1 OF Shifter IS
    signal q : integer range 0 to (2**k)-1;  -- Holds the shift value (converted from x)
    signal valid_shift : std_logic;  -- Flag to check if n = 2^k
    signal x_k : std_logic_vector(k-1 downto 0);
BEGIN
    -- Check if n = 2^k
    valid_shift <= '1' when (n = 2**k) else '0';
    
    x_k <= x(k-1 downto 0);
    
    -- Convert the shift amount (x) to an integer q, using only the lower k bits
    q <= to_integer(unsigned(x_k));  
    
    -- Shift operations using concatenation, only if n = 2^k
    res <= (y(n-1-q downto 0) & (q-1 downto 0 => '0')) when (dir = "000" and valid_shift = '1' and q >= 0) else  -- Shift Left
           ((q-1 downto 0 => '0') & y(n-1 downto q)) when (dir = "001" and valid_shift = '1' and q >= 0) else    -- Shift Right
           (others => '0'); 

    -- Carry-out logic
    cout <= '0' when (q = 0 and valid_shift = '1') else
            y(n-q) when (dir = "000" and valid_shift = '1') else
            y(q-1) when (dir = "001" and valid_shift = '1') else
            '0';

END op1;









