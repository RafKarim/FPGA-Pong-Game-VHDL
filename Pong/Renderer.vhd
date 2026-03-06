library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Renderer is
    Port (
        xposition, yposition        : in  INTEGER;
        ballX, ballY      : in  INTEGER;
        PaddleleftY       : in  INTEGER;
        PaddlerightY      : in  INTEGER;
        ballVisibility       : in  STD_LOGIC;
        Rout, Gout, Bout  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Renderer;

architecture Behavioral of Renderer is

    -- Constants reused from your design
    constant paddlex  : integer := 12;
    constant paddley : integer := 90;

    constant goaltop    : integer := 125;
    constant goalbottom : integer := 485 - goaltop;

    constant ArenaTop    : integer := 37;
    constant ArenaBottom : integer := 446;
    constant ArenaLeft   : integer := 26;
    constant ArenaRight  : integer := 604;

    constant PaddleleftPosX  : integer := 40;
    constant PaddlerightPosX : integer := 600;

    constant ballSize : integer := 15;

begin

    process(xposition, yposition, ballX, ballY, PaddleleftY, PaddlerightY, ballVisibility)
    begin
        -- Default background (black)
        Rout <= (others => '0');
        Gout <= (others => '0');
        Bout <= (others => '0');

        ----------------------------------------------------------------
        -- BACKGROUND
        ----------------------------------------------------------------
        if (xposition >= 25 and xposition <= 615 and
           ((yposition >= 25 and yposition <= 36) or (yposition >= 448 and yposition <= 459))) then
            Rout <= X"FF"; Gout <= X"FF"; Bout <= X"FF";  -- top/bottom white
        elsif (((xposition >= 25 and xposition <= 36) or (xposition >= 604 and xposition <= 615)) and
              ((yposition >= 36 and yposition <= goaltop) or (yposition >= goalbottom and yposition <= 448))) then
            Rout <= X"FF"; Gout <= X"FF"; Bout <= X"FF";  -- side white
        elsif ((xposition > 316 and xposition < 320) and yposition >= 37 and yposition < 448 and
              (((yposition - 35) mod 64) > 32)) then
            Rout <= X"00"; Gout <= X"00"; Bout <= X"00";  -- dashed center line
        elsif (xposition >= 0 and xposition < 640 and yposition >= 0 and yposition < 480) then
            Rout <= X"34"; Gout <= X"FF"; Bout <= X"54";  -- green field
        else
            Rout <= (others => '0'); Gout <= (others => '0'); Bout <= (others => '0');
        end if;

        ----------------------------------------------------------------
        -- PADDLES
        ----------------------------------------------------------------
        -- Left paddle (blue)
        if ((xposition > PaddleleftPosX and xposition < PaddleleftPosX + paddlex) and
            (yposition > PaddleleftY and yposition < PaddleleftY + paddley)) then
            Rout <= X"00"; Gout <= X"00"; Bout <= X"FF";
        end if;

        -- Right paddle (pink)
        if ((xposition < PaddlerightPosX and xposition > PaddlerightPosX - paddlex) and
            (yposition > PaddlerightY and yposition < PaddlerightY + paddley)) then
            Rout <= X"FF"; Gout <= X"80"; Bout <= X"FF";
        end if;

        ----------------------------------------------------------------
        -- BALL (yellow normally, red in goal zone)
        ----------------------------------------------------------------
        if (ballVisibility = '1') then
            if (xposition >= ballX and xposition < ballX + ballSize and
                yposition >= ballY and yposition < ballY + ballSize) then

                if (ballY >= goaltop and ballY + ballSize <= goalbottom)
                    and ((ballX <= ArenaLeft + 1) or
                         (ballX + ballSize >= ArenaRight - 1)) then
                    Rout <= X"FF"; Gout <= X"00"; Bout <= X"00";  -- red in gate
                else
                    Rout <= X"FF"; Gout <= X"FF"; Bout <= X"00";  -- yellow
                end if;
            end if;
        end if;

    end process;

end Behavioral;
