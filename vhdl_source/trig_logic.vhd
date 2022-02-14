library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity trig_logic is
port(
    clk_in  : in  std_logic;
    n_rst   : in  std_logic;
    trig    : out std_logic
);
end trig_logic;

architecture Behavioral of trig_logic is

    constant MAX_COUNT	: integer range 0 to 250000 := 250000;
    signal trig_clk     : std_logic;
    signal counter      : integer range 0 to MAX_COUNT;
    signal trig_signal  : std_logic;
    

    component edge_det is
    port (
        clk    	: in  std_logic;
        inp  	: in  std_logic;
        det	   	: out std_logic
    );
    end component;

begin

    trig_sig_gen: process(clk_in)
	begin
		if rising_edge(clk_in) then
            if n_rst = '0' then
                trig_clk <= '0';
                counter    <= 0;
            else    
			    if counter < MAX_COUNT then
			    	counter <= counter + 1;
			    else
			    	trig_clk <= not trig_clk;
			    	counter <= 0;
			    end if;
            end if;
		end if;
	end process trig_sig_gen;

    det: edge_det
    port map(
        clk    	=> clk_in,
        inp  	=> trig_clk,
        det	   	=> trig_signal
    );

    trig <= trig_signal;

end Behavioral;

