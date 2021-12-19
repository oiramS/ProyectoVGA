LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

ENTITY CONTROL_JOYSTICK IS
	PORT(
	CLK: IN STD_LOGIC;
	X_POS: OUT INTEGER RANGE 0 TO 4095 := 0;
	Y_POS : OUT INTEGER RANGE 0 TO 4095 := 0);
END CONTROL_JOYSTICK;

ARCHITECTURE COMPORTAMIENTO OF CONTROL_JOYSTICK IS
	Signal s_ch0	: std_logic_vector (11 downto 0);
	Signal s_ch1	: std_logic_vector (11 downto 0);
	Signal s_ch2	: std_logic_vector (11 downto 0);
	Signal s_ch3	: std_logic_vector (11 downto 0);
	Signal s_ch4	: std_logic_vector (11 downto 0);
	Signal s_ch5	: std_logic_vector (11 downto 0);
	Signal s_ch6	: std_logic_vector (11 downto 0);
	Signal s_ch7	: std_logic_vector (11 downto 0);
	component merindo is
		port (
			CLOCK : in  std_logic                     := '0'; --      clk.clk
			CH0   : out std_logic_vector(11 downto 0);        -- readings.CH0
			CH1   : out std_logic_vector(11 downto 0);        --         .CH1
			CH2   : out std_logic_vector(11 downto 0);        --         .CH2
			CH3   : out std_logic_vector(11 downto 0);        --         .CH3
			CH4   : out std_logic_vector(11 downto 0);        --         .CH4
			CH5   : out std_logic_vector(11 downto 0);        --         .CH5
			CH6   : out std_logic_vector(11 downto 0);        --         .CH6
			CH7   : out std_logic_vector(11 downto 0);        --         .CH7
			RESET : in  std_logic                     := '0'  --    reset.reset
		);
	end component merindo; 
	
	BEGIN
		
	mrd2 : merindo port map(
			clk,
			s_ch0,
			s_ch1,
			s_ch2,
			s_ch3,
			s_ch4,
			s_ch5,
			s_ch6,
			s_ch7
		);
	
	DECO_VOLTAJES : process(s_ch0, s_ch1)
		begin
			x_pos <= to_integer(unsigned(s_ch0));
			y_pos <= to_integer(unsigned(s_ch1));
	end process;
	
		
END COMPORTAMIENTO;