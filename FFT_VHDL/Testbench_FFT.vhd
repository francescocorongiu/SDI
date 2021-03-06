library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Testbench_FFT IS
  END Testbench_FFT;

ARCHITECTURE Behavior OF Testbench_FFT IS

SIGNAL clk, rst, st, d: STD_LOGIC;
SIGNAL OUTf, INt: STD_LOGIC_VECTOR(383 DOWNTO 0);
SIGNAL r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15 : STD_LOGIC_VECTOR (23 DOWNTO 0);
SIGNAL out0, out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15: STD_LOGIC_VECTOR (23 DOWNTO 0);


COMPONENT FFT IS

	PORT( CLOCK : IN STD_LOGIC;
			START: IN STD_LOGIC;
			RESET: IN STD_LOGIC;
			Xt: IN STD_LOGIC_VECTOR(383 DOWNTO 0);
			--A: IN STD_LOGIC_VECTOR(191 DOWNTO 0);  --24 bit * 8
			--B: IN STD_LOGIC_VECTOR(191 DOWNTO 0);
			Xf: OUT STD_LOGIC_VECTOR(383 DOWNTO 0);
			--A1:OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
			--B1: OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
			DONE: OUT STD_LOGIC
			);
END COMPONENT;


BEGIN

 -- CLK: clk_gen port map(clock,RESET);
 
clck : PROCESS
	BEGIN
	clk <= '1';
	wait for 20 ns;
	clk <= '0';
	wait for 20 ns;


   END PROCESS;

rset : PROCESS
	BEGIN
	rst <= '1';
	wait for 100 ns;
	rst <= '0';
	wait;
   END PROCESS;


run : PROCESS
  BEGIN

  r0<="000000000000000000000000";
  r1<="000000000000000000000000";
  r2<="000000000000000000000000";
  r3<="000000000000000000000000";
  r4<="000000000000000000000000";
  r5<="000000000000000000000000";
  r6<="000000000000000000000000";
  r7<="000000000000000000000000";
  r8<="000000000000000000000000";
  r9<="000000000000000000000000";
  r10<="000000000000000000000000";
  r11<="000000000000000000000000";
  r12<="000000000000000000000000";
  r13<="000000000000000000000000";
  r14<="000000000000000000000000";
  r15<="000000000000000000000000";

  st<='0';

  wait for 300 ns;

  st<='1';
  wait for 40 ns;

  --REALI
  r0<="000001000000000000000000";
  r1<="000000000000000000000000";
  r2<="000000000000000000000000";
  r3<="000000000000000000000000";
  r4<="000000000000000000000000";
  r5<="000000000000000000000000";
  r6<="000000000000000000000000";
  r7<="000000000000000000000000";
  r8<="000000000000000000000000";
  r9<="000000000000000000000000";
  r10<="000000000000000000000000";
  r11<="000000000000000000000000";
  r12<="000000000000000000000000";
  r13<="000000000000000000000000";
  r14<="000000000000000000000000";
  r15<="000000000000000000000000";
  
  st<='0';

  wait for 40 ns;
  
  --IMMAGINARI
  r0<="000000000000000000000000";
  r1<="000000000000000000000000";
  r2<="000000000000000000000000";
  r3<="000000000000000000000000";
  r4<="000000000000000000000000";
  r5<="000000000000000000000000";
  r6<="000000000000000000000000";
  r7<="000000000000000000000000";
  r8<="000000000000000000000000";
  r9<="000000000000000000000000";
  r10<="000000000000000000000000";
  r11<="000000000000000000000000";
  r12<="000000000000000000000000";
  r13<="000000000000000000000000";
  r14<="000000000000000000000000";
  r15<="000000000000000000000000";
  
 wait;
END PROCESS;

FFT1: FFT PORT MAP( CLOCK=>clk, START=>st, RESET=>rst, Xt=>INt, Xf=>OUTf , DONE=>d);

INt<=r15&r14&r13&r12&r11&r10&r9&r8&r7&r6&r5&r4&r3&r2&r1&r0;

out15<=OUTf(23 DOWNTO 0);
out14<=OUTf(47 DOWNTO 24);
out13<=OUTf(71 DOWNTO 48);
out12<=OUTf(95 DOWNTO 72);
out11<=OUTf(119 DOWNTO 96);
out10<=OUTf(143 DOWNTO 120);
out9<=OUTf(167 DOWNTO 144);
out8<=OUTf(191 DOWNTO 168);
out7<=OUTf(215 DOWNTO 192);
out6<=OUTf(239 DOWNTO 216);
out5<=OUTf(263 DOWNTO 240);
out4<=OUTf(287 DOWNTO 264);
out3<=OUTf(311 DOWNTO 288);
out2<=OUTf(335 DOWNTO 312);
out1<=OUTf(359 DOWNTO 336);
out0<=OUTf(383 DOWNTO 360);

END Behavior;
