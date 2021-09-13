library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux2to1_1bit IS 
	PORT(x,y,s : IN STD_LOGIC; 
			m : OUT STD_LOGIC);
END mux2to1_1bit;


ARCHITECTURE Behavior OF mux2to1_1bit IS
	BEGIN 
		 m <= (NOT (s) AND x) OR (s AND y);
END Behavior;