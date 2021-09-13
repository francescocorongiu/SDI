LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ROM_rounding IS
GENERIC (
    N     : POSITIVE := 2 --num bit riga
	 );
PORT       (ADDR            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
				CLOCK				 : IN STD_LOGIC;
            EN					 : IN STD_LOGIC;
				ROM_OUT         : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END ROM_rounding;

ARCHITECTURE Behavior OF ROM_rounding IS



TYPE Rom_type IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(N-1 DOWNTO 0);
constant rom8: Rom_type:=(	   "00", --000          --8 elementi della rom da 2 bit ciascuno
										"01", --001
										"01", --010
										"10", --011
										"10", --100
										"11", --101
										"11", --110
										"11" --111
								);

BEGIN
PROCESS(CLOCK)
	BEGIN
	IF(CLOCK'EVENT AND CLOCK='1')THEN
		IF(EN='1')THEN
		 ROM_OUT<=rom8(to_integer(unsigned(ADDR)));
		END IF;
	END IF;
END PROCESS;

END Behavior;