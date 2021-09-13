library ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Testbench_butterfly_final IS
  END Testbench_butterfly_final;

ARCHITECTURE Behavior OF Testbench_butterfly_final IS

SIGNAL clk, rst, st, d: STD_LOGIC;
SIGNAL a_in,b_in : SIGNED (23 DOWNTO 0);
SIGNAL w_in: STD_LOGIC_VECTOR (47 DOWNTO 0);
SIGNAL a_out, b_out: SIGNED (23 DOWNTO 0);


COMPONENT Butterfly_final IS

	PORT( CLOCK : IN STD_LOGIC;
			START: IN STD_LOGIC;
			RESET: IN STD_LOGIC;
			W: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
			A: IN SIGNED(23 DOWNTO 0);
			B: IN SIGNED(23 DOWNTO 0);
			A1:OUT SIGNED(23 DOWNTO 0);
			B1: OUT SIGNED(23 DOWNTO 0);
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

  a_in<="000000000000000000000000";
  b_in<="000000000000000000000000";
  w_in<="000000000000000000000000000000000000000000000000";
  st<='0';

  wait for 300 ns;

  st<='1';
  wait for 40 ns;

  a_in<="000000000000010000011001"; --Ar
  b_in<="111111111111101011100001"; --Br
  w_in<="011111111111111111111111000000000000000000000000"; --Wr Wi
  st<='0';

  wait for 40 ns;
  a_in<="000000000000000100000110"; --Ai
  b_in<="000000000000011100101011"; --Bi
  


  wait;
END PROCESS;

FFT: Butterfly_final PORT MAP( CLOCK=>clk, RESET=>rst, START=>st, DONE=>d, A=>a_in, B=>b_in, W=>w_in, A1=>a_out, B1=>b_out);


END Behavior;
