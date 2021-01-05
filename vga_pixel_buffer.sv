/* Module implements the pixel buffer for the VGA */
/* includes a datapath with address translation units for transforming VGA beam coordinates into memory addresses,
 * mux for selecting which pixel data to use, register for storing last available pixel data, dual-port RAM for storage,
 * module to assign RGB values to pixels, and control unit module to generate control signals for modules on the datapath.
 */ 
`include "Magic_Numbers.sv"
module vga_pixel_buffer(
	// inputs
	input logic clk,
	input logic reset,
	input logic math_clk,
	input logic color_clk,
	input logic Clear,
	input logic [63:0] curX,
	input logic [63:0] curY,
	input logic [15:0] escape_value,
	input logic [9:0] drawxsig,
	input logic [9:0] drawysig,
	input logic vga_clk,
	input logic Draw,
	input logic draw_frame,
	input logic vga_ready,
	
	// outputs
	output logic done_draw_esc,
	output logic [7:0] VGA_R,
	output logic [7:0] VGA_G,
	output logic [7:0] VGA_B,
	output logic OE_N,
	output logic WE_N
);
	
	logic  [15:0] toRAM;
	logic  [15:0] fromRAM;
	
	logic  [15:0] Pixel_Data;
	logic  [15:0] _Pixel_Data;
	
	logic [18:0] read_address;
	logic [18:0] write_address;
	assign toRAM = escape_value;
	
	
	/* data path of module */
	
	// computes address of pixel to paint with old data
	address_translation_unit addr0 (
									.curX(drawxsig),
									.curY(drawysig),
									.address(read_address)
									);
	
	// computes address of pixel to paint with new data
	address_translation_unit addr1 (
									.curX(curX),
									.curY(curY),
									.address(write_address)
									);
									
	// selects new data or old data depending on status of fractal_engine module
	Mux_module #(.DATA_SIZE(4)) mux0 (
										.A(fromRAM[3:0]),
										.B(Pixel_Data[3:0]),
										.SELECT(~Draw), // Draw is high => use (old) data from RAM. Else, use new pixelData
										.OUT(_Pixel_Data[3:0])
										);	
	// loads intermediate register with data from RAM if VGA critical path timing constraints are met
	Register #(.DATA_SIZE(4)) reg0 (
					.CLK(clk),
					.reset(reset),
					.LD(~vga_ready),
					.Din(_Pixel_Data[3:0]),
					.Dout(fromRAM[3:0])
				);
	
	// writes data to RAM, loads internal register with results
	pxlram ram0 (
				.rdaddress(read_address),
				.wraddress(write_address),
				.rdclock(vga_clk),
				.wrclock(clk),
				.wren(~WE_N),
				.rden(~OE_N),
				.data(toRAM[3:0]),
				.q(Pixel_Data[3:0])
				);
				
	// assigns color value to pixel using data from RAM
	colorize_pixel_unit colorizer(
		.clk(clk),
		.vga_clk(vga_clk),
		.reset(Clear),
		.start(~Draw),
		.drawxsig(drawxsig),
		.drawysig(drawysig),
		.escape_value(fromRAM[3:0]),
		.R(VGA_R),
		.G(VGA_G),
		.B(VGA_B)
	);
	
	// control unit. generates RAM R/W control signals 
	vga_pixel_buffer_control_unit control0(
			.clk(clk),
			.reset(reset),
			.Draw(Draw),
			.OE_N(OE_N),
			.WE_N(WE_N),
			.done_draw_esc(done_draw_esc)
	);

endmodule
