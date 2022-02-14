library ieee;
use ieee.std_logic_1164.all;

entity edge_det is
	port (
		clk    	: in  std_logic;
		inp  	: in  std_logic;
		det	   	: out std_logic
	);
end edge_det;

architecture behavioural of edge_det is

signal first	: std_logic;
signal second	: std_logic;


begin

det <= not second and first;

	reg: process(clk)
	begin
	
		if(rising_edge(clk)) then
		
				first   <= inp;
				second  <= first;
			
		end if;
		
	end process reg;

end behavioural;

