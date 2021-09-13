LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux4to1 IS
GENERIC(N : positive :=24);
PORT (w0, w1, w2, w3 : IN SIGNED(N-1 DOWNTO 0);
						 s : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
						 f : OUT SIGNED(N-1 DOWNTO 0));
END mux4to1;

ARCHITECTURE Behavior OF mux4to1 IS
BEGIN
WITH s SELECT
	f <= w0 WHEN "00",
		  w1 WHEN "01",
		  w2 WHEN "10",
		  w3 WHEN OTHERS;
END Behavior;