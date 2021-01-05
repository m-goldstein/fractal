//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8 (

      ///////// Clocks /////////
      input              Clk,
		input					 Clk_100,	//		not needed anymore
		//input					 Clk_150,				|
		///input					 Clk_200,				V
      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N
	

);


logic Reset_h, vssig, blank, sync, VGA_Clk;
// declare R/W signals for RAM.
logic oe_n, we_n, OE_N, WE_N;

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	//HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	//assign HEX4[7] = 1'b1;
	
	//HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	//assign HEX3[7] = 1'b1;
	
	//HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	//assign HEX1[7] = 1'b1;
	
	//HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	//assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	//assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	//assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);
	logic Clear_h;
	assign {Clear_h}= ~ (KEY[1]);
	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	

//instantiate a vga_controller, ball, and color_mapper here with the ports.

vga_controller vga_c (.Clk(Clk),
							 .Reset(Reset_h),
							 .hs(VGA_HS), // Horizontal sync
							 .vs(VGA_VS), // Vertical sync
							 .pixel_clk(VGA_Clk), // VGA Clk (25 MHz)
							 .blank(blank), // blank
							 .sync(sync),   // sync
							 .DrawX(drawxsig), 
							 .DrawY(drawysig));


logic math_clk;
logic Left, Right, Up, Down, Magnify, Demagnify; // logical wires for key presses
//logic Inc_Speed, Dec_Speed;
								
logic signewcurX_in, signewcurX_out;
logic signewcurY_in, signewcurY_out;

logic [63:0] curX, curY;
logic [63:0] dX, dY;
wire [63:0] curX_from_NIOS, curY_from_NIOS;

// registers for translational/scaling signals
logic go_up;
logic go_down;
logic go_left;
logic go_right;
logic go_magnify;
logic go_demagnify;

// registers for communicating orientation changes between modules
logic x_updated;
logic y_updated;
logic ack;

		
assign signewcurX_in = x_updated;
assign signewcurY_in = y_updated;
logic draw_frame = 1'b1;
logic MagnificationAck;
logic [63:0] Magnification;
logic signewmag_in, signewmag_out;
wire  [63:0] Magnification_from_NIOS;
wire  [63:0] Magnification_to_NIOS;
		
	lab8_soc u0 (
		.clk_clk                           (Clk),            //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		//.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
		// input ports
		.curx_w0_in_port(curX[31:0]),
		.curx_w1_in_port(curX[63:32]),
		.cury_w0_in_port(curY[31:0]),
		.cury_w1_in_port(curY[63:32]),
		.mag_w0_in_port(Magnification_to_NIOS[31:0]),
		.mag_w1_in_port(Magnification_to_NIOS[63:32]),
		.signewcurx_in_port(signewcurX_in),
		.signewcury_in_port(signewcurY_in),
		.signewmag_in_port(signewmag_in),
		
		// output ports
		.curx_w0_out_port(curX_from_NIOS[31:0]),
		.curx_w1_out_port(curX_from_NIOS[63:32]),
		.cury_w0_out_port(curY_from_NIOS[31:0]),
		.cury_w1_out_port(curY_from_NIOS[63:32]),
		.mag_w0_out_port(Magnification_from_NIOS[31:0]),
		.mag_w1_out_port(Magnification_from_NIOS[63:32]),
		.signewcurx_out_port(signewcurX_out),
		.signewcury_out_port(signewcurY_out),
		.signewmag_out_port(signewmag_out)
	 );
	 
	 assign Magnification_to_NIOS = Magnification;
	 
	 
	/* module to store current location data */
	explore_unit explorer (
			.clk(Clk),
			.reset(Reset_h),
			.up(go_up),
			.down(go_down),
			.left(go_left),
			.right(go_right),
			.dX(dX),
			.dY(dY),
			.x_ack(x_updated),
			.y_ack(y_updated)
	);
	
	/* module to decode keycodes from NIOSII hardware and encode signals to be passed to fractal core modules */
	Keycode_Mapper keycode_mapper(
									.keycode_in(keycode),
									.LEFT(Left),
									.RIGHT(Right),
									.UP(Up),
									.DOWN(Down),
									.ZOOM_IN(Magnify),
									.ZOOM_OUT(Demagnify)
									//.INC_SPEED(Inc_Speed),
									//.DEC_SPEED(Dec_Speed)
								);
	
	/* 50MHz - Frequency of input Clock 
	 * Divide by 1 (50 MHz)
	 * Multiply by 3 (150 MHz)
	 */
	/* generates a 150 MHz clock for the compute modules */
	 altpll_module #(50, 1, 3 ) fractal_pll (
		.clk_in(Clk),
	   .clk_out(math_clk)
	 );  
	  
	  
	  /* this module stores information about the scaling factor and applies it to each 2D-translation on the plane 
	 * to create the effect of zooming in / out on the fractal.
	 */
	Magnifier_Reg magnifierreg0(
		.clk(Clk),
		.math_clk(math_clk),
		.reset(Reset_h),
		.Increase_Magnification(go_magnify),
		.Decrease_Magnification(go_demagnify),
		.Magnification(Magnification),
		.ack(MagnificationAck)
	);
	  
	  /* This module instantiates modules involved with fractal computations, memory I/O, and VGA timing.
	   * This is similar to lab9 how one module implemented the majority of the IP core.
	   */ 
	 fractal_core_interface fractal_core(
		.clk(Clk),
		.vga_clk(VGA_Clk),
		.reset(Reset_h),
		.Clear(Clear_h),
		.math_clk(math_clk),
		.color_clk(math_clk),
		//.color_clk(Clk_200),
		.go_up(go_up),
		.go_down(go_down),
		.go_left(go_left),
		.go_right(go_right),
		.go_magnify(go_magnify),
		.go_demagnify(go_demagnify),
		.sigack(ack),
		.SW(SW),
		.up(Up),
		.down(Down),
		.left(Left),
		.right(Right),
		.magnify(Magnify),
		.demagnify(Demagnify),
		.signewmag(MagnificationAck),
		.dX_in(dX),
		.dY_in(dY),
		.signewcurX_in(signewcurX_out), // from NIOS
		.signewcurY_in(signewcurY_out), // from NIOS
		.curX_in(curX_from_NIOS),
		.curY_in(curY_from_NIOS),
		.curX_out(curX),
		.curY_out(curY),
		//.signewcurX_out(signewcurX_in), // to NIOS
		//.signewcurY_out(signewcurY_in), // to NIOS
		.magnification(Magnification),
		.draw_frame(draw_frame),
		.KEY(KEY),
		.drawxsig(drawxsig),
		.drawysig(drawysig),
		.VGA_R(Red),
		.VGA_G(Green),
		.VGA_B(Blue),
		.OE_N(oe_n),
		.WE_N(we_n)
	 );
		assign OE_N = oe_n;
		assign WE_N = we_n;
		
		HexDriver hex_inst_5 (Magnification[7:4], HEX5);
		HexDriver hex_inst_4 (Magnification[3:0], HEX4);
		HexDriver hex_inst_3 (curY[7:4], HEX3);
		HexDriver hex_inst_2 (curY[3:0], HEX2);
		HexDriver hex_inst_1 (curX[7:4], HEX1);
		HexDriver hex_inst_0 (curX[3:0], HEX0);
endmodule
