library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GameLogic is
    Port (
        clock          : in  STD_LOGIC;   -- pixel clock (25 MHz)
        xposition         : in  INTEGER range 0 to 799;
        yposition         : in  INTEGER range 0 to 524;
        SW0, SW1     : in  STD_LOGIC; -- controls left paddle
        SW2, SW3     : in  STD_LOGIC; -- controls right paddle
        ballX_out    : out INTEGER; -- output for ball x position
        ballY_out    : out INTEGER; -- "" "" y positon
        PaddleLeftY_out  : out INTEGER;-- output for left paddle y position
        PaddleRightY_out : out INTEGER; -- "" "" x position
        Stategoal_out    : out STD_LOGIC; -- 1 = goal
        Visibleball_out  : out STD_LOGIC
    );
end GameLogic;

architecture Behavioral of GameLogic is

    -- BALL STATE
    signal ballpositionX    : integer range 0 to 640 := 315; -- initial position for x and y
    signal ballpositionY    : integer range 0 to 480 := 230;
    constant ballSize : integer := 15;

    signal balldirectionX : integer range 0 to 1 := 1;  -- 1 = right, 0 = left
    signal balldirectionY : integer range 0 to 1 := 1;  -- 1 = down, 0 = up

    signal ballVisibility : std_logic := '1';
    signal goalState   : std_logic := '0';
    signal goalTimer   : integer range 0 to 100 := 0;
    constant GOAL_PAUSE_FRAMES : integer := 60;  -- ~1 second pause

    -- ARENA / PADDLES
    constant paddlex  : integer := 12;
    constant paddley : integer := 90; -- these are paddle dimensions

    constant goaltop    : integer := 125;
    constant goalbottom : integer := 485 - goaltop; -- coordinates of goal region

    constant ArenaTop    : integer := 37;
    constant ArenaBottom : integer := 446;
    constant ArenaLeft   : integer := 26;
    constant ArenaRight  : integer := 604; -- all sides of the play area

    constant PaddleleftPosX  : integer := 40;
    constant PaddlerightPosX : integer := 600; -- x positions for right and left paddle

    signal PaddleleftPosY  : integer range 0 to 480 := 37;
    signal PaddlerightPosY : integer range 0 to 480 := 37; -- y poistions for right and left paddle

