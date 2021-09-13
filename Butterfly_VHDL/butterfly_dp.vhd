library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY butterfly_dp IS

	PORT( CLOCK : IN STD_LOGIC;
			IN_A, IN_B: IN SIGNED (23 DOWNTO 0); --REGISTER FILE AB
			ADDR_IN: IN STD_LOGIC_VECTOR (1 DOWNTO 0); --REGISTER FILE AB  --addr reg1 e reg2 + addr reg3 e reg4
			ADDR_OUT : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --REGISTER FILE AB --addr uscita1 + addr uscita2
			RST_RF, LE_RF	 : IN STD_LOGIC; --REGISTER FILE AB
			Wi, Wr : IN SIGNED (23 DOWNTO 0); --REGISTER FILE W
			LE_W, RST_W : IN STD_LOGIC; --REGISTER FILE W 
			ADDR_OUTW : IN STD_LOGIC; --REGISTER FILE W
			MPY_SHn, RST_MULT: IN STD_LOGIC; --MOLTIPLICATORE
			RST_SH, LE_SH : IN STD_LOGIC; --REGISTRO USCITA SHIFT
			RST_MPY, LE_MPY: IN STD_LOGIC;--REGISTRO USCITA MOLTIPLICATORE
			MUX_SUM: IN STD_LOGIC; --MUX INGRESSO SOMMATORE
			MUX_SUB1: IN STD_LOGIC; --MUX INGRESSO1 SOTTRATTORE
			MUX_SUB2: IN STD_LOGIC_VECTOR(1 DOWNTO 0); --MUX INGRESSO2 SOTTRATTORE
			RST_SUB, LE_SUB: IN STD_LOGIC; --REGISTRO USCITA SOTTRATTORE
			RST_SUM, LE_SUM: IN STD_LOGIC; --REGISTRO USCITA SOMMATORE
			MUX_ROUND, EN_ROUND: IN STD_LOGIC; --ROM ROUNDING + MUX INGRESSO
			RST_RNDREG, LE_RNDREG: IN STD_LOGIC; --REG PER ROUNDING
			RST_A,LE_A: IN STD_LOGIC;
			RST_A1,LE_A1: IN STD_LOGIC;
			RST_B,LE_B: IN STD_LOGIC;
			OUT_A, OUT_B : OUT SIGNED (23 DOWNTO 0));
END butterfly_dp;

ARCHITECTURE Behaviour OF butterfly_dp IS

--componenti
COMPONENT multiplier 
GENERIC(N : integer:=8);
PORT(A,B: IN SIGNED(N-1 DOWNTO 0);
		clock, reset, MPY_SHn: IN STD_LOGIC;
		p: OUT SIGNED(2*N-1 DOWNTO 0);
		shift_out: OUT SIGNED(N DOWNTO 0));
END COMPONENT;
	
COMPONENT adder 
GENERIC(N : integer:=8);
PORT(a,b: IN SIGNED(N-1 DOWNTO 0);
		s: OUT SIGNED(N-1 DOWNTO 0)
		);
END COMPONENT;

COMPONENT rise_register 
  GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN SIGNED(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
				 data_out : OUT SIGNED(N-1 DOWNTO 0));
END COMPONENT;
	
COMPONENT mux2to1 
	GENERIC (N : INTEGER:=10);
		PORT( input1 : IN SIGNED (N-1 DOWNTO 0);
				input2 : IN SIGNED (N-1 DOWNTO 0);
				sel	 : IN STD_LOGIC;
				output : OUT SIGNED (N-1 DOWNTO 0));
END COMPONENT;

COMPONENT mux3to1 
GENERIC (N : INTEGER:=10);
	PORT( input1 : IN SIGNED (N-1 DOWNTO 0);
			input2 : IN SIGNED (N-1 DOWNTO 0);
			input3 : IN SIGNED (N-1 DOWNTO 0);
			sel	 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			output : OUT SIGNED (N-1 DOWNTO 0));
END COMPONENT;

