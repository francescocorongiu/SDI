LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--registro di dimensioni generiche

ENTITY fall_register IS
  GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
				 data_out : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END fall_register;

ARCHITECTURE Behavior OF fall_register IS

SIGNAL stored : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
	BEGIN

	  PROCESS (clock, reset)
		  BEGIN
			IF (reset = '1') THEN
			 stored <= (OTHERS => '0'); --resetto valori nel registro
			ELSIF (clock'EVENT AND clock = '0') THEN
				IF CLEAR = '1' THEN
					stored <= (OTHERS => '0');
				ELSIF (LE = '1' ) THEN
					stored <= data_in; --modifico valore di Q se e presente un fronte di discesa
				END IF;
		  END IF;
	END PROCESS;

	data_out <= stored;

END Behavior;
