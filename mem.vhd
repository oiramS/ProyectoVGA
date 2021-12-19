Library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity MEM is
	Port(cont: in integer range 0 to 1023;
		  salida: out integer range 0 to 255);
end entity;

architecture comportamiento of MEM is
type mem is array (0 to 1023) of integer range 0 to 255;
signal sen : mem := 
();
begin
		
	salida <= sen(cont);

end comportamiento;
