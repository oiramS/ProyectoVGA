LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

ENTITY vga_rgb IS
PORT(CLK, CLK_MASTER, RST: IN STD_LOGIC;
	  HSYNC, VSYNC: OUT STD_LOGIC;
	  CLIC_DER : IN STD_LOGIC;
	  R, G, B: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- SALIDAS PARA TARJETA DE-10 LITE
END vga_rgb;

ARCHITECTURE COMPORTAMIENTO OF vga_rgb IS
-- VALORES PARA MONITOR DE 640X480
CONSTANT HD: INTEGER := 639; -- PANTALLA HORIZONTAL (640)
CONSTANT VD: INTEGER := 479; -- PANTALLA VERTICAL (480)

CONSTANT HFP: INTEGER := 16; -- BORDE DERECHO (FRONT PORCH)
CONSTANT HSP: INTEGER := 96; -- SINCRONIZACION
CONSTANT HBP: INTEGER := 48; -- BORDE IZQUIERDO (BACK PORCH)

CONSTANT VFP: INTEGER := 10; -- BORDE DERECHO (FRONT PORCH)
CONSTANT VSP: INTEGER := 2; --  SINCRONIZACION
CONSTANT VBP: INTEGER := 33; -- BORDE IZQUIERDO (BACK PORCH)

CONSTANT LIM : INTEGER := 75; --TAMAÑO DE LA MEMORIA

SIGNAL HPOS: INTEGER := 0; -- BARRIDO HORIZONTAL
SIGNAL VPOS: INTEGER := 0; --  BARRIDO VERTICAL

SIGNAL VIDEO: STD_LOGIC := '0'; -- ACTIVAION DE SALIDA DE VIDEO

SIGNAL X_DESP : INTEGER RANGE 0 TO 639 := 100;
SIGNAL Y_DESP : INTEGER RANGE 0 TO 480 := 100;

Signal X_POS	: INTEGER RANGE 0 TO 4095 := 0;
Signal Y_POS	: INTEGER RANGE 0 TO 4095 := 0;

Signal s_ch0	: std_logic_vector (11 downto 0);
Signal s_ch1	: std_logic_vector (11 downto 0);

--MEMORIA RAM
type mat is array(LIM downto 0, LIM downto 0) of INTEGER RANGE 0 TO 10;
signal mem : mat := (others => (others => 0));

--COLOR
SIGNAL CURCOLOR : INTEGER RANGE 0 TO 10 := 4;

--DATOS 
SIGNAL DATCOLOR : INTEGER RANGE 0 TO 10 := 0;

TYPE ESTADOS IS (INICIO, ARRIBA, ABAJO, IZQUIERDA, DERECHA, ESPERA);
SIGNAL PRESENTE : ESTADOS := INICIO;

component ADC is
		port (
			CLOCK : in  std_logic                     := '0'; --      clk.clk
			CH0   : out std_logic_vector(11 downto 0);        -- readings.CH0
			CH1   : out std_logic_vector(11 downto 0);        --         .CH1
			RESET : in  std_logic                     := '0'  --    reset.reset
		);
	end component ADC;

BEGIN

	ADC2 : ADC port map(
			CLK_MASTER,
			s_ch0,
			s_ch1,
			RST
		);

	DECO_VOLTAJES : process(s_ch0, s_ch1)
		begin
			X_POS <= to_integer(unsigned(s_ch0));
			Y_POS <= to_integer(unsigned(s_ch1));
	end process;
	
	MEMORIA: PROCESS(CLK, RST, CLIC_DER, X_DESP, Y_DESP, HPOS, VPOS)
	VARIABLE CONT_X, CONT_Y : INTEGER RANGE 0 TO 639 := 0;
	BEGIN
		IF(RST = '1') THEN
			mem <= (others => (others => 0));
		ELSIF RISING_EDGE(CLK) THEN
			IF(X_DESP < LIM AND Y_DESP < LIM) THEN
				IF(CLIC_DER = '0') THEN
					mem(X_DESP, Y_DESP) <= CURCOLOR;
				END IF;
			END IF;
		END IF;
		
	END PROCESS;
	
	CONTROL_JOYSTICK : PROCESS(CLK, RST, X_POS, Y_POS)
	VARIABLE CONTADOR : INTEGER RANGE 0 TO 1_000_000 := 0;
	BEGIN 
		IF(RST = '1') THEN
			CONTADOR := 0;
			PRESENTE <= INICIO;
			X_DESP <= 100;
			Y_DESP <= 100;
		ELSIF(RISING_EDGE(CLK)) THEN
			CASE (PRESENTE) IS 
				WHEN INICIO =>
					IF(X_POS > 1800 AND X_POS < 2000 AND Y_POS > 1800 AND Y_POS < 2000) THEN
						PRESENTE <= INICIO;
					ELSIF(X_POS > 2000) THEN
						PRESENTE <= DERECHA;
					ELSIF(X_POS < 1800) THEN
						PRESENTE <= IZQUIERDA;
					ELSIF(Y_POS > 2000) THEN
						PRESENTE <= ARRIBA;
					ELSIF(Y_POS < 1800) THEN
						PRESENTE <= ABAJO;
					ELSE
						PRESENTE <= INICIO;
					END IF;
				WHEN ABAJO => -- --
					IF(Y_DESP < 250) THEN
						Y_DESP <= Y_DESP + 1;
					ELSE
						Y_DESP <= 0;
					END IF;
					PRESENTE <= ESPERA;
				WHEN ARRIBA =>
					IF(Y_DESP > 0) THEN 
						Y_DESP <= Y_DESP - 1;
					ELSE 
						Y_DESP <= 250;
					END IF;
					PRESENTE <= ESPERA;
				WHEN IZQUIERDA =>
					IF(X_DESP > 0) THEN
						X_DESP <= X_DESP - 1;
					ELSE 
						X_DESP <= 250;
					END IF;
					PRESENTE <= ESPERA;
				WHEN DERECHA => 
					IF(X_DESP < 250) THEN
						X_DESP <= X_DESP + 1;
					ELSE 
						X_DESP <= 0;
					END IF;
					PRESENTE <= ESPERA;
				WHEN ESPERA =>
					IF(CONTADOR = 1_000_000) THEN
						CONTADOR := 0;
						PRESENTE <= INICIO;
					ELSE 
						CONTADOR := CONTADOR + 1;
					END IF;
			END CASE;
		END IF;
	END PROCESS;

	--X_DESP += 10;
	--
	CONT_H : PROCESS(CLK, RST) -- CONTADOR HORIZONTAL
	BEGIN
		IF RST = '1' THEN
			HPOS <= 0;
			ELSIF RISING_EDGE (CLK) THEN
				IF HPOS = (HD + HFP + HSP + HBP) THEN -- HPOS = 799
					HPOS <= 0;
				ELSE
					HPOS <= HPOS + 1;
				END IF;
			END IF;		
	END PROCESS;
	
	CONT_V : PROCESS(CLK, RST, HPOS) -- CONTADOR VERTICAL
	BEGIN
		IF RST = '1' THEN
			VPOS <= 0;
			ELSIF RISING_EDGE (CLK) THEN
				IF HPOS = (HD + HFP + HSP + HBP) THEN
					IF VPOS = (VD + VFP + VSP + VBP) THEN --VPOS = 524
						VPOS <= 0;
					ELSE
						VPOS <= VPOS + 1;
					END IF;
				END IF;	
			END IF;
	END PROCESS;
	
	H_SYNC : PROCESS(CLK, RST, HPOS) -- SINCRONIZACION HORIZONTAL
	BEGIN
		IF RST = '1' THEN
			HSYNC <= '0';
		ELSIF FALLING_EDGE(CLK) THEN
			IF HPOS <= (HD + HFP) OR HPOS > (HD + HFP + HSP) THEN
				HSYNC <= '1';
			ELSE
				HSYNC <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	V_SYNC : PROCESS(CLK, RST, VPOS) -- SINCRONIZACION VERTICAL
	BEGIN
		IF RST = '1' THEN
			VSYNC <= '0';
		ELSIF FALLING_EDGE(CLK) THEN
			IF VPOS <= (VD + VFP) OR VPOS > (VD + VFP + VSP) THEN
				VSYNC <= '1';
			ELSE
				VSYNC <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	V_OUT: PROCESS(CLK, RST, HPOS, VPOS) -- SALIDA DE VIDEO
	BEGIN
		IF RST = '1' THEN
			VIDEO <= '0';
		ELSIF FALLING_EDGE(CLK) THEN
			IF HPOS <= HD AND VPOS <= VD THEN
				VIDEO <= '1';
			ELSE
				VIDEO <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	
	SELECTOR_COLOR : PROCESS(X_DESP, Y_DESP, CLIC_DER)
		BEGIN
			IF(CLIC_DER = '0') THEN
				IF (X_DESP >= 85 AND X_DESP <= 95 AND Y_DESP >= 10 AND Y_DESP <= 20) THEN 
					CURCOLOR <= 1;
				ELSIF(X_DESP >= 85 AND X_DESP <= 95 AND Y_DESP >= 25 AND Y_DESP <= 35) THEN
					CURCOLOR <= 2;
				ELSIF(X_DESP >= 85 AND X_DESP <= 95 AND Y_DESP >= 40 AND Y_DESP <= 50) THEN
					CURCOLOR <= 3;
				END IF;
			END IF;
	END PROCESS;
	
	-- PROCESO VALIDO PARA DE-10 LITE
	-- (X-295)^^2 + (Y-195)^^2 = (10)^^2
	FONDO : PROCESS (CLK, HPOS, VPOS, VIDEO,X_DESP, Y_DESP, RST) -- PROCESO PARA COLOREAR LOS PIXELES DEL FONDO
	VARIABLE COLORES : INTEGER RANGE 0 TO 7 := 0;
	BEGIN
		IF RST = '1' THEN
			R <= "0000";
			G <= "0000";
			B <= "0000";
		ELSIF FALLING_EDGE(CLK) THEN
			IF VIDEO = '1' THEN
				IF ((HPOS >= 0 AND HPOS <= 639) AND (VPOS >= 0 AND VPOS <= 479)) THEN
					IF ((HPOS - X_DESP)*(HPOS - X_DESP) + (VPOS- Y_DESP)*(VPOS - Y_DESP) <= 4) THEN -- PUNTERO
						R <= "0100";
						G <= "0100";
						B <= "0100";
					ELSIF(HPOS < LIM AND VPOS < LIM) then --CUADRO
						COLORES := mem(HPOS, VPOS);
						CASE COLORES IS 
							WHEN 0 =>
								R <= "1111";
								G <= "1111";
								B <= "1111";
							WHEN 1 =>
								R <= "1111";
								G <= "0000";
								B <= "0000";
							WHEN 2 =>
								R <= "0000";
								G <= "0000";
								B <= "1111";
							WHEN 3 => 
								R <= "0000";
								G <= "1111";
								B <= "0000";
							WHEN OTHERS =>
								R <= "0000";
								G <= "0000";
								B <= "0000";
						END CASE;
					ELSIF (HPOS >= 0 AND HPOS <= 150)AND (VPOS >= 0  AND VPOS <= 150) THEN --FONDO
						IF (HPOS >=85 AND HPOS <= 95 AND VPOS >= 10 AND VPOS <= 20) THEN 
							R <= "1111";
							G <= "0000";
							B <= "0000";
						ELSIF(HPOS >=85 AND HPOS <= 95 AND VPOS >= 25 AND VPOS <= 35) THEN
							R <= "0000";
							G <= "0000";
							B <= "1111";
						ELSIF(HPOS >=85 AND HPOS <= 95 AND VPOS >= 40 AND VPOS <= 50) THEN
							R <= "0000";
							G <= "1111";
							B <= "0000";
						ELSE --FONDO FONDO
							R <= "0000";
							G <= "0000";
							B <= "0000";
						END IF;
					ELSE -- PARTE DE LA PANTALLA QUE NO SE UTILIZA
						R <= "0111";
						G <= "0111";
						B <= "0111";
					END IF;				
				END IF;
			ELSE 
				R <= "0000";
				G <= "0000";
				B <= "0000";
			END IF;
		END IF;
	END PROCESS;
	
	
END COMPORTAMIENTO;