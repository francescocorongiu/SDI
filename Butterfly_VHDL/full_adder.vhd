LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY full_adder IS
PORT(a,b,ci: IN STD_LOGIC;
	  s,co: OUT STD_LOGIC);
END full_adder;

ARCHITECTURE Behavior OF full_adder IS

COMPONENT mux2to1_1bit 
	PORT(x,y,s : IN STD_LOGIC; 
			m : OUT STD_LOGIC);
END COMPONENT; 

SIGNAL ab_xor: STD_LOGIC;

BEGIN
ab_xor <= a XOR b;

SUM: s<= ci XOR ab_xor;

CARRY: mux2to1_1bit PORT MAP (x=>b,y=>ci,s=>ab_xor,m=>co);

END Behavior;

