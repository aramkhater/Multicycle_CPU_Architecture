LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.aux_package.all;

ENTITY Control IS
    PORT(
        st, ld, mov, done, add, sub, and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz,
        Cflag, Zflag, Nflag       : in std_logic;
        rst, ena, clk             : in std_logic;
        DTCM_wr, DTCM_addr_sel,
        DTCM_addr_out, DTCM_addr_in, DTCM_out,
        RFin, RFout,
        Imm1_in, Imm2_in, Ain, Pcin, IRin : out std_logic;
        RFaddr_rd, RFaddr_wr      : out std_logic_vector(1 downto 0);
        PCsel                     : out std_logic_vector(1 downto 0);
        ALUFN                     : out std_logic_vector(3 downto 0);
        tb_done                   : out std_logic;
		update_flags : out std_logic
    );
END Control;

ARCHITECTURE behav OF Control IS
    TYPE state IS (
        Rtypecyc1, --Rtypecyc2,
        Itypecyc1, Itypecyc2, Itypecyc3, Itypecyc4,
        Fetch, Decode, Reset
    );
    SIGNAL pr_state, nx_state: state;
BEGIN

    sync_process : process(clk, rst)
    begin
        if (rst = '1') then
            pr_state <= Reset;
        elsif (clk'EVENT AND clk='1' and ena = '1') then
            pr_state <= nx_state;
        end if;
    end process;

    FSM : process(pr_state, st, ld, mov, done, add, sub, and_op, or_op, xor_op,merge,shl, jmp, jc, jnc,jn,jz, Cflag, Zflag, Nflag)
    begin
        -- Default
        DTCM_wr        <= '0';
        ALUFN          <= "0000";
        Ain            <= '0';
        RFin           <= '0';
        RFout          <= '0';
        RFaddr_rd      <= "11";
        RFaddr_wr      <= "11";
        IRin           <= '0';
        PCin           <= '0';
        PCsel          <= "10";
        Imm1_in        <= '0';
        Imm2_in        <= '0';
        DTCM_out       <= '0';
        DTCM_addr_sel   <= '0';
        DTCM_addr_in   <= '0';
        DTCM_addr_out  <= '0';
        tb_done        <= '0';
        update_flags<= '0';
        case pr_state is

            when Reset =>
			            DTCM_wr        <= '0';
                      ALUFN          <= "0000";
					Ain            <= '0';
					RFin           <= '0';
					RFout          <= '0';
					RFaddr_rd      <= "11";
					RFaddr_wr      <= "11";
					IRin           <= '0';
					PCin           <= '0';
					PCsel          <= "10";
					Imm1_in        <= '0';
					Imm2_in        <= '0';
					DTCM_out       <= '0';
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					tb_done        <= '0';
					update_flags<= '0';

                if done = '0' then
                    nx_state <= Fetch;
                else
                   nx_state <= Reset;
                end if;

            when Fetch =>
			        DTCM_wr        <= '0';
					ALUFN          <= "0000";
					Ain            <= '0';
					RFin           <= '0';
					RFout          <= '0';
					RFaddr_rd      <= "11";
					RFaddr_wr      <= "11";
					update_flags<= '0';
					PCin           <= '0';
					
					Imm1_in        <= '0';
					Imm2_in        <= '0';
					DTCM_out       <= '0';
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					tb_done        <= '0';

                IRin <= '1';
                PCsel <= "10";
                nx_state <= Decode;

            when Decode =>
			        DTCM_wr        <= '0';
					RFaddr_rd      <= "11";
					IRin           <= '0';
                    ALUFN<="0000";
					Imm2_in        <= '0';
					DTCM_out       <= '0';
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					
				if done='1' then
				    PCin <= '1';
                    tb_done <= '1';
					Ain            <= '0';
					PCsel <= "00";
				   nx_state<=Reset;
                elsif (add = '1' or sub = '1' or and_op = '1' or or_op = '1' or xor_op = '1' or shl='1') then
				    ALUFN <= "0110"; --B => C
					RFout<='1';
				    RFaddr_rd <= "00"; -- R[rc]
					Ain  <= '1';
					PCin <= '0';
                    nx_state <= Rtypecyc1;
				
                 
				elsif (jmp = '1' or jc = '1' or jnc = '1' or jn='1' or jz='1') then
					if (jmp = '1') or (jc = '1' and Cflag = '1') or (jnc = '1' and Cflag = '0') or (jn = '1' and Nflag = '1')or (jz = '1' and Zflag = '1') then
						PCsel <= "01";
						PCin <= '1';
						nx_state <= Fetch;
					else 
						PCsel <= "10";
				        PCin <= '1';
						nx_state <= Fetch;
					end if;
                    
                    

                elsif mov = '1' then
				    ALUFN <= "0110";
					PCsel <= "10";
                    RFout<='0';					
                    RFin <= '1';
                    PCin <= '1';
                    RFaddr_wr <= "10";
					
                    Imm1_in <= '1';
                    nx_state <= Fetch;

                elsif (ld = '1' or st = '1') then
                    nx_state <= Itypecyc1;
                end if;

            when Rtypecyc1 =>
			       Ain  <= '0';
			       DTCM_wr        <= '0';
					
					RFaddr_rd <= "01"; --R[rb]
					RFout <= '1';
					IRin           <= '0';
					--PCin           <= '0';
					PCsel          <= "10";
					Imm1_in        <= '0';
					Imm2_in        <= '0';
					DTCM_out       <= '0';
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					tb_done        <= '0';
					update_flags<= '1';
				if add = '1' then
					ALUFN <= "0000";
				elsif sub = '1' then
					ALUFN <= "0001";
				elsif and_op = '1' then
					ALUFN <= "0010";
				elsif or_op = '1' then
					ALUFN <= "0011";
				elsif xor_op = '1' then
					ALUFN <= "0100";
				elsif shl='1' then
				   ALUFN <="0101";  --shl
				end if;
				PCin <= '1'; 
				Rfin <='1';
                RFaddr_wr <= "10"; --R[rc]

                nx_state <= Fetch;

            when Itypecyc1 =>
			        DTCM_wr        <= '0';
					RFin           <= '0';
					RFout          <= '0';
					RFaddr_rd      <= "11";
					RFaddr_wr      <= "11";
					IRin           <= '0';
					PCin           <= '0';
					PCsel          <= "10";
					Imm1_in        <= '0';
					
					DTCM_out       <= '0';
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					tb_done        <= '0';
					
                ALUFN <= "0110"; -- C=B
                Ain <= '1';
                Imm2_in <= '1';
                nx_state <= Itypecyc2;
            --cycle 2 the result of ALU to the latch
            when Itypecyc2 =>
					DTCM_wr        <= '0';
					ALUFN <= "0000";--sum 
					Ain            <= '0';
					
					RFout          <= '1';
					RFaddr_rd <= "01";
					RFaddr_wr      <= "11";
					IRin           <= '0';
					PCin           <= '0';
					PCsel          <= "10";
					Imm1_in        <= '0';
					Imm2_in        <= '0';
					DTCM_out       <= '0';
					tb_done        <= '0';
			        DTCM_addr_sel <= '1'; --bus A
                if ld = '1' then  
                    RFin           <= '1';				
                   DTCM_addr_out <= '1';
                elsif st = '1' then
				    RFin           <= '0';
				    RFaddr_rd <= "01";--R[ra]
				    ALUFN <= "0000";--sum 
                    DTCM_addr_in <= '1';
					
                end if;
                nx_state <= Itypecyc3;

            --cycle 3 read/write from/to memory
            when Itypecyc3 =>

					Ain            <= '0';
					

					RFaddr_wr      <= "11";
					IRin           <= '0';
					
					PCsel          <= "10";
					Imm1_in        <= '0';
					Imm2_in        <= '0';
					
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					tb_done        <= '0';
                  
                if ld = '1' then
				    RFaddr_rd <= "01";
                    DTCM_out <= '1';
					RFout     <= '0';
					ALUFN <= "0110"; -- C=B
                    RFin <= '0';
                    RFaddr_wr <= "10";
					PCin           <= '0';
					PCsel          <= "10";
					nx_state <= Itypecyc4;
                elsif st = '1' then
                    RFout <= '1'; 
					RFaddr_rd <= "10";--R[ra]
                    DTCM_wr <= '1';--read from bus B
					PCin           <= '1';
					PCsel          <= "10";
                    nx_state <=Fetch;
                end if;
            --cycle 4 load to the register
            when Itypecyc4 =>
                if ld='1' then
					Ain            <= '0';
					RFout          <= '0';
					RFaddr_rd      <= "11";
					IRin           <= '0';
					PCsel          <= "10";
					Imm1_in        <= '0';
					Imm2_in        <= '0';
					DTCM_out       <= '1';
					DTCM_addr_sel   <= '0';
					DTCM_addr_in   <= '0';
					DTCM_addr_out  <= '0';
					tb_done        <= '0';	
                    ALUFN <= "0110"; -- C=B
                    RFin <= '1';
                    RFaddr_wr <= "10";
				
			    elsif st = '1' then
                    RFout <= '1'; 
					RFaddr_rd <= "10";--R[ra]
                    DTCM_wr <= '1';--read from bus B
                end if;
                PCin <= '1';
                nx_state <= Fetch;

        end case;
    end process;

END behav;
