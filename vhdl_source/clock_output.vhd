library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity clock_output is
port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    clk_enable  : in  std_logic;
    clk_out     : out std_logic
);
end clock_output;

architecture Behavioral of clock_output is

    signal clk_inv : std_logic;

begin

    clk_inv <= NOT clk;
    
    ODDR2_inst : ODDR2
    generic map(
        DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1" 
        INIT => '0',                -- Sets initial state of the Q output to '0' or '1'
        SRTYPE => "SYNC")           -- Specifies "SYNC" or "ASYNC" set/reset
    port map (
        Q  => clk_out,      -- 1-bit output data
        C0 => clk,          -- 1-bit clock input
        C1 => clk_inv,      -- 1-bit clock input
        CE => clk_enable,   -- 1-bit clock enable input
        D0 => '0',          -- 1-bit data input (associated with C0)
        D1 => '1',          -- 1-bit data input (associated with C1)
        R  => rst,          -- 1-bit reset input
        S  => '0'           -- 1-bit set input
    );

end Behavioral;

