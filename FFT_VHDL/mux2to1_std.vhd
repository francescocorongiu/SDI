library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux2to1_std IS 
GENERIC (N : INTEGER:=10);
	PORT( input1 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
			input2 : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
			sel	 : IN STD_LOGIC;
			output : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END mux2to1_std;


ARCHITECTURE Behavior OF mux2to1_std IS
	BEGIN 
		 output <= input1 WHEN (sel = '0') ELSE
					  input2 WHEN (sel = '1');

END Behavior;