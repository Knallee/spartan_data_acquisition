library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity debouncer is
port(
    clk 		: in std_logic;
    button_in 	: in std_logic;
    button_out 	: out std_logic
);
end entity; 

architecture behaviour of debouncer is

  signal count_in	: integer range 0 to 500000;  -- range to count for debouncing
  signal count_q 	: integer range 0 to 500000;  -- range to count for debouncing

begin
  
    reg: process (clk) is
    begin  
        
        if clk'event and clk = '1' then
		
                count_q <= count_in;
				
        end if;
    end process reg;

    comb: process (button_in, count_q) is
    begin
       
        count_in 	<= count_q;
        button_out 	<= '0';

        if button_in = '1' then
            if count_q < 500000 then
			
                count_in <= count_q + 1;
				
            else
			
                count_in <= 500000;
				
            end if;
        else
		
          count_in <= 0;
		  
        end if;

        if count_q = 500000 then
		
            button_out <= '1';
			
        end if;
		
    end process comb;
end architecture;

