LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY CU_Butterfly IS
PORT       (START            : IN STD_LOGIC;
				RESET				: IN STD_LOGIC;
				DONE 				: OUT STD_LOGIC;
				CLOCK 			:IN STD_LOGIC;
				COMMAND        : OUT STD_LOGIC_VECTOR(24 DOWNTO 0));
END CU_Butterfly;

ARCHITECTURE Behavior OF CU_Butterfly IS

	COMPONENT reg IS
	  GENERIC (N : INTEGER:=10);
			PORT ( clock : IN STD_LOGIC;
					 data_in : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
					 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
					 data_out : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT fall_register IS
   GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
				 data_out : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
   END COMPONENT;

	COMPONENT mux3to1_std IS
		GENERIC (N : INTEGER:=10);
			PORT( input1 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
					input2 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
					input3 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
					sel	 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
					output : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT Rom_async IS
		PORT       (ADDR            : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
						OUTPUT         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT adder_u IS
	GENERIC(N : integer:=8);
		PORT(a,b: IN UNSIGNED(N-1 DOWNTO 0);
				s: OUT UNSIGNED(N-1 DOWNTO 0)
				);
	END COMPONENT;
	
	COMPONENT start_jump IS
				PORT( 
					reset: IN STD_LOGIC;
					addr: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
					cc: IN STD_LOGIC;
					start: IN STD_LOGIC;
					sel_addr: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
					);
	END COMPONENT;
	
	SIGNAL mux_out, addr_rom: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL adder_out: UNSIGNED(4 DOWNTO 0);
	SIGNAL rom_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cc: STD_LOGIC;
	SIGNAL jmp_addr: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL uir_out: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mux_sel: STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

uAR: reg GENERIC MAP( N=>5)
		PORT MAP(clock=>CLOCK, data_in=>mux_out, clear=>'0', reset=>'0', LE=>'1', data_out=>addr_rom);
		
ROM: Rom_async PORT MAP(ADDR=>addr_rom, OUTPUT=>rom_out);

uIR: fall_register GENERIC MAP( N=>32)
		PORT MAP(clock=>CLOCK, data_in=>rom_out, clear=>'0', reset=>'0', LE=>'1', data_out=>uir_out);

cc<=uir_out(31);
jmp_addr<=uir_out(30 DOWNTO 26);
COMMAND<=uir_out(25 DOWNTO 1);
DONE<=uir_out(0);


mux: mux3to1_std GENERIC MAP(N=>5)
		PORT MAP (input1=>STD_LOGIC_VECTOR(adder_out), input2=>jmp_addr, input3=>"00000", sel=>mux_sel, output=>mux_out);
		
sommatore: adder_u GENERIC MAP(N=>5)
			PORT MAP(a=>UNSIGNED(addr_rom), b=>"00001",s=>adder_out);
			
st_jmp: start_jump PORT MAP ( reset=>RESET, addr=>addr_rom, cc=>cc, start=>START, sel_addr=>mux_sel); 

END Behavior;