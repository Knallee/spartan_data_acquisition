library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_adc_data_rx_tx is
end TB_adc_data_rx_tx;

architecture Behavioral of TB_adc_data_rx_tx is

    component adc_data_rx is
    port(
        sclk        : in  std_logic;
        n_rst       : in  std_logic;
        data_in     : in  std_logic;
        tx_done     : in  std_logic;
        drdy        : in  std_logic;
        data_out    : out std_logic_vector(7 downto 0);
        send        : out std_logic
    );
    end component;

    component tx_UART is
    port(
        clk		 	 : in  std_logic;
        n_rst	 	 : in  std_logic;
        send	 	 : in  std_logic;
        tx		 	 : out std_logic;
        tx_done		 : out std_logic;
        byte_in  	 : in  std_logic_vector(7 downto 0)
    );
    end component;

signal s_sclk     : std_logic := '0';
signal s_n_rst    : std_logic := '0';
signal s_data_in  : std_logic := '0';
signal s_tx_done  : std_logic := '0';
signal s_drdy     : std_logic := '0';
signal s_data_out : std_logic_vector(7 downto 0) := (others => '0');
signal s_send     : std_logic := '0';

signal s_tx       : std_logic;

constant sclk_period : time := 40 ns;


signal sim_done 	: std_logic := '0'; 

begin


    uut1: adc_data_rx
    port map(
        sclk        => s_sclk,
        n_rst       => s_n_rst,
        data_in     => s_data_in,
        tx_done     => s_tx_done,
        drdy        => s_drdy,
        data_out    => s_data_out,
        send        => s_send
    );

    uut2: tx_UART
    port map(
        clk		 	 => s_sclk,
        n_rst	 	 => s_n_rst,
        send	 	 => s_send,
        tx		 	 => s_tx,
        tx_done		 => s_tx_done,
        byte_in  	 => s_data_out
    );

   -- Clock process definitions
   sclk_process :process
   begin
		if sim_done = '0' then
			wait for sclk_period / 2;
			s_sclk <= not s_sclk;
		else
			wait;
		end if;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for sclk_period*2;
      s_n_rst <= '1';
      wait for (sclk_period/2) *3;
      wait for 4 ns;

      s_drdy <= '1';
      wait for 44 ns;
      s_drdy <= '0';


      -- insert stimulus here 

      
      wait;
   end process;


    stim_proc2: process
    begin
        wait for sclk_period*2;
        s_n_rst <= '1';
        wait for (sclk_period/2) *3;

        for I in 1 to 4 loop
            s_data_in <= '1';
            wait for sclk_period;
            s_data_in <= '0';
            wait for sclk_period;
        end loop;

        for I in 1 to 4 loop
            s_data_in <= '1';
            wait for sclk_period;
            s_data_in <= '1';
            wait for sclk_period;
        end loop;

        for I in 1 to 4 loop
            s_data_in <= '0';
            wait for sclk_period;
            s_data_in <= '1';
            wait for sclk_period;
        end loop;

        s_data_in <= '0';
        
        wait until s_tx_done = '1';

        wait until s_tx_done = '1';

        wait until s_tx_done = '1';
        
        wait for 50000 ns;

        sim_done <= '1';
        wait;
   end process;


end Behavioral;

