	component lab8_soc is
		port (
			clk_clk                        : in    std_logic                     := 'X';             -- clk
			curx_w0_in_port                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
			curx_w0_out_port               : out   std_logic_vector(31 downto 0);                    -- out_port
			curx_w1_in_port                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
			curx_w1_out_port               : out   std_logic_vector(31 downto 0);                    -- out_port
			cury_w0_in_port                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
			cury_w0_out_port               : out   std_logic_vector(31 downto 0);                    -- out_port
			cury_w1_in_port                : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
			cury_w1_out_port               : out   std_logic_vector(31 downto 0);                    -- out_port
			hex_digits_export              : out   std_logic_vector(15 downto 0);                    -- export
			key_external_connection_export : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			keycode_export                 : out   std_logic_vector(7 downto 0);                     -- export
			leds_export                    : out   std_logic_vector(13 downto 0);                    -- export
			mag_w0_in_port                 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
			mag_w0_out_port                : out   std_logic_vector(31 downto 0);                    -- out_port
			mag_w1_in_port                 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- in_port
			mag_w1_out_port                : out   std_logic_vector(31 downto 0);                    -- out_port
			reset_reset_n                  : in    std_logic                     := 'X';             -- reset_n
			sdram_clk_clk                  : out   std_logic;                                        -- clk
			sdram_wire_addr                : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba                  : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n               : out   std_logic;                                        -- cas_n
			sdram_wire_cke                 : out   std_logic;                                        -- cke
			sdram_wire_cs_n                : out   std_logic;                                        -- cs_n
			sdram_wire_dq                  : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm                 : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n               : out   std_logic;                                        -- ras_n
			sdram_wire_we_n                : out   std_logic;                                        -- we_n
			spi0_MISO                      : in    std_logic                     := 'X';             -- MISO
			spi0_MOSI                      : out   std_logic;                                        -- MOSI
			spi0_SCLK                      : out   std_logic;                                        -- SCLK
			spi0_SS_n                      : out   std_logic;                                        -- SS_n
			usb_gpx_export                 : in    std_logic                     := 'X';             -- export
			usb_irq_export                 : in    std_logic                     := 'X';             -- export
			usb_rst_export                 : out   std_logic;                                        -- export
			signewcurx_in_port             : in    std_logic                     := 'X';             -- in_port
			signewcurx_out_port            : out   std_logic;                                        -- out_port
			signewcury_in_port             : in    std_logic                     := 'X';             -- in_port
			signewcury_out_port            : out   std_logic;                                        -- out_port
			signewmag_in_port              : in    std_logic                     := 'X';             -- in_port
			signewmag_out_port             : out   std_logic                                         -- out_port
		);
	end component lab8_soc;

	u0 : component lab8_soc
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                     clk.clk
			curx_w0_in_port                => CONNECTED_TO_curx_w0_in_port,                --                 curx_w0.in_port
			curx_w0_out_port               => CONNECTED_TO_curx_w0_out_port,               --                        .out_port
			curx_w1_in_port                => CONNECTED_TO_curx_w1_in_port,                --                 curx_w1.in_port
			curx_w1_out_port               => CONNECTED_TO_curx_w1_out_port,               --                        .out_port
			cury_w0_in_port                => CONNECTED_TO_cury_w0_in_port,                --                 cury_w0.in_port
			cury_w0_out_port               => CONNECTED_TO_cury_w0_out_port,               --                        .out_port
			cury_w1_in_port                => CONNECTED_TO_cury_w1_in_port,                --                 cury_w1.in_port
			cury_w1_out_port               => CONNECTED_TO_cury_w1_out_port,               --                        .out_port
			hex_digits_export              => CONNECTED_TO_hex_digits_export,              --              hex_digits.export
			key_external_connection_export => CONNECTED_TO_key_external_connection_export, -- key_external_connection.export
			keycode_export                 => CONNECTED_TO_keycode_export,                 --                 keycode.export
			leds_export                    => CONNECTED_TO_leds_export,                    --                    leds.export
			mag_w0_in_port                 => CONNECTED_TO_mag_w0_in_port,                 --                  mag_w0.in_port
			mag_w0_out_port                => CONNECTED_TO_mag_w0_out_port,                --                        .out_port
			mag_w1_in_port                 => CONNECTED_TO_mag_w1_in_port,                 --                  mag_w1.in_port
			mag_w1_out_port                => CONNECTED_TO_mag_w1_out_port,                --                        .out_port
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                   reset.reset_n
			sdram_clk_clk                  => CONNECTED_TO_sdram_clk_clk,                  --               sdram_clk.clk
			sdram_wire_addr                => CONNECTED_TO_sdram_wire_addr,                --              sdram_wire.addr
			sdram_wire_ba                  => CONNECTED_TO_sdram_wire_ba,                  --                        .ba
			sdram_wire_cas_n               => CONNECTED_TO_sdram_wire_cas_n,               --                        .cas_n
			sdram_wire_cke                 => CONNECTED_TO_sdram_wire_cke,                 --                        .cke
			sdram_wire_cs_n                => CONNECTED_TO_sdram_wire_cs_n,                --                        .cs_n
			sdram_wire_dq                  => CONNECTED_TO_sdram_wire_dq,                  --                        .dq
			sdram_wire_dqm                 => CONNECTED_TO_sdram_wire_dqm,                 --                        .dqm
			sdram_wire_ras_n               => CONNECTED_TO_sdram_wire_ras_n,               --                        .ras_n
			sdram_wire_we_n                => CONNECTED_TO_sdram_wire_we_n,                --                        .we_n
			spi0_MISO                      => CONNECTED_TO_spi0_MISO,                      --                    spi0.MISO
			spi0_MOSI                      => CONNECTED_TO_spi0_MOSI,                      --                        .MOSI
			spi0_SCLK                      => CONNECTED_TO_spi0_SCLK,                      --                        .SCLK
			spi0_SS_n                      => CONNECTED_TO_spi0_SS_n,                      --                        .SS_n
			usb_gpx_export                 => CONNECTED_TO_usb_gpx_export,                 --                 usb_gpx.export
			usb_irq_export                 => CONNECTED_TO_usb_irq_export,                 --                 usb_irq.export
			usb_rst_export                 => CONNECTED_TO_usb_rst_export,                 --                 usb_rst.export
			signewcurx_in_port             => CONNECTED_TO_signewcurx_in_port,             --              signewcurx.in_port
			signewcurx_out_port            => CONNECTED_TO_signewcurx_out_port,            --                        .out_port
			signewcury_in_port             => CONNECTED_TO_signewcury_in_port,             --              signewcury.in_port
			signewcury_out_port            => CONNECTED_TO_signewcury_out_port,            --                        .out_port
			signewmag_in_port              => CONNECTED_TO_signewmag_in_port,              --               signewmag.in_port
			signewmag_out_port             => CONNECTED_TO_signewmag_out_port              --                        .out_port
		);

