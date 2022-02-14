library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity button_logic is
port(
    clk         : in  std_logic;
    btn1        : in  std_logic;
    btn2        : in  std_logic;
    btn3        : in  std_logic;
    btn1_out    : out std_logic;
    btn2_out    : out std_logic;
    btn3_out    : out std_logic
);
end button_logic;

architecture Behavioral of button_logic is

    signal btn1_deb : std_logic;
    signal btn2_deb : std_logic;
    signal btn3_deb : std_logic;

    component debouncer is
    port(
        clk 		: in std_logic;
        button_in 	: in std_logic;
        button_out 	: out std_logic
    );
    end component;

    component edge_det is
	port (
		clk    	: in  std_logic;
		inp  	: in  std_logic;
		det	   	: out std_logic
	);
    end component;

begin

    deb1: debouncer
    port map(
        clk 		=> clk,
        button_in 	=> BTN1,
        button_out 	=> btn1_deb
    );

    deb2: debouncer
    port map(
        clk 		=> clk,
        button_in 	=> BTN2,
        button_out 	=> btn2_deb
    );

    deb3: debouncer
    port map(
        clk 		=> clk,
        button_in 	=> BTN3,
        button_out 	=> btn3_out
    );    
    
    det1: edge_det
	port map(
		clk    	=> clk,
		inp  	=> btn1_deb,
		det	   	=> btn1_out
	);

    det2: edge_det
	port map(
		clk    	=> clk,
		inp  	=> btn2_deb,
		det	   	=> btn2_out
	);




end Behavioral;

