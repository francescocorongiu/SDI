library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
  generic (
    N     : positive := 24        --Numero bit riga
	 );
  port(
    outA         : out SIGNED(N-1 downto 0);
    outB         : out SIGNED(N-1 downto 0);
    inputA       : in  SIGNED(N-1 downto 0);
	 inputB       : in  SIGNED(N-1 downto 0);
	 inSel      : in  STD_LOGIC_VECTOR(1 downto 0);
    outSel      : in  STD_LOGIC_VECTOR(3 downto 0);
	 load_en     : in STD_LOGIC;
	 reset        : in  std_logic;
	 Clk          : in std_logic
    );
end reg_file;


architecture behavioral of reg_file is

COMPONENT rise_register 
  GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN SIGNED(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
				 data_out : OUT SIGNED(N-1 DOWNTO 0));
END COMPONENT;

COMPONENT mux4to1 IS
GENERIC(N : positive :=24);
PORT (w0, w1, w2, w3 : IN SIGNED(N-1 DOWNTO 0);
						 s : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
						 f : OUT SIGNED(N-1 DOWNTO 0));
END COMPONENT;

  SIGNAL en1, en2, en3, en4: STD_LOGIC;
  SIGNAL out1, out2, out3, out4: SIGNED(N-1 DOWNTO 0);

BEGIN

Reg_1: rise_register   generic map (N=>N)
								   	port map (data_in=>inputA, clock=>Clk, reset=>reset, LE=>en1, data_out=>out1, clear=>'0');
Reg_2: rise_register   generic map (N=>N)
								   	port map (data_in=>inputA, clock=>Clk, reset=>reset, LE=>en2, data_out=>out2, clear=>'0');
Reg_3: rise_register   generic map (N=>N)
								   	port map (data_in=>inputB, clock=>Clk, reset=>reset, LE=>en3, data_out=>out3, clear=>'0');
Reg_4: rise_register   generic map (N=>N)
								   	port map (data_in=>inputB, clock=>Clk, reset=>reset, LE=>en4, data_out=>out4, clear=>'0');
										
mux1: mux4to1 generic map (N=>N)
							  port map (w0=>out1, w1=>out2, w2=>out3, w3=>out4, s=>outSel(3 DOWNTO 2), f=>outA);
mux2: mux4to1 generic map (N=>N)
							  port map (w0=>out1, w1=>out2, w2=>out3, w3=>out4, s=>outSel(1 DOWNTO 0), f=>outB);

en1<=load_en AND inSel(1);
en2<=load_en AND inSel(0);
en3<=load_en AND inSel(1);
en4<=load_en AND inSel(0);


end behavioral;

