library IEEE;
use IEEE.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY FFT IS

	PORT( CLOCK : IN STD_LOGIC;
			START: IN STD_LOGIC;
			RESET: IN STD_LOGIC;
			Xt: IN STD_LOGIC_VECTOR(383 DOWNTO 0);
			--A: IN STD_LOGIC_VECTOR(191 DOWNTO 0);  --24 bit * 8
			--B: IN STD_LOGIC_VECTOR(191 DOWNTO 0);
			Xf: OUT STD_LOGIC_VECTOR(383 DOWNTO 0);
			--A1:OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
			--B1: OUT STD_LOGIC_VECTOR(191 DOWNTO 0);
			DONE: OUT STD_LOGIC
			);
END FFT;

ARCHITECTURE Behaviour OF FFT IS

COMPONENT Butterfly_final IS

	PORT( CLOCK : IN STD_LOGIC;
			START: IN STD_LOGIC;
			RESET: IN STD_LOGIC;
			W: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
			A: IN SIGNED(23 DOWNTO 0);
			B: IN SIGNED(23 DOWNTO 0);
			A1:OUT SIGNED(23 DOWNTO 0);
			B1: OUT SIGNED(23 DOWNTO 0);
			DONE: OUT STD_LOGIC
			);
END COMPONENT;

COMPONENT reg IS
  GENERIC (N : INTEGER:=10);
		PORT ( clock : IN STD_LOGIC;
				 data_in : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
				 clear, reset, LE: IN STD_LOGIC;  --Enable = load enable
				 data_out : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END COMPONENT;

TYPE W_type IS ARRAY (0 TO 7) of STD_LOGIC_VECTOR(23 DOWNTO 0);
TYPE Sample_type IS ARRAY (0 TO 7) of SIGNED(23 DOWNTO 0);
TYPE DONE_type IS ARRAY (0 TO 31) of STD_LOGIC;
TYPE Twiddle IS ARRAY (0 TO 7) of STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL w_re_coeff: W_type;
SIGNAL w_im_coeff: W_type;
SIGNAL DONE_sgn1,DONE_sgn2,DONE_sgn3,DONE_sgn4: DONE_type;
SIGNAL DS1,DS2,DS3,DS4: STD_LOGIC;
SIGNAL twidf: Twiddle;
SIGNAL A_sample1: Sample_type;
SIGNAL B_sample1: Sample_type;
SIGNAL A_sample2: Sample_type;
SIGNAL B_sample2: Sample_type;
SIGNAL A_sample3: Sample_type;
SIGNAL B_sample3: Sample_type;
SIGNAL A_sample4: Sample_type;
SIGNAL B_sample4: Sample_type;

BEGIN

--registri per i coefficienti W
w_0re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"011111111111111111111111", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(0)); --1

w_1re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"011101100100000110101111", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(1)); --0.92387953251129

w_2re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"010110101000001001111010", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(2)); --0.70710678118655

w_3re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"001100001111101111000101", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(3)); --0.38268343236509
		
w_4re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"000000000000000000000000", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(4)); --0
		
w_5re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"110011110000010000111011", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(5)); --(-0.38268343236509)
		
w_6re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"101001010111110110000110", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(6)); --(-0.70710678118655)
		
w_7re : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"100010011011111001010001", clear=>'0', reset=>'0', LE=>'1', data_out=>w_re_coeff(7)); --(-0.92387953251129)
		
w_0im : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"000000000000000000000000", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(0)); --0
		
w_1im : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"110011110000010000111011", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(1)); --(-0.38268343236509)
		
w_2im : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"101001010111110110000110", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(2)); --(-0.70710678118655)
		
w_3im : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"100010011011111001010001", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(3));  --(-0.92387953251129)
		
w_4im : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"100000000000000000000000", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(4)); --(-1)
		
w_5im : reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"100010011011111001010001", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(5)); --(-0.92387953251129)
		
w_6im: reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"101001010111110110000110", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(6)); --(-0.70710678118655)
		
w_7im: reg GENERIC MAP(N=>24) 
		PORT MAP (clock=>CLOCK, data_in=>"110011110000010000111011", clear=>'0', reset=>'0', LE=>'1', data_out=>w_im_coeff(7)); --(-0.38268343236509)

twidf(0)<=w_re_coeff(0) & w_im_coeff(0); 
twidf(1)<=w_re_coeff(1) & w_im_coeff(1); 
twidf(2)<=w_re_coeff(2) & w_im_coeff(2); 
twidf(3)<=w_re_coeff(3) & w_im_coeff(3); 
twidf(4)<=w_re_coeff(4) & w_im_coeff(4); 
twidf(5)<=w_re_coeff(5) & w_im_coeff(5); 
twidf(6)<=w_re_coeff(6) & w_im_coeff(6); 
twidf(7)<=w_re_coeff(7) & w_im_coeff(7); 	

