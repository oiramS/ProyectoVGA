Library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity MATRIX is
	Port(cont: in integer range 0 to 1023;
		  salida: out integer range 0 to 255);
end entity;

architecture comportamiento of MATRIX is
type mat is array(639 downto 0, 419 downto 0) of std_logic_vector(11 downto 0);
signal mem : mat;
begin
	process()
		begin
			for i in 0 to 639 loop
				for j in 0 to 419 loop
					mem(i)(j) <= "111111111111"
				end loop;
			end loop;
	end process;
end comportamiento;