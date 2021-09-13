library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux3to1 IS
GENERIC (N : INTEGER:=10);
	PORT( input1 : IN SIGNED (N-1 DOWNTO 0);
			input2 : IN SIGNED (N-1 DOWNTO 0);
			input3 : IN SIGNED (N-1 DOWNTO 0);
			sel	 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			output : OUT SIGNED (N-1 DOWNTO 0));
END mux3to1;


ARCHITECTURE Behavior OF mux3to1 IS
	BEGIN
		 output <= input1 WHEN (sel = "00") ELSE
					  input2 WHEN (sel = "01") ELSE
					  input3;

END Behavior;
