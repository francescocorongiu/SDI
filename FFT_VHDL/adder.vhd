LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY adder IS
GENERIC(N : integer:=8);
PORT(a,b: IN SIGNED(N-1 DOWNTO 0);
		s: OUT SIGNED(N-1 DOWNTO 0)
		);
END adder;

ARCHITECTURE Structure OF adder IS
BEGIN

s<=a+b;

END Structure;
