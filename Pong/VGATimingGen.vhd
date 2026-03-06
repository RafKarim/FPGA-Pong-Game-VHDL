library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGATimingGen is
    Port (
        clock     : in  STD_LOGIC;
        Horizsync   : out STD_LOGIC;
        Vertsync   : out STD_LOGIC;
        xposition    : out INTEGER range 0 to 799;
        yposition    : out INTEGER range 0 to 524
    );
end VGATimingGen;

architecture Behavioral of VGATimingGen is
    signal horiz_count : integer range 0 to 799 := 0;
    signal vert_count : integer range 0 to 524 := 0;
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if horiz_count = 799 then
                horiz_count <= 0;
                if vert_count = 524 then
                    vert_count <= 0;
                else
                    vert_count <= vert_count + 1;
                end if;
            else
                horiz_count <= horiz_count + 1;
            end if; -- basically this logic is that if horiz = 799 or vert = 524 reset to 0 else increment by 1

            if (horiz_count >= 656 and horiz_count <= 751) then
                Horizsync <= '0';
            else
                Horizsync <= '1';
            end if;

            if (vert_count >= 490 and vert_count <= 491) then
                Vertsync <= '0';
            else
                Vertsync <= '1';
            end if; -- basically for all other positions set horiz and vert to 1
        end if;
    end process;

    xposition <= horiz_count;
    yposition <= vert_count;
end Behavioral;
