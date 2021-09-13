LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY adder_u IS
GENERIC(N : integer:=8);
PORT(a,b: IN UNSIGNED(N-1 DOWNTO 0);
		s: OUT UNSIGNED(N-1 DOWNTO 0)
		);
END adder_u;

ARCHITECTURE Structure OF adder_u IS 

BEGIN 

s<=a+b;

END Structure;