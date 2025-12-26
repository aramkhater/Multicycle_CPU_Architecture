library ieee;
use ieee.std_logic_1164.all;

entity OPCdecoder is
    port(
        st, ld, mov, done, add, sub, jmp, jc, jnc,jn,jz : out std_logic;
        and_op, or_op, xor_op,merge,shl : out std_logic;
        OPC : in std_logic_vector(3 downto 0)
    );
end OPCdecoder;

architecture behav of OPCdecoder is
begin

    done    <= '1' when OPC = "1111" else '0';
    st      <= '1' when OPC = "1110" else '0';
    ld      <= '1' when OPC = "1101" else '0';
    mov     <= '1' when OPC = "1100" else '0';
    add     <= '1' when OPC = "0000" else '0';
    sub     <= '1' when OPC = "0001" else '0';
    and_op  <= '1' when OPC = "0010" else '0';
    or_op   <= '1' when OPC = "0011" else '0';
    xor_op  <= '1' when OPC = "0100" else '0';
	merge <= '1' when OPC="0110" else '0';
    jmp     <= '1' when OPC = "0111" else '0';
    jc      <= '1' when OPC = "1000" else '0';
    jnc     <= '1' when OPC = "1001" else '0';
	jn <= '1' when OPC="1010" else '0';
	jz <= '1' when OPC="1011" else '0';
	shl <= '1' when OPC="0101" else '0';

end behav;



  
		