--PRIMO STADIO

btf_0: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(383 DOWNTO 360)), 
											B=>SIGNED(Xt(191 DOWNTO 168)), A1=>A_sample1(0), B1=>B_sample1(0), DONE=>DONE_sgn1(0));

btf_1: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(359 DOWNTO 336)), 
											B=>SIGNED(Xt(167 DOWNTO 144)), A1=>A_sample1(1), B1=>B_sample1(1), DONE=>DONE_sgn1(1));
											
btf_2: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(335 DOWNTO 312)), 
											B=>SIGNED(Xt(143 DOWNTO 120)), A1=>A_sample1(2), B1=>B_sample1(2), DONE=>DONE_sgn1(2));
										
btf_3: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(311 DOWNTO 288)), 
											B=>SIGNED(Xt(119 DOWNTO 96)), A1=>A_sample1(3), B1=>B_sample1(3), DONE=>DONE_sgn1(3));
										
btf_4: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(287 DOWNTO 264)), 
											B=>SIGNED(Xt(95 DOWNTO 72)), A1=>A_sample1(4), B1=>B_sample1(4), DONE=>DONE_sgn1(4));
											
btf_5: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(263 DOWNTO 240)), 
											B=>SIGNED(Xt(71 DOWNTO 48)), A1=>A_sample1(5), B1=>B_sample1(5), DONE=>DONE_sgn1(5));
											
btf_6: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(239 DOWNTO 216)), 
											B=>SIGNED(Xt(47 DOWNTO 24)), A1=>A_sample1(6), B1=>B_sample1(6), DONE=>DONE_sgn1(6));
											
btf_7: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>START, RESET=>RESET, W=>twidf(0), A=>SIGNED(Xt(215 DOWNTO 192)), 
											B=>SIGNED(Xt(23 DOWNTO 0)), A1=>A_sample1(7), B1=>B_sample1(7), DONE=>DONE_sgn1(7));

DS1<=DONE_sgn1(0) AND DONE_sgn1(1) AND DONE_sgn1(2) AND DONE_sgn1(3) AND DONE_sgn1(4) AND DONE_sgn1(5) AND DONE_sgn1(6) AND DONE_sgn1(7);											

--SECONDO STADIO

btf_8: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(0), A=>A_sample1(0), 
											B=>A_sample1(4), A1=>A_sample2(0), B1=>B_sample2(0), DONE=>DONE_sgn2(0));
				
btf_9: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(0), A=>A_sample1(1), 
											B=>A_sample1(5), A1=>A_sample2(1), B1=>B_sample2(1), DONE=>DONE_sgn2(1));

btf_10: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(0), A=>A_sample1(2), 
											B=>A_sample1(6), A1=>A_sample2(2), B1=>B_sample2(2), DONE=>DONE_sgn2(2));
											
btf_11: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(0), A=>A_sample1(3), 
											B=>A_sample1(7), A1=>A_sample2(3), B1=>B_sample2(3), DONE=>DONE_sgn2(3));
											
btf_12: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(4), A=>B_sample1(0), 
											B=>B_sample1(4), A1=>A_sample2(4), B1=>B_sample2(4), DONE=>DONE_sgn2(4));
											
btf_13: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(4), A=>B_sample1(1), 
											B=>B_sample1(5), A1=>A_sample2(5), B1=>B_sample2(5), DONE=>DONE_sgn2(5));
											
btf_14: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(4), A=>B_sample1(2), 
											B=>B_sample1(6), A1=>A_sample2(6), B1=>B_sample2(6), DONE=>DONE_sgn2(6));
											
btf_15: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS1, RESET=>RESET, W=>twidf(4), A=>B_sample1(3), 
											B=>B_sample1(7), A1=>A_sample2(7), B1=>B_sample2(7), DONE=>DONE_sgn2(7));

DS2<=DONE_sgn2(0) AND DONE_sgn2(1) AND DONE_sgn2(2) AND DONE_sgn2(3) AND DONE_sgn2(4) AND DONE_sgn2(5) AND DONE_sgn2(6) AND DONE_sgn2(7);

--TERZO STADIO

btf_16: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(0), A=>A_sample2(0), 
											B=>A_sample2(2), A1=>A_sample3(0), B1=>B_sample3(0), DONE=>DONE_sgn3(0));
				