begin

    process(clock)
    begin
        if rising_edge(clock) then

            -- Frame tick at (10,10) 
            if (xposition = 10 and yposition = 10) then

                if goalState = '0' then
                    --------------------------------------------------------
                    -- PADDLES can be moved when goalstate = 0
                    --------------------------------------------------------
                    if (SW2 = '0' and PaddlerightPosY < ArenaBottom - paddley and SW3 = '1') then
                        PaddlerightPosY <= PaddlerightPosY + 1;
                    elsif (SW2 = '1' and PaddlerightPosY > ArenaTop and SW3 = '1') then
                        PaddlerightPosY <= PaddlerightPosY - 1;
                    end if; -- right paddle down and up

                    if (SW0 = '0' and PaddleleftPosY < ArenaBottom - paddley and SW1 = '1') then
                        PaddleleftPosY <= PaddleleftPosY + 1;
                    elsif (SW0 = '1' and PaddleleftPosY > ArenaTop and SW1 = '1') then
                        PaddleleftPosY <= PaddleleftPosY - 1;
                    end if; -- left paddle down and up

                    --------------------------------------------------------
                    -- BALL MOTION
                    --------------------------------------------------------
                    if balldirectionX > 0 then
                        ballpositionX <= ballpositionX + 1;
                    else
                        ballpositionX <= ballpositionX - 1;
                    end if;
							-- move ball along x direction based on current direction
                    if balldirectionY > 0 then
                        ballpositionY <= ballpositionY + 1;
                    else
                        ballpositionY <= ballpositionY - 1;
                    end if;
							-- "" "" y direction based on current direction
                    --------------------------------------------------------
                    -- TOP / BOTTOM WALL BOUNCE
                    --------------------------------------------------------
                    if (balldirectionY = 0 and ballpositionY <= ArenaTop) then
                        balldirectionY <= 1; -- ball bounces down
                        ballpositionY <= ArenaTop; -- reset position at top wall
                    end if; -- basically if ball hits top wall reverse vertical direction
                    if (balldirectionY = 1 and ballpositionY >= ArenaBottom - ballSize) then
                        balldirectionY <= 0;
                        ballpositionY <= ArenaBottom - ballSize;
                    end if; -- basically if ball hits bottom wall reverse vertical direction

                    --------------------------------------------------------
                    -- LEFT / RIGHT WALLS (NO GATE REGIONS)
                    --------------------------------------------------------
                    if (balldirectionX = 1 and ballpositionX >= ArenaRight - ballSize - 1 and
                        ((ballpositionY < goaltop) or (ballpositionY + ballSize > goalbottom))) then
                        balldirectionX <= 0;
                        ballpositionX <= ArenaRight - ballSize - 1;
                    end if; -- basically if ball doesnt go through goal reverse horizontal direction

                    if (balldirectionX = 0 and ballpositionX <= ArenaLeft + 1 and
                        ((ballpositionY < goaltop) or (ballpositionY + ballSize > goalbottom))) then
                        balldirectionX <= 1;
                        ballpositionX <= ArenaLeft + 1;
                    end if; -- if ball doesnt go through goal reverse horizontal direction 

                    --------------------------------------------------------
                    -- CORNER FIX (upper-left)
                    --------------------------------------------------------
                    if (ballpositionX <= ArenaLeft + 1 and ballpositionY <= ArenaTop + 1) then
                        balldirectionX <= 1;
                        balldirectionY <= 1;
                        ballpositionX <= ArenaLeft + 2;
                        ballpositionY <= ArenaTop + 2;
                    end if; -- if corner is hit then reverse in both directions

                    --------------------------------------------------------
                    -- PADDLE COLLISIONS
                    --------------------------------------------------------
                    -- Left paddle
                    if (balldirectionX = 0 and
                        ballpositionX <= PaddleleftPosX + paddlex and
                        ballpositionX >= PaddleleftPosX + paddlex - 2 and
                        (ballpositionY + ballSize > PaddleleftPosY and ballpositionY < PaddleleftPosY + paddley)) then
                        balldirectionX <= 1; -- ball bounces right
                        ballpositionX <= PaddleleftPosX + paddlex; -- reset position at left paddle
                    end if; 

                    -- Right paddle
                    if (balldirectionX = 1 and
                        ballpositionX + ballSize >= PaddlerightPosX - paddlex and
                        ballpositionX + ballSize <= PaddlerightPosX - paddlex + 2 and
                        (ballpositionY + ballSize > PaddlerightPosY and ballpositionY < PaddlerightPosY + paddley)) then
                        balldirectionX <= 0; -- ball bounces left
                        ballpositionX <= PaddlerightPosX - paddlex - ballSize; -- reset positom at right paddle
                    end if;

                    --------------------------------------------------------
                    -- GOAL DETECTION (symmetric)
                    --------------------------------------------------------
                    -- checks if ball passes left or right goal area
						  if ((ballpositionX + ballSize >= ArenaRight) or
                        (ballpositionX <= ArenaLeft)) and
                       (ballpositionY >= goaltop and ballpositionY + ballSize <= goalbottom) then
								-- adjust ball position and mark goal state
                        if (ballpositionX + ballSize >= ArenaRight) then
                            ballpositionX <= ArenaRight - ballSize; -- reset ball at right goal line
                        else
                            ballpositionX <= ArenaLeft; -- reset ball at left goal line
                        end if;

                        goalState   <= '1'; -- goal has been scored
                        ballVisibility <= '1'; -- ball visible 
                        goalTimer   <= 0; -- reset goal timer
                    end if;

                else
                    --------------------------------------------------------
                    -- GOAL FREEZE STATE
                    --------------------------------------------------------
                    ballVisibility <= '1'; -- ball stays visible during the freeze
                    if goalTimer < GOAL_PAUSE_FRAMES then
                        goalTimer <= goalTimer + 1; -- increment goal timer
                    else
                        ballpositionX <= 312; -- ball set to centre of screen
                        ballpositionY <= 232;
                        balldirectionX   <= 1;
                        balldirectionY   <= 1;
                        ballVisibility <= '1';
                        goalState   <= '0';
                    end if;
                end if;
            end if; -- frame tick
        end if; -- rising_edge
    end process;

    -- Drive outputs
    ballX_out        <= ballpositionX;
    ballY_out        <= ballpositionY;
    PaddleLeftY_out  <= PaddleleftPosY;
    PaddleRightY_out <= PaddlerightPosY;
    StateGoal_out    <= goalState;
    Visibleball_out  <= ballVisibility;

end Behavioral;
