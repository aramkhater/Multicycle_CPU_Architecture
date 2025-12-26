library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.aux_package.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

---------------------------------------------------------
entity top_tb is
    constant BusSize  : integer := 16;
    constant m        : integer := 16;
    constant Awidth   : integer := 6;	 
    constant RegSize  : integer := 4;
    constant dept     : integer := 64;

    constant dataMemResult    : string(1 to 87) :=
        "C:/Users/YourName/Path/to/datamemoryResultofExecutionofInstructions.txt";

    constant dataMemLocation  : string(1 to 84) :=
        "C:/Users/YourName/Path/to/datamemory.txt";

    constant progMemLocation  : string(1 to 84) :=
        "C:/Users/YourName/Path/to/progammemory.txt";
end top_tb;

---------------------------------------------------------
architecture rtb of top_tb is

    signal done_tb, rst, ena, clk, TBactive, DTCM_tb_wr, ITCM_tb_wr : std_logic := '0';
    signal DTCM_tb_in, DTCM_tb_out : std_logic_vector(BusSize-1 downto 0);
    signal ITCM_tb_in             : std_logic_vector(BusSize-1 downto 0);
    signal DTCM_tb_addr_in, ITCM_tb_addr_in : std_logic_vector(Awidth-1 downto 0);
    signal DTCM_tb_addr_out       : std_logic_vector(Awidth-1 downto 0);
    signal done_tbPmemIn, done_tbDmemIn : boolean := false;
 
begin

    TopUnit: entity work.Top
        generic map ( 
            Dwidth      => 16,
            Awidth      => 6,
            dept        => 64,
            BusWidth    => 16,
            RegWidth    => 4,
            ImmidWidth  => 8,
            OffsetWidth => 8
        )
        port map (
            clk              => clk,
            rst              => rst,
            ena              => ena,
            done_tb             => done_tb,
            TBactive         => TBactive,
            ITCM_tb_wr       => ITCM_tb_wr,
            TBdatainProgMem       => ITCM_tb_in,
            ITCM_tb_addr_in  => ITCM_tb_addr_in,
            DTCM_tb_wr       => DTCM_tb_wr,
            TBdataindataMem      => DTCM_tb_in,
            DTCM_tb_addr_in  => DTCM_tb_addr_in,
            DTCM_tb_addr_out => DTCM_tb_addr_out,
            TBdataout      => DTCM_tb_out
        );

    -- Reset process
    gen_rst : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;


    -- Clock generation
	gen_clk : process
	begin
	  clk <= '0';
	  wait for 50 ns;
	  clk <= not clk;
	  wait for 50 ns;
	end process;
	
	--------- 	TB
	gen_TB : process
        begin
		 TBactive <= '1';
		 wait until done_tbPmemIn and done_tbDmemIn;  
		 TBactive <= '0';
		 wait until done_tb = '1';  
		 TBactive <= '1';	
        end process;	

    -- Load Data Memory
    LoadDataMem: process 
        file inDmemfile : text open read_mode is dataMemLocation;
        variable linetomem     : std_logic_vector(BusSize-1 downto 0);
        variable good          : boolean;
        variable L             : line;
        variable TempAddresses : std_logic_vector(Awidth-1 downto 0);
    begin 
        done_tbDmemIn <= false;
        TempAddresses := (others => '0');
        while not endfile(inDmemfile) loop
            readline(inDmemfile, L);
            hread(L, linetomem, good);
            next when not good;
            DTCM_tb_wr      <= '1';
            DTCM_tb_addr_in <= TempAddresses;
            DTCM_tb_in      <= linetomem;
            wait until rising_edge(clk);
            TempAddresses := TempAddresses + 1;
        end loop;
        DTCM_tb_wr <= '0';
        done_tbDmemIn <= true;
        file_close(inDmemfile);
        wait;
    end process;

    -- Load Program Memory
    LoadProgramMem: process 
        file inPmemfile : text open read_mode is progMemLocation;
        variable linetomem     : std_logic_vector(BusSize-1 downto 0); 
        variable good          : boolean;
        variable L             : line;
        variable TempAddresses : std_logic_vector(Awidth-1 downto 0);
    begin 
        done_tbPmemIn <= false;
        TempAddresses := (others => '0');
        while not endfile(inPmemfile) loop
            readline(inPmemfile, L);
            hread(L, linetomem, good);
            next when not good;
            ITCM_tb_wr       <= '1';
            ITCM_tb_addr_in  <= TempAddresses;
            ITCM_tb_in       <= linetomem;
            wait until rising_edge(clk);
            TempAddresses := TempAddresses + 1;
        end loop;
        ITCM_tb_wr <= '0';
        done_tbPmemIn <= true;
        file_close(inPmemfile);
        wait;
    end process;



	ena <= '1' when (done_tbPmemIn and done_tbDmemIn) else '0';
	
		
	----- Writing from Data memory 
	WriteToDataMem: process 
		file outDmemfile : text open write_mode is dataMemResult;
		variable    linetomem			: std_logic_vector(BusSize-1 downto 0);
		variable	good				: boolean;
		variable 	L 					: line;
		variable	TempAddresses		: std_logic_vector(Awidth-1 downto 0) ; -- Awidth
		variable 	counter				: integer;
	begin 
		wait until done_tb = '1';  
		TempAddresses := (others => '0');
		counter := 1;
		while counter < 63 loop	--15 lines in file
			DTCM_tb_addr_out <= TempAddresses;
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			hwrite(L,DTCM_tb_out);
			writeline(outDmemfile,L);
			TempAddresses := TempAddresses +1;
			counter := counter +1;
		end loop ;
		file_close(outDmemfile);
		wait;
    end process;
	

end  rtb;
