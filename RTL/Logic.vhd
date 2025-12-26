LIBRARY ieee;
USE ieee.std_logic_1164.all;
--------------------------------------------------------
ENTITY Logic IS
	Generic (n: integer :=8);
	Port (
	X,Y: in std_logic_vector(n-1 downto 0);
	Alufn: in std_logic_vector(2 downto 0);
	LogicOut: out std_logic_vector(n-1 downto 0);
	cout: out std_logic
	);
END Logic;
--------------------------------------------------------
ARCHITECTURE structural OF Logic IS
BEGIN
LogicOut <= (not Y)          when Alufn = "000" else
            (Y or X)         when Alufn = "001" else
            (Y and X)        when Alufn = "010" else
            (Y xor X)        when Alufn = "011" else
            (not (Y or X))   when Alufn = "100" else  -- NOR
            (not (Y and X))  when Alufn = "101" else  -- NAND
            (not (Y xor X))  when Alufn = "111" else  -- XNOR
			(X(n-1 downto (n-8))&Y(7 downto 0))   when Alufn="110"  else --Merge
            (others => '0'); -- Default case

cout <= '0';

END structural;
