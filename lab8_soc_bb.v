
module lab8_soc (
	clk_clk,
	curx_w0_in_port,
	curx_w0_out_port,
	curx_w1_in_port,
	curx_w1_out_port,
	cury_w0_in_port,
	cury_w0_out_port,
	cury_w1_in_port,
	cury_w1_out_port,
	hex_digits_export,
	key_external_connection_export,
	keycode_export,
	leds_export,
	mag_w0_in_port,
	mag_w0_out_port,
	mag_w1_in_port,
	mag_w1_out_port,
	reset_reset_n,
	sdram_clk_clk,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	spi0_MISO,
	spi0_MOSI,
	spi0_SCLK,
	spi0_SS_n,
	usb_gpx_export,
	usb_irq_export,
	usb_rst_export,
	signewcurx_in_port,
	signewcurx_out_port,
	signewcury_in_port,
	signewcury_out_port,
	signewmag_in_port,
	signewmag_out_port);	

	input		clk_clk;
	input	[31:0]	curx_w0_in_port;
	output	[31:0]	curx_w0_out_port;
	input	[31:0]	curx_w1_in_port;
	output	[31:0]	curx_w1_out_port;
	input	[31:0]	cury_w0_in_port;
	output	[31:0]	cury_w0_out_port;
	input	[31:0]	cury_w1_in_port;
	output	[31:0]	cury_w1_out_port;
	output	[15:0]	hex_digits_export;
	input	[1:0]	key_external_connection_export;
	output	[7:0]	keycode_export;
	output	[13:0]	leds_export;
	input	[31:0]	mag_w0_in_port;
	output	[31:0]	mag_w0_out_port;
	input	[31:0]	mag_w1_in_port;
	output	[31:0]	mag_w1_out_port;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	input		spi0_MISO;
	output		spi0_MOSI;
	output		spi0_SCLK;
	output		spi0_SS_n;
	input		usb_gpx_export;
	input		usb_irq_export;
	output		usb_rst_export;
	input		signewcurx_in_port;
	output		signewcurx_out_port;
	input		signewcury_in_port;
	output		signewcury_out_port;
	input		signewmag_in_port;
	output		signewmag_out_port;
endmodule