btf_17: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(0), A=>A_sample2(1), 
											B=>A_sample2(3), A1=>A_sample3(1), B1=>B_sample3(1), DONE=>DONE_sgn3(1));

btf_18: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(4), A=>B_sample2(0), 
											B=>B_sample2(2), A1=>A_sample3(2), B1=>B_sample3(2), DONE=>DONE_sgn3(2));
											
btf_19: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(4), A=>B_sample2(1), 
											B=>B_sample2(3), A1=>A_sample3(3), B1=>B_sample3(3), DONE=>DONE_sgn3(3));
											
btf_20: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(2), A=>A_sample2(4), 
											B=>A_sample2(6), A1=>A_sample3(4), B1=>B_sample3(4), DONE=>DONE_sgn3(4));
											
btf_21: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(2), A=>A_sample2(5), 
											B=>A_sample2(7), A1=>A_sample3(5), B1=>B_sample3(5), DONE=>DONE_sgn3(5));
											
btf_22: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(6), A=>B_sample2(4), 
											B=>B_sample2(6), A1=>A_sample3(6), B1=>B_sample3(6), DONE=>DONE_sgn3(6));
											
btf_23: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS2, RESET=>RESET, W=>twidf(6), A=>B_sample2(5), 
											B=>B_sample2(7), A1=>A_sample3(7), B1=>B_sample3(7), DONE=>DONE_sgn3(7));

DS3<=DONE_sgn3(0) AND DONE_sgn3(1) AND DONE_sgn3(2) AND DONE_sgn3(3) AND DONE_sgn3(4) AND DONE_sgn3(5) AND DONE_sgn3(6) AND DONE_sgn3(7);

--QUARTO STADIO

btf_24: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(0), A=>A_sample3(0), 
											B=>A_sample3(1), A1=>A_sample4(0), B1=>B_sample4(0), DONE=>DONE_sgn4(0));
				
btf_25: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(4), A=>B_sample3(0), 
											B=>B_sample3(1), A1=>A_sample4(1), B1=>B_sample4(1), DONE=>DONE_sgn4(1));

btf_26: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(2), A=>A_sample3(2), 
											B=>A_sample3(3), A1=>A_sample4(2), B1=>B_sample4(2), DONE=>DONE_sgn4(2));
											
btf_27: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(6), A=>B_sample3(2), 
											B=>B_sample3(3), A1=>A_sample4(3), B1=>B_sample4(3), DONE=>DONE_sgn4(3));
											
btf_28: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(1), A=>A_sample3(4), 
											B=>A_sample3(5), A1=>A_sample4(4), B1=>B_sample4(4), DONE=>DONE_sgn4(4));
											
btf_29: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(5), A=>B_sample3(4), 
											B=>B_sample3(5), A1=>A_sample4(5), B1=>B_sample4(5), DONE=>DONE_sgn4(5));
											
btf_30: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(3), A=>A_sample3(6), 
											B=>A_sample3(7), A1=>A_sample4(6), B1=>B_sample4(6), DONE=>DONE_sgn4(6));
											
btf_31: Butterfly_final PORT MAP (CLOCK=>CLOCK, START=>DS3, RESET=>RESET, W=>twidf(7), A=>B_sample3(6), 
											B=>B_sample3(7), A1=>A_sample4(7), B1=>B_sample4(7), DONE=>DONE_sgn4(7));

DS4<=DONE_sgn4(0) AND DONE_sgn4(1) AND DONE_sgn4(2) AND DONE_sgn4(3) AND DONE_sgn4(4) AND DONE_sgn4(5) AND DONE_sgn4(6) AND DONE_sgn4(7);

DONE<=DS4;

Xf<=STD_LOGIC_VECTOR(A_sample4(0)) & STD_LOGIC_VECTOR(A_sample4(4)) & STD_LOGIC_VECTOR(A_sample4(2)) & STD_LOGIC_VECTOR(A_sample4(6)) & 
		STD_LOGIC_VECTOR(A_sample4(1)) & STD_LOGIC_VECTOR(A_sample4(5)) & STD_LOGIC_VECTOR(A_sample4(3)) & STD_LOGIC_VECTOR(A_sample4(7)) &
		STD_LOGIC_VECTOR(B_sample4(0)) & STD_LOGIC_VECTOR(B_sample4(4)) & STD_LOGIC_VECTOR(B_sample4(2)) & STD_LOGIC_VECTOR(B_sample4(6)) &
		STD_LOGIC_VECTOR(B_sample4(1)) & STD_LOGIC_VECTOR(B_sample4(5)) & STD_LOGIC_VECTOR(B_sample4(3)) & STD_LOGIC_VECTOR(B_sample4(7));

END Behaviour;