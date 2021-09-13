library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY start_jump IS
	PORT( clock: IN STD_LOGIC;
			reset: IN STD_LOGIC;
			addr: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			cc: IN STD_LOGIC;
			start: IN STD_LOGIC;
			sel_addr: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
			);
END start_jump;


ARCHITECTURE Behavior OF start_jump IS
	SIGNAL sel: STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL idlestate: STD_LOGIC;
--	SIGNAL sgn,lastinstruction  : STD_LOGIC;
--	SIGNAL add : STD_LOGIC_VECTOR (2 DOWNTO 0);

--type Rom_type is array (0 to 7) of std_logic_vector(1 downto 0);
--
--constant rom: Rom_type:=(  "00",
--									"10",
--									"00",		
--									"00",
--									"00",
--									"00",
--									"01",	
--									"01" );

	BEGIN
	  
	idlestate<=NOT(addr(4)) AND NOT(addr(3)) AND NOT(addr(2)) AND NOT(addr(1)) AND NOT(addr(0));
--	lastinstruction<= NOT(addr(4)) AND (addr(3)) AND (addr(2)) AND NOT(addr(1)) AND NOT(addr(0));
--
--	sgn <= idlestate NOR lastinstruction;
--	add <= start&cc&sgn;
--	
--	PROCESS(clock)
--	BEGIN
--		IF(clock'EVENT AND clock='1')THEN
--			sel_addr<=rom(to_integer(unsigned(add)));
--		END IF;
--	END PROCESS;
	
	PROCESS(reset,start,cc,addr,idlestate)
		BEGIN
		IF (reset='1') THEN
			sel<="10";
		ELSE
			IF(start='1' AND cc='0')THEN --inizio
			 sel<="00";
			ELSIF(start='0' AND cc='0') THEN --run
	       IF(idlestate='0')THEN 
			    IF(addr="01100")THEN
			     sel<="10";
			    ELSE
			      sel<="00";
			    END IF;
			  ELSE
			     sel<="10";
			  END IF;
			ELSIF(start='1' AND cc='1') THEN --jump
			 sel<="01";
			ELSIF(start='0' AND cc='1') THEN --no jump
			 sel<="00";
			ELSE
				sel<="10";
			END IF;
		END IF;
	END PROCESS;

sel_addr<=sel;
		
END Behavior;