COMPONENT subtractor 
GENERIC(N : integer:=8);
PORT(a,b: IN SIGNED(N-1 DOWNTO 0);
		s: OUT SIGNED(N-1 DOWNTO 0));
END COMPONENT;	

COMPONENT ROM_rounding
GENERIC (	N     : POSITIVE := 2);
PORT       (ADDR            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				CLOCK				 : IN STD_LOGIC;
            EN					 : IN STD_LOGIC;
				ROM_OUT         : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END COMPONENT;

COMPONENT reg_file IS
  GENERIC (
    N     : POSITIVE := 24        --Numero bit riga
	 );
  PORT(
    outA         : OUT SIGNED(N-1 DOWNTO 0);
    outB         : OUT SIGNED(N-1 DOWNTO 0);
    inputA       : IN  SIGNED(N-1 DOWNTO 0);
	 inputB       : IN  SIGNED(N-1 DOWNTO 0);
	 inSel        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    outSel       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
	 load_en      : IN STD_LOGIC;
	 reset        : IN  STD_LOGIC;
	 Clk          : IN STD_LOGIC
    );
END COMPONENT;

COMPONENT Reg_file_W IS
	GENERIC (
		N     : POSITIVE := 24 --num bit riga
		);
	PORT    (ADDR_OUT       : IN STD_LOGIC;
				INPUT1			:IN SIGNED(N-1 DOWNTO 0);
				INPUT2			:IN SIGNED(N-1 DOWNTO 0);
				CLOCK				: IN STD_LOGIC;
				RESET				: IN STD_LOGIC;
            LOAD_EN			: IN STD_LOGIC;
				REG_OUT        : OUT SIGNED(N-1 DOWNTO 0));
END COMPONENT;

SIGNAL out_w, out_1, out_2: SIGNED(23 DOWNTO 0);
SIGNAL mpy_in,shift_in: SIGNED(48 DOWNTO 0);
SIGNAL p_out: SIGNED(47 DOWNTO 0);
SIGNAL s_out: SIGNED(24 DOWNTO 0);
SIGNAL shift_out, mpy_out: SIGNED(48 DOWNTO 0);
SIGNAL mux_sum_out, mux_sum_in1: SIGNED(48 DOWNTO 0);
SIGNAL sum_in, sum_out: SIGNED(48 DOWNTO 0);
SIGNAL mux_sub1_out, mux_sub2_out: SIGNED(48 DOWNTO 0);
SIGNAL sub_in, sub_out: SIGNED(48 DOWNTO 0);
SIGNAL mux_rnd_out: SIGNED(48 DOWNTO 0);
SIGNAL mux_rnd_out_std: STD_LOGIC_VECTOR(48 DOWNTO 0);
SIGNAL rnd_out: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL val_rounded: STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL val_to_round: SIGNED(21 DOWNTO 0);
SIGNAL reg_out_in: SIGNED(23 DOWNTO 0);
SIGNAL a_out: SIGNED(23 DOWNTO 0);

	BEGIN
	
	--register file Ar Ai Br Bi
	register_file: reg_file GENERIC MAP(N=>24)
		PORT MAP(outA=>out_1 , outB=>out_2 , inputA=>IN_A , inputB=>IN_B , inSel=>ADDR_IN , outSel=>ADDR_OUT , load_en=>LE_RF, reset=>RST_RF, Clk=>CLOCK);
	
	--register file Wr Wi
	register_file_W: Reg_file_W GENERIC MAP(N=>24)
		PORT MAP(ADDR_OUT=>ADDR_OUTW , INPUT1=>Wr , INPUT2=>Wi , CLOCK=>CLOCK , RESET=>RST_W , LOAD_EN=>LE_W , REG_OUT=>out_w);
	
	--moltiplicatore
	multip: multiplier GENERIC MAP (N=>24)
		PORT MAP (A=>out_1, B=>out_w, clock=>CLOCK, reset=>RST_MULT, MPY_SHn=>MPY_SHn, p=>p_out, shift_out=>s_out);
		
	mpy_in<= p_out(46 DOWNTO 0) & "00";
	shift_in<=s_out & "000000000000000000000000";
	
	shift_reg: rise_register GENERIC MAP (N=>49)
		PORT MAP (clock=>CLOCK, data_in=>shift_in, clear=> '0', reset=>RST_SH, LE=>LE_SH, data_out=>shift_out);
	
	mpy_reg: rise_register GENERIC MAP (N=>49)
		PORT MAP (clock=>CLOCK, data_in=>mpy_in, clear=> '0', reset=>RST_MPY, LE=>LE_MPY, data_out=>mpy_out);
	
	--sommatore
	mux_sum_in1<=out_2 & "0000000000000000000000000"; --estensione di segno
	
	mux_add: mux2to1 GENERIC MAP (N=>49)
		PORT MAP (input1=>sum_out, input2=>mux_sum_in1, sel=>MUX_SUM, output=>mux_sum_out);
	
	add: adder GENERIC MAP (N=>49)
		PORT MAP (a=>mpy_out, b=>mux_sum_out, s=>sum_in);
	
	sum_reg: rise_register GENERIC MAP (N=>49)
		PORT MAP (clock=>CLOCK, data_in=>sum_in, clear=> '0', reset=>RST_SUM, LE=>LE_SUM, data_out=>sum_out);

	--sottrattore 
	muxA_sub: mux2to1 GENERIC MAP (N=>49)
		PORT MAP (input1=>sum_out, input2=>shift_out, sel=>MUX_SUB1, output=>mux_sub1_out);
		
	muxB_sub: mux3to1 GENERIC MAP (N=>49)
		PORT MAP (input1=>sum_out, input2=>mpy_out, input3=>sub_out, sel=>MUX_SUB2, output=>mux_sub2_out );
		
	sub: subtractor GENERIC MAP (N=>49)
		PORT MAP (a=>mux_sub1_out, b=>mux_sub2_out, s=>sub_in);
		
	sub_reg: rise_register GENERIC MAP (N=>49)
		PORT MAP (clock=>CLOCK, data_in=>sub_in, clear=> '0', reset=>RST_SUB, LE=>LE_SUB, data_out=>sub_out);
		
	--ROM rounding
	mux_rom:	mux2to1 GENERIC MAP (N=>49)
		PORT MAP (input1=>sum_out, input2=>sub_out, sel=>MUX_ROUND, output=>mux_rnd_out); 
		
	mux_rnd_out_std<=STD_LOGIC_VECTOR(mux_rnd_out);
		
	rnd_reg: rise_register GENERIC MAP (N=>22)
		PORT MAP (clock=>CLOCK, data_in=>SIGNED(mux_rnd_out_std(48 DOWNTO 27)), clear=> '0', reset=>RST_RNDREG, LE=>LE_RNDREG, data_out=>val_to_round);
	
	rom_round: ROM_rounding GENERIC MAP (N=>2)
		PORT MAP (ADDR=>mux_rnd_out_std(26 DOWNTO 24), CLOCK=>CLOCK, EN=>EN_ROUND, ROM_OUT=>rnd_out);
	
	val_rounded<=STD_LOGIC_VECTOR(val_to_round) & rnd_out;
	reg_out_in<=SIGNED(val_rounded);
	
	--uscite 
	A_reg: rise_register GENERIC MAP (N=>24)
		PORT MAP (clock=>CLOCK, data_in=>reg_out_in, clear=> '0', reset=>RST_A, LE=>LE_A, data_out=>a_out);
		
	B_reg: rise_register GENERIC MAP (N=>24)
		PORT MAP (clock=>CLOCK, data_in=>reg_out_in, clear=> '0', reset=>RST_B, LE=>LE_B, data_out=>OUT_B);
		
	A1_reg: rise_register GENERIC MAP (N=>24)
		PORT MAP (clock=>CLOCK, data_in=>a_out, clear=> '0', reset=>RST_A1, LE=>LE_A1, data_out=>OUT_A);
		
END Behaviour;