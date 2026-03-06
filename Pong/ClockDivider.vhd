library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ClockDivider is
    Port (
        clk_in  : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    signal div : std_logic := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            div <= not div;
        end if;
    end process;
    clk_out <= div;
end Behavioral;
