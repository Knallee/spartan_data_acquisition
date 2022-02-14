LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_adc_data_rx IS
END TB_adc_data_rx;
 
ARCHITECTURE behavior OF TB_adc_data_rx IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT adc_data_rx
    PORT(
         sclk     : in   std_logic;
         n_rst    : in   std_logic;
         data_in  : in   std_logic;
         tx_done  : in   std_logic;
         drdy     : in   std_logic;
         data_out : out  std_logic_vector(7 downto 0);
         send     : out  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal sclk    : std_logic := '0';
   signal n_rst   : std_logic := '0';
   signal data_in : std_logic := '0';
   signal tx_done : std_logic := '0';
   signal drdy    : std_logic := '0';

 	--Outputs
   signal data_out   : std_logic_vector(7 downto 0);
   signal send       : std_logic;

   -- Clock period definitions
   constant sclk_period : time := 40 ns;

   signal sim_done 	: std_logic := '0'; 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: adc_data_rx PORT MAP (
          sclk       => sclk,
          n_rst      => n_rst,
          data_in    => data_in,
          tx_done    => tx_done,
          drdy       => drdy,
          data_out   => data_out,
          send       => send
        );

   -- Clock process definitions
   sclk_process :process
   begin
		if sim_done = '0' then
			wait for sclk_period / 2;
			sclk <= not sclk;
		else
			wait;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for sclk_period*2;
      n_rst <= '1';
      wait for (sclk_period/2) *3;
      wait for 4 ns;

      drdy <= '1';
      wait for 44 ns;
      drdy <= '0';


      -- insert stimulus here 

      
      wait;
   end process;


   stim_proc2: process
   begin
      wait for sclk_period*2;
      n_rst <= '1';
      wait for (sclk_period/2) *3;

      for I in 1 to 4 loop
         data_in <= '1';
         wait for sclk_period;
         data_in <= '0';
         wait for sclk_period;
      end loop;

      for I in 1 to 4 loop
         data_in <= '1';
         wait for sclk_period;
         data_in <= '1';
         wait for sclk_period;
      end loop;

      for I in 1 to 4 loop
         data_in <= '0';
         wait for sclk_period;
         data_in <= '1';
         wait for sclk_period;
      end loop;

      data_in <= '0';

      wait for sclk_period*10;
      tx_done <= '1';
      wait for sclk_period;
      tx_done <= '0';

      wait for sclk_period*10;
      tx_done <= '1';
      wait for sclk_period;
      tx_done <= '0';

      wait for sclk_period*10;
      tx_done <= '1';
      wait for sclk_period;
      tx_done <= '0';

      sim_done <= '1';
      wait;
   end process;

END;
