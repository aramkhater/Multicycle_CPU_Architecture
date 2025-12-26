library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Update is
    generic (
        Dwidth      : integer := 16;
        OffsetWidth : integer := 8
    );
    Port (
        clk      : in  std_logic;
        PCin     : in  std_logic;                          -- PC update enable
        PCsel    : in  std_logic_vector(1 downto 0);       -- PC selection signal
        IRoffset : in  std_logic_vector(OffsetWidth-1 downto 0); -- 8-bit immediate
        PC_out   : out std_logic_vector(Dwidth-1 downto 0) -- Current PC value
    );
end PC_Update;

architecture Behavioral of PC_Update is
    signal PC : std_logic_vector(Dwidth-1 downto 0) := (others => '0'); -- Internal PC register
begin
    process(clk)
        variable offset : signed(Dwidth-1 downto 0); -- Sign-extended offset
    begin
        if rising_edge(clk) then
            if PCin = '1' then
                --  Properly cast IRoffset to signed before resizing
                offset := resize(signed(IRoffset), Dwidth);

                case PCsel is
                    when "00" =>
                        PC <= (others => '0');  -- Reset PC
                    when "01" =>
                        -- PC + 1 + offset (branch case)
                        PC <= std_logic_vector(signed(PC) + 1 +offset);
                    when "10" =>
                        -- PC + 1 (sequential)
                        PC <= std_logic_vector(unsigned(PC) + 1);
                    when others =>
                        -- Hold current value
                        PC <= PC;
                end case;
            end if;
        end if;
    end process;

    PC_out <= PC;

end Behavioral;





