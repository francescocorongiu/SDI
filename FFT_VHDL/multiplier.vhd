LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY multiplier IS
GENERIC(N : integer:=8);
PORT(A,B: IN SIGNED(N-1 DOWNTO 0);
		clock, reset, MPY_SHn: IN STD_LOGIC;
		p: OUT SIGNED(2*N-1 DOWNTO 0);
		shift_out: OUT SIGNED(N DOWNTO 0));
END multiplier;

ARCHITECTURE Structure OF multiplier IS 

COMPONENT rise_register
  GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN SIGNED(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  
				 data_out : OUT SIGNED(N-1 DOWNTO 0));
END COMPONENT;

SIGNAL outreg1,outproduct: SIGNED (2*N-1 DOWNTO 0);

BEGIN
			reg1: rise_register GENERIC MAP (N=>2*N)
				PORT MAP (clock=>clock, data_in=>outproduct, clear=>'0', reset=>reset, LE=>MPY_SHn, data_out=>outreg1);
				
			reg2: rise_register GENERIC MAP (N=>2*N)
				PORT MAP (clock=>clock, data_in=>outreg1, clear=>'0', reset=>reset, LE=>'1', data_out=>p);	
	
	shift_out<= A(N-2 downto 0) & "00";
	outproduct<=A*B;
	
END Structure;