library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity ads1675_top is
port(
    sys_clkp        : in  std_logic;
    sys_clkn        : in  std_logic;
    BTN1            : in  std_logic;
    BTN2            : in  std_logic;
    BTN3            : in  std_logic;    -- reset
    led0            : out std_logic;
    led1            : out std_logic;
    led2            : out std_logic;
    led3            : out std_logic;
    led4            : out std_logic;
    led5            : out std_logic;
    led6            : out std_logic;
    led7            : out std_logic;
    AD4_PDWN        : out std_logic;
    AD4_CLK_SEL     : out std_logic;
    AD4_LVDS        : out std_logic;    
    AD4_LL_CFG      : out std_logic;
    AD4_FPATH       : out std_logic;
    AD4_DR          : out std_logic_vector(2 downto 0);
    AD4_START       : out std_logic;    
    AD4_CS          : out std_logic;
    AD4_SCLK_P      : in  std_logic;
    AD4_DOUT_P      : in  std_logic;
    AD4_DRDY_P      : in  std_logic;
    AD4_FCLK        : out std_logic;
    TX_PIN          : out std_logic;
    debug           : out std_logic
);
end ads1675_top;

architecture Behavioral of ads1675_top is

    signal n_rst     : std_logic;
    signal rst_oddr2 : std_logic;
    signal rst       : std_logic;

    signal clk_100MHz : std_logic;
    --attribute period: string;  
    --attribute period of clk_100MHz : signal is "10 ns";

    signal clk_25MHz : std_logic;
    --attribute periood: string;  
    --attribute periood of clk_25MHz : signal is "40 ns";

    signal Counter1: std_logic_vector(25 downto 0);
    signal CLK1_scaled: std_logic;

    signal Counter2: std_logic_vector(23 downto 0);
    signal CLK2_scaled: std_logic;

    signal Counter3         : std_logic_vector(24 downto 0);
    signal trig_signal      : std_logic;

    signal clk_inv          : std_logic;
    signal gated_25MHz      : std_logic;
    signal ad4_master_clk   : std_logic;

    signal btn1_edge : std_logic; 
    signal btn2_edge : std_logic;

    signal s_pwr_dwn      : std_logic;
    signal s_ad4_pdwn     : std_logic;
    signal s_ad4_clk_sel  : std_logic;
    signal s_ad4_lvds     : std_logic;
    signal s_ad4_ll_cfg   : std_logic;
    signal s_ad4_fpath    : std_logic;
    signal s_ad4_dr       : std_logic_vector(2 downto 0);
    signal s_ad4_start    : std_logic;
    signal s_ad4_cs       : std_logic;
    signal s_ad4_fclk_en  : std_logic;



    signal tx_done  : std_logic;
    signal data_out : std_logic_vector(7 downto 0);
    signal send     : std_logic;

  

    component clk_gen is
    port(
        CLK_IN1_P         : in  std_logic;
        CLK_IN1_N         : in  std_logic;
        CLK_100MHz        : out std_logic;
        CLK_25MHz         : out std_logic;  
        RESET             : in  std_logic;
        LOCKED            : out std_logic
    );
    end component;

    component button_logic is
    port(
        clk         : in  std_logic;
        btn1        : in  std_logic;
        btn2        : in  std_logic;
        btn3        : in  std_logic;
        btn1_out    : out std_logic;
        btn2_out    : out std_logic;
        btn3_out    : out std_logic
    );
    end component;

    component ads1675_controller is
    port(
        clk             : in  std_logic;
        n_rst           : in  std_logic;
        BTN2            : in  std_logic;
        BTN1            : in  std_logic;
        trig            : in  std_logic;
        AD4_PDWN        : out std_logic;
        AD4_CLK_SEL     : out std_logic;
        AD4_LVDS        : out std_logic;
        AD4_LL_CFG      : out std_logic;
        AD4_FPATH       : out std_logic;
        AD4_DR          : out std_logic_vector(2 downto 0);
        AD4_START       : out std_logic;
        AD4_CS          : out std_logic;
        AD4_FCLK_EN     : out std_logic;
        led5            : out std_logic;
        led6            : out std_logic;
        led7            : out std_logic
    );
    end component;

    component trig_logic is
    port(
        clk_in  : in  std_logic;
        n_rst   : in  std_logic;
        trig    : out std_logic
    );
    end component;

    component adc_data_rx is
    port(
        sclk        : in  std_logic;
        n_rst       : in  std_logic;
        data_in     : in  std_logic;
        tx_done     : in  std_logic;
        drdy        : in  std_logic;
        data_out    : out std_logic_vector(7 downto 0);
        send        : out std_logic;
        debug       : out std_logic
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

    component clock_output is
    port(
        clk         : in  std_logic;
        rst         : in  std_logic;
        clk_enable  : in  std_logic;
        clk_out     : out std_logic
    );
    end component;

begin

    n_rst <= not rst;

    clock: clk_gen
    port map(
        CLK_IN1_P          => sys_clkp,
        CLK_IN1_N          => sys_clkn,
        CLK_100MHz         => clk_100MHz,
        CLK_25MHz          => clk_25MHz,
        RESET              => '0',
        LOCKED             => open
    );

    btn_logic: button_logic
    port map(
        clk         => clk_25MHz,
        btn1        => BTN1,
        btn2        => BTN2,
        btn3        => BTN3,
        btn1_out    => btn1_edge,
        btn2_out    => btn2_edge,
        btn3_out    => rst
    );

    ad4_controller: ads1675_controller
    port map(
        clk             => clk_25MHz,
        n_rst           => n_rst,
        BTN1            => btn1_edge,
        BTN2            => btn2_edge,
        trig            => trig_signal,
        AD4_PDWN        => s_ad4_pdwn,
        AD4_CLK_SEL     => s_ad4_clk_sel,
        AD4_LVDS        => s_ad4_lvds,
        AD4_LL_CFG      => s_ad4_ll_cfg,
        AD4_FPATH       => s_ad4_fpath,
        AD4_DR          => s_ad4_dr,
        AD4_START       => s_ad4_start,
        AD4_CS          => s_ad4_cs,
        AD4_FCLK_EN     => s_ad4_fclk_en,
        led5            => led5,
        led6            => led6,
        led7            => led7

        

    );

    trig_gen: trig_logic
    port map(
        clk_in  => clk_25MHz,
        n_rst   => n_rst,
        trig    => trig_signal
    );

    data_adc_rx: adc_data_rx
    port map(
        sclk        => AD4_SCLK_P,
        n_rst       => n_rst,
        data_in     => AD4_DOUT_P,
        tx_done     => tx_done,
        drdy        => AD4_DRDY_P,
        data_out    => data_out,
        send        => send,
        debug       => debug
    );

    uart_tx: tx_UART 
    port map(
        clk		 	 => AD4_SCLK_P,
        n_rst	 	 => n_rst,
        send	 	 => send,
        tx		 	 => TX_PIN,
        tx_done		 => tx_done,
        byte_in  	 => data_out
    );

    clk_out: clock_output
    port map(
        clk         => clk_25MHz,
        rst         => rst,
        clk_enable  => s_ad4_fclk_en,
        clk_out     => ad4_master_clk
    );

    

    Prescaler1: process(clk_100MHz)
	begin
		if rising_edge(clk_100MHz) then
			if Counter1 < "10111110101111000010000000" then
				Counter1 <= Counter1 + 1;
			else
				CLK1_scaled <= not CLK1_scaled;
				Counter1 <= (others => '0');
			end if;
		end if;
	end process Prescaler1;

    Prescaler2: process(clk_25MHz)
	begin
		if rising_edge(clk_25MHz) then
			if Counter2 < "101111101011110000100000" then
				Counter2 <= Counter2 + 1;
			else
				CLK2_scaled <= not CLK2_scaled;
				Counter2 <= (others => '0');
			end if;
		end if;
	end process Prescaler2;








    led0 <= CLK1_scaled;
    led1 <= CLK2_scaled;
    led2 <= trig_signal;
    led3 <= '1';
    led4 <= '1';



    AD4_PDWN    <= s_ad4_pdwn;
    AD4_CLK_SEL <= s_ad4_clk_sel;
    AD4_LVDS    <= s_ad4_lvds;
    AD4_LL_CFG  <= s_ad4_ll_cfg;
    AD4_FPATH   <= s_ad4_fpath;
    AD4_DR      <= s_ad4_dr;
    AD4_START   <= s_ad4_start;
    AD4_CS      <= s_ad4_cs;
    AD4_FCLK    <= ad4_master_clk;



end Behavioral;

