LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Reg_file_W IS
GENERIC (
    N     : POSITIVE := 24 --num bit riga
	 );
PORT       (ADDR_OUT            : IN STD_LOGIC;
				INPUT1			:IN SIGNED(N-1 DOWNTO 0);
				INPUT2			:IN SIGNED(N-1 DOWNTO 0);
				CLOCK				 : IN STD_LOGIC;
				RESET				 : IN STD_LOGIC;
            LOAD_EN					 : IN STD_LOGIC;
				REG_OUT        : OUT SIGNED(N-1 DOWNTO 0));
END Reg_file_W;

ARCHITECTURE Behavior OF Reg_file_W IS

	COMPONENT mux2to1 IS 
	GENERIC (N : INTEGER:=10);
		PORT( input1 : IN SIGNED (N-1 DOWNTO 0);
				input2 : IN SIGNED (N-1 DOWNTO 0);
				sel	 : IN STD_LOGIC;
				output : OUT SIGNED (N-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT rise_register 
  GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN SIGNED(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
				 data_out : OUT SIGNED(N-1 DOWNTO 0));
  END COMPONENT;
	
	--SIGNAL out_reg1,out_reg2: STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	SIGNAL uout1, uout2: SIGNED(N-1 DOWNTO 0);
	
BEGIN

Reg_1W: rise_register   generic map (N=>N)
								   	port map (data_in=>INPUT1, clock=>CLOCK, reset=>RESET, LE=>LOAD_EN, data_out=>uout1, clear=>'0');
Reg_2W: rise_register   generic map (N=>N)
								   	port map (data_in=>INPUT2, clock=>CLOCK, reset=>RESET, LE=>LOAD_EN, data_out=>uout2, clear=>'0');
										
mux: mux2to1 generic map(N=>N)
									port map(input1=>uout1,input2=>uout2,sel=>ADDR_OUT,output=>REG_OUT);

END Behavior;
