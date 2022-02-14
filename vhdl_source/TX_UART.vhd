library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_UART is
	port(
		clk		 	 : in  std_logic;
		n_rst	 	 : in  std_logic;
		send	 	 : in  std_logic;
		tx		 	 : out std_logic;
		tx_done		 : out std_logic;
		byte_in  	 : in  std_logic_vector(7 downto 0)
	);
end tx_UART;

architecture Behavioral of tx_UART is

	type state is (sRST, sIDLE, sSTART, sTX, sSTOP);
	signal next_state : state;
	signal crnt_state : state;
	
	signal tx_data		  	: std_logic_vector(7 downto 0);
		
	signal next_tx_done		: std_logic;
	signal next_send_byte 	: std_logic_vector(7 downto 0);
	signal next_index	  	: integer range 0 to 9;
	signal next_uart_tx	  	: std_logic;
	signal next_clk_count 	: integer range 0 to 2000000;
	
	signal crnt_tx_done		: std_logic;
	signal crnt_send_byte 	: std_logic_vector(7 downto 0);
	signal crnt_index	  	: integer range 0 to 8;
	signal crnt_uart_tx	  	: std_logic;
	signal crnt_clk_count 	: integer range 0 to 2000000;
		
	-- constant MAX_COUNT	  	: integer range 0 to 2000000 := 10417; -- 9600 baud @ 100MHz
	-- constant MAX_COUNT	  	: integer range 0 to 2000000 := 868; -- 115200 baud @ 100MHz
	constant MAX_COUNT	  	: integer range 0 to 2000000 := 217; -- 115200 baud @ 25MHz

begin
	
	reg: process(clk) is
	begin

		if rising_edge(clk) then
		
			if n_rst = '0' then
				
				crnt_state 		<= sRST;
				
				crnt_tx_done	<= '0';
				crnt_send_byte  <= (others => '0');
				crnt_index	    <= 0;
				crnt_uart_tx	<= '1';
			    crnt_clk_count  <= 0;
				
			else 
				
				crnt_tx_done	<= next_tx_done;
				crnt_state 		<= next_state;
				crnt_send_byte  <= next_send_byte;
				crnt_index	    <= next_index;
				crnt_uart_tx	<= next_uart_tx;
				crnt_clk_count  <= next_clk_count;
			
			end if;
			
		end if;


	end process reg;

	
	tx 		<= crnt_uart_tx;
	tx_done	<= crnt_tx_done;

	comb: process(crnt_state, byte_in, crnt_clk_count, send, crnt_tx_done, crnt_send_byte, crnt_index, crnt_uart_tx) is
	begin

		next_state 		<= crnt_state;
		
		next_tx_done	<= crnt_tx_done;
		next_send_byte	<= crnt_send_byte;
		next_index	 	<= crnt_index;
		next_uart_tx	<= crnt_uart_tx;
		next_clk_count	<= crnt_clk_count;
		
		case crnt_state is
		
			when sRST =>
			
				next_state 		<= sIDLE;
				
				next_tx_done	<= '0';
				next_send_byte	<= (others => '0');
				next_index		<= 0;
				next_uart_tx	<= '1';
				next_clk_count	<= 0;
				
				
			when sIDLE => 
				
				next_index		<= 0;
				next_tx_done	<= '0';
				next_uart_tx	<= '1';
			
				if send = '1' then
					
					next_send_byte	<= byte_in;
					next_state	 	<= sSTART;
				
				else
				
					next_state <= sIDLE;
				
				end if;
			
			when sSTART =>
			
				if crnt_clk_count < MAX_COUNT then
					
					next_uart_tx 	<= '0';
					next_clk_count 	<= crnt_clk_count + 1;
					next_state		<= sSTART;
					
				else 
				
					next_clk_count 	<= 0;
					next_state 		<= sTX;
					
				end if;
			
			
			when sTX =>
				
				if crnt_index < 7 then
				
					if crnt_clk_count < MAX_COUNT then
					
						next_clk_count 	<= crnt_clk_count + 1;
						next_state		<= sTX;
						
					else 
					
						next_index		<= crnt_index + 1;
						next_clk_count 	<= 0;
						next_state 		<= sTX;
						
					end if;
					
					if crnt_send_byte(crnt_index) = '1' then
					
						next_uart_tx <= '1';
						
					else
					
						next_uart_tx <= '0';
						
					end if;
				
				else 
					
					if crnt_clk_count < MAX_COUNT then
					
						next_clk_count 	<= crnt_clk_count + 1;
						next_state		<= stx;
						
					else 
					
						next_clk_count 	<= 0;
						next_state 		<= sSTOP;
						
					end if;
					
					if crnt_send_byte(7) = '1' then
					
						next_uart_tx <= '1';
						
					else
					
						next_uart_tx <= '0';
						
					end if;
				
				end if;
	
			when sSTOP =>
			
				if crnt_clk_count < MAX_COUNT then
					
					next_uart_tx 	<= '1';
					next_clk_count 	<= crnt_clk_count + 1;
					next_state		<= sSTOP;
					
				else 
					
					next_tx_done	<= '1';
					next_clk_count 	<= 0;
					next_state 		<= sIDLE;
					
				end if;
			
			when others => 

				next_state <= sRST;
		
		end case;

	end process comb;

end Behavioral;

