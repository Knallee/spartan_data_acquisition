library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity adc_data_rx is
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
end adc_data_rx;

architecture Behavioral of adc_data_rx is

	type state is (sRST, sIDLE, sUART_MSB, sUART_MIA, sUART_MIB, sUART_LSB, sPAD);
	signal next_state : state;
	signal crnt_state : state;


    signal next_send        : std_logic;
    signal next_data_rdy    : std_logic;

    signal crnt_send        : std_logic;
    signal crnt_data_rdy    : std_logic;

    signal msb_byte         : std_logic_vector(7 downto 0);
    signal mia_byte         : std_logic_vector(7 downto 0);
    signal mib_byte         : std_logic_vector(7 downto 0);
    signal lsb_byte         : std_logic_vector(7 downto 0);

    signal adc_data         : std_logic_vector(23 downto 0);
    signal index            : integer range 0 to 23;
    signal incoming_data    : std_logic;


    signal first_bit   : std_logic;


begin

    reg: process(sclk)
    begin

        if falling_edge(sclk) then

            if n_rst = '0' then

                crnt_state <= sRST;

                incoming_data   <= '0';
                index           <= 22;
                adc_data        <= (others => '0');

                crnt_send       <= '0';
                crnt_data_rdy   <= '0';

            else

                crnt_state      <= next_state;
                crnt_send       <= next_send;
                crnt_data_rdy   <= next_data_rdy;

                if drdy = '1' then
                    
                    adc_data(23)  <= data_in;

                    incoming_data <= '1';

                end if;

                if incoming_data = '1' and index > 0 then

                    index           <= index - 1;
                    adc_data(index) <= data_in;                 

                elsif index = 0 and incoming_data = '1' then

                    adc_data(index) <= data_in;
                    incoming_data   <= '0';
                    crnt_data_rdy   <= '1';
                    index           <= 22;
                    
                end if;

            end if;

        end if;

    end process reg;
    
    --msb_byte <= "10101010";
    --mid_byte <= "11111111";
    --lsb_byte <= "01010101"; 

    --msb_byte <= adc_data(23 downto 16);
    --mid_byte <= adc_data(15 downto  8);
    --lsb_byte <= adc_data(7  downto  0); 

    msb_byte <= "00" & adc_data(23 downto 18);
    mia_byte <= "01" & adc_data(17 downto 12);
    mib_byte <= "10" & adc_data(11 downto  6);
    lsb_byte <= "11" & adc_data(5  downto  0);

    send    <= crnt_send;
    debug   <= incoming_data;

    with crnt_state select
        data_out <= msb_byte when sUART_MSB,
                    mia_byte when sUART_MIA,
                    mib_byte when sUART_MIB,
                    lsb_byte when sUART_LSB,
                    (others => '0') when others;

    comb: process(crnt_state, crnt_data_rdy, tx_done, crnt_send)
    begin

        next_state      <= crnt_state;
        next_send       <= crnt_send;
        next_data_rdy   <= crnt_data_rdy;

        case crnt_state is

            when sRST => 

                next_state      <= sIDLE;
                next_send       <= '0';
                next_data_rdy   <= '0';

            when sIDLE =>

                next_state       <= sIDLE; 

                if crnt_data_rdy = '1' then

                    next_state <= sUART_MSB;

                end if;


            when sUART_MSB => 

                next_send       <= '1';
                next_data_rdy   <= '0';

                if tx_done = '1' then

                    next_send   <= '0';

                    next_state  <= sUART_MIA;

                end if;

            when sUART_MIA =>

                next_send <= '1';

                if tx_done = '1' then

                    next_send   <= '0';

                    next_state  <= sUART_MIB;

                end if;

            when sUART_MIB =>

                next_send <= '1';

                if tx_done = '1' then

                    next_send   <= '0';

                    next_state  <= sUART_LSB;

                end if;

            when sUART_LSB => 

                next_send <= '1';

                if tx_done = '1' then

                    next_send   <= '0';

                    next_state  <= sIDLE;

                end if;

            when others =>         


        end case;

    end process comb;


end Behavioral;

