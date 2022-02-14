library ieee;
use ieee.std_logic_1164.all;

entity ads1675_controller is
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
end ads1675_controller;

architecture Behavioral of ads1675_controller is

    type state_type is (sPWR_DWN, sRDY, sSINGLE_SHOT, sSELF_TRIG);
    signal  crnt_state, next_state : state_type;

    signal crnt_pdwn     : std_logic;
    signal crnt_start    : std_logic;
    signal crnt_fclk_en  : std_logic;

    signal next_pdwn     : std_logic;
    signal next_start    : std_logic;
    signal next_fclk_en  : std_logic;


begin

    reg: process(clk) 
    begin
        if rising_edge(clk) then
            
            if n_rst = '0' then

                crnt_state      <= sPWR_DWN;
                crnt_pdwn       <= '0';
                crnt_start      <= '0';
                crnt_fclk_en    <= '0';

            else

                crnt_state      <= next_state;
                crnt_pdwn       <= next_pdwn;
                crnt_start      <= next_start;
                crnt_fclk_en    <= next_fclk_en;

            end if;

        end if;

    end process reg;

    comb: process(BTN1, BTN2, trig, crnt_state, crnt_pdwn, crnt_start, crnt_fclk_en)
    begin

        next_pdwn       <= crnt_pdwn;
        next_start      <= crnt_start;
        next_fclk_en    <= crnt_fclk_en;
        led5            <= '1';
        led6            <= '1'; 
        led7            <= '1';
        next_state <= crnt_state;

        case crnt_state is

            when sPWR_DWN =>

                led5            <= '1';
                led6            <= '1'; 
                led7            <= '1';

                next_pdwn       <= '0';
                next_start      <= '0';
                next_fclk_en    <= '0';
                

                if BTN1 = '1' then

                    next_state      <= sRDY;
                    next_pdwn       <= '1';
                    next_fclk_en    <= '1';
                    next_start      <= '1';     -- Strobe start to apply settings


                end if; 

            when sRDY =>

                led5            <= '0';
                led6            <= '1'; 
                led7            <= '1';

                next_start  <= '0';

                if BTN1 = '1' then

                    next_state <= sSINGLE_SHOT;

                end if;

                if BTN2 = '1' then

                    next_state <= sSELF_TRIG;

                end if;

            when sSINGLE_SHOT =>

                led5            <= '1';
                led6            <= '0'; 
                led7            <= '1';

                next_start      <= '1';
                next_state      <= sRDY;

            when sSELF_TRIG =>

                led5            <= '1';
                led6            <= '1'; 
                led7            <= '0';

                next_start <= '0';

                if trig = '1' then

                    next_start <= '1';

                end if;

                if BTN2 = '1' then

                    next_state <= sRDY;

                end if;


        end case;

    end process comb;



    AD4_PDWN    <= crnt_pdwn;
    AD4_CLK_SEL <= '0';
    AD4_LVDS    <= '1';
    AD4_LL_CFG  <= '0';
    AD4_FPATH   <= '1';
    AD4_DR      <= "000";
    AD4_START   <= crnt_start;
    AD4_CS      <= '0';
    AD4_FCLK_EN <= crnt_fclk_en;
    

end Behavioral;

