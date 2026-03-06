architecture Structural of PONG is

    signal pix_clk : std_logic; 
    signal xpos    : integer range 0 to 799;
    signal ypos    : integer range 0 to 524;

    signal hsync   : std_logic;
    signal vsync   : std_logic;

    signal ballX_sig, ballY_sig : integer;
    signal leftPaddleY_sig, rightPaddleY_sig : integer;
    signal goalState_sig  : std_logic;
    signal ballVisible_sig: std_logic;

    signal control0 : std_logic_vector(35 downto 0);
    signal ila_data : std_logic_vector(26 downto 0);
    signal trig0 : std_logic_vector(0 downto 0);

    -- ✅ INTERNAL RGB SIGNALS (needed to avoid reading OUT ports)
    signal Rout_sig : std_logic_vector(7 downto 0);
    signal Gout_sig : std_logic_vector(7 downto 0);
    signal Bout_sig : std_logic_vector(7 downto 0);

    component icon
        PORT ( CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
    end component;

    component ila 
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK : IN STD_LOGIC;
            DATA : IN STD_LOGIC_VECTOR(26 DOWNTO 0);
            TRIG0 : IN STD_LOGIC_VECTOR(0 TO 0)
        );
    end component;

begin

    sys_icon : icon
        port map ( CONTROL0 => control0 );

    sys_ila : ila
        port map (
            CONTROL => control0,
            CLK => pix_clk,
            DATA => ila_data,
            TRIG0 => trig0
        );

    clkdiv_inst : entity work.ClockDivider
        port map (
            clk_in  => clk,
            clk_out => pix_clk
        );

    DAC_CLK <= pix_clk;

    vga_inst : entity work.VGATimingGen
        port map (
            clock      => pix_clk,
            Horizsync  => hsync,
            Vertsync   => vsync,
            xposition  => xpos,
            yposition  => ypos
        );

    game_inst : entity work.GameLogic
        port map (
            clock             => pix_clk,
            xposition         => xpos,
            yposition         => ypos,
            SW0               => SW0,
            SW1               => SW1,
            SW2               => SW2,
            SW3               => SW3,
            ballX_out         => ballX_sig,
            ballY_out         => ballY_sig,
            PaddleleftY_out   => leftPaddleY_sig,
            PaddlerightY_out  => rightPaddleY_sig,
            Stategoal_out     => goalState_sig,
            Visibleball_out   => ballVisible_sig
        );

    -- Renderer (now drives internal RGB signals)
    render_inst : entity work.Renderer
        port map (
            xposition      => xpos,
            yposition      => ypos,
            ballX          => ballX_sig,
            ballY          => ballY_sig,
            PaddleleftY    => leftPaddleY_sig,
            PaddlerightY   => rightPaddleY_sig,
            ballVisibility => ballVisible_sig,
            Rout           => Rout_sig,   -- FIXED
            Gout           => Gout_sig,   -- FIXED
            Bout           => Bout_sig    -- FIXED
        );

    -- Drive actual output ports
    Rout <= Rout_sig;
    Gout <= Gout_sig;
    Bout <= Bout_sig;

    -- ILA debug signals
    trig0 <= "1";

    ila_data(0) <= hsync;
    ila_data(1) <= vsync;
    ila_data(2) <= pix_clk;

    -- Assign RGB to debug bus
    ila_data(10 downto 3)  <= Gout_sig;
    ila_data(18 downto 11) <= Bout_sig;
    ila_data(26 downto 19) <= Rout_sig;

    H <= hsync;
    V <= vsync;

end Structural;
