/* testbench for complex adder module */
/*
module testbench();

	//timeunit 10ns;
	//timeprecision 1ns;
	logic clk;
	logic reset;
	logic start;
	logic [63:0] re_a;
	logic [63:0] re_b;
	logic [63:0] im_a;
	logic [63:0] im_b;
	wire [63:0] re_z;
	wire [63:0] im_z;
	
	always begin : CLOCK_GEN
		#1 clk = ~clk;
	end
	
	initial begin : OK
		#1 reset = 0;
		#1 start = 0;
		#1 reset = 1;
		#1 reset = 0;
		#1 start = 1;
		
		
	end
	initial begin : CLOCKINIT
		clk = 0;
	end
	
	initial begin
		//re_a <= 64'h4000000000000000; // 2
		//re_b <= 64'h4000000000000000; // 2
		//im_a <= 64'h3ff0000000000000; // 1
		//im_b <= 64'h3ff0000000000000; // 1
		//re_z <= 64'h0;
		//im_z <= 64'h0;
		#5 start <= 1;
		
	end
	
	adder_unit add0(
		.clk(clk),
		.reset(reset),
		.start(start),
		.re_a(re_a),
		.re_b(re_b),
		.im_a(im_a),
		.im_b(im_b),
		.re_z(re_z),
		.im_z(im_z)
		);
	
	
endmodule
*/
// testbench for complex multiply
/*
module testbench();

	//timeunit 10ns;
	//timeprecision 1ns;
	logic clk;
	logic reset;
	logic start;
	logic done;
	logic ack;
	logic [63:0] re_a;
	logic [63:0] re_b;
	logic [63:0] im_a;
	logic [63:0] im_b;
	wire [63:0] re_z;
	wire [63:0] im_z;
	
	always begin : CLOCK_GEN
		#1 clk = ~clk;
	end
	
	initial begin : OK
		#1 reset = 0;
		#1 start = 0;
		#1 reset = 1;
		#1 reset = 0;
		#1 start = 1;
		#1 ack = 0;
		
	end
	initial begin : CLOCKINIT
		clk = 0;
	end
	
	initial begin
		//re_a <= 64'h4000000000000000; // 2
		//re_b <= 64'h4000000000000000; // 2
		//im_a <= 64'h3ff0000000000000; // 1
		//im_b <= 64'h3ff0000000000000; // 1
		re_a <= 64'h3ff8000000000000; // 1.5
		re_b <= 64'h4000000000000000; // 2
		im_a <= 64'h3ff4000000000000; // 1.25
		im_b <= 64'h3ff0000000000000; // 1
		
		//re_z <= 64'h0;
		//im_z <= 64'h0;
		#5 start <= 1;
		ack <= 0;
		
	end
	
	multiplier_unit mult0(
		.clk(clk),
		.reset(reset),
		.start(start),
		.done(done),
		.ack(ack),
		.re_a(re_a),
		.re_b(re_b),
		.im_a(im_a),
		.im_b(im_b),
		.re_z(re_z),
		.im_z(im_z)
		);
	
endmodule
*/
/* testbench for complex magnitude module 
module testbench();

	//timeunit 10ns;
	//timeprecision 1ns;
	logic clk;
	logic reset;
	logic start;
	logic done;
	logic ack;
	logic [63:0] re_a;
	logic [63:0] re_b;
	logic [63:0] im_a;
	logic [63:0] im_b;
	wire [63:0] re_z;
	wire [63:0] im_z;
	
	always begin : CLOCK_GEN
		#1 clk = ~clk;
	end
	
	initial begin : OK
		#1 reset = 0;
		#1 start = 0;
		#1 reset = 1;
		#1 reset = 0;
		#1 start = 1;
		#1 ack = 0;
		
	end
	initial begin : CLOCKINIT
		clk = 0;
	end
	
	initial begin
		//re_a <= 64'h4000000000000000; // 2
		//re_b <= 64'h4000000000000000; // 2
		//im_a <= 64'h3ff0000000000000; // 1
		//im_b <= 64'h3ff0000000000000; // 1
		re_a <= 64'h3ff8000000000000; // 1.5
		re_b <= 64'h4000000000000000; // 2
		im_a <= 64'h3ff4000000000000; // 1.25
		im_b <= 64'h3ff0000000000000; // 1
		
		//re_z <= 64'h0;
		//im_z <= 64'h0;
		#5 start <= 1;
		ack <= 0;
		
	end
	magnitude_unit mag0(
		.clk(clk),
		.reset(reset),
		.start(start),
		.done(done),
		.ack(ack),
		.re_in(re_a),
		.im_in(im_a),
		.mag_out(re_z) // should be 3.8125
		);
	
endmodule
*/
/*
module testbench();

	//timeunit 10ns;
	//timeprecision 1ns;
	logic clk;
	logic reset;
	logic start;
	logic done;
	logic ack;
	logic inc_mag;
	logic dec_mag;
	logic [63:0] re_a;
	logic [63:0] re_b;
	logic [63:0] im_a;
	logic [63:0] im_b;
	wire [63:0] re_z;
	wire [63:0] im_z;
	logic[63:0] magnify_factor_asInt;
	logic z_ack, z_ack_out;
	always begin : CLOCK_GEN
		#1 clk = ~clk;
	end
	
	initial begin : OK
		#1 reset = 0;
		#1 start = 0;
		#1 reset = 1;
		#1 reset = 0;
		#1 start = 1;
		#1 inc_mag = 0;
		#1 dec_mag = 0;
		
		//#5 inc_mag = 1;
		//#50 inc_mag = 0;
		//#20 dec_mag = 1;
		//#50 dec_mag = 0;
	end
	initial begin : CLOCKINIT
		clk = 0;
	end
	
	initial begin
		//re_a <= 64'h4000000000000000; // 2
		//re_b <= 64'h4000000000000000; // 2
		//im_a <= 64'h3ff0000000000000; // 1
		//im_b <= 64'h3ff0000000000000; // 1
		re_a <= 64'h3ff8000000000000; // 1.5
		re_b <= 64'h4000000000000000; // 2
		im_a <= 64'h3ff4000000000000; // 1.25
		im_b <= 64'h3ff0000000000000; // 1
		inc_mag <= 1'h1;
		dec_mag <= 1'h0;
		//re_z <= 64'h0;
		//im_z <= 64'h0;
		#5 start <= 1;
		inc_mag <= 1'h1;
		 Increase magnify tests 
		#100 inc_mag <= 1'h0;
		#100 inc_mag <= 1'h1;
		#100 inc_mag <= 1'h0;
		#100 inc_mag <= 1'h1;
		#100 inc_mag <= 1'h0;
		 Decrease magnify tests 
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
		#100 dec_mag <= 1'h1;
		#100 dec_mag <= 1'h0;
	end
	Magnifier_Reg magreg0 (
		.clk(clk),
		.reset(reset),
		.Increase_Magnification(inc_mag),
		.Decrease_Magnification(dec_mag),
		.Magnification(re_z),
		.ack(ack)
	);
	ieee_to_int zoom_factor_converter (
		.clk(clk),
		.reset(reset),
		.a_in(re_z),
		.a_in_done(ack),
		.a_in_ack(z_ack),
		.z_out_ack(ack),
		.z_out_done(z_ack_out),
		.z_out(magnify_factor_asInt)
	);
endmodule
*/

`include "Magic_Numbers.sv"
module testbench();

timeunit 10ns;
timeprecision 1ns;

logic clk = 0;
logic vga_clk = 0;
logic math_clk = 0;
logic reset;
logic[7:0] escape;
logic Draw;
logic [9:0] drawxsig, drawysig;
logic [7:0] R, G, B;
logic done;
logic Clear = reset;
logic draw_screen;
//smart_color_mapper c0(
//    .clk(clk),
//	 .reset(reset),
//	 .it(it),
//	 .*
//);
	cordial_color_mapper c0 (
				.clk(clk),
				.math_clk(math_clk),
				.vga_clk(vga_clk),
				.reset(reset),
				.do_color(~Draw),
				.data_in(escape),
				.coeff(`COEFF_A),
				.data_out(R),
				.done(done)
				);
	always begin: CLOCK_GEN
	#1 clk = ~clk;
		vga_clk = ~vga_clk;
		math_clk = ~math_clk;
	end
	
	initial begin: CLOCK_INIT
		escape = 3;
		vga_clk = 0;
		math_clk = 0;
		drawxsig = 2;
		drawysig =4;
		Draw = 0;
		clk = 0;
	end
	
	initial begin: TEST_VECTORS
		#2 reset = 1;
		#5 reset = 0;
		#10 Draw = 0;
		#15 Draw = 1;
		#400 Draw =0;
		#30000 reset = 1;
		#400 escape = 5;
		#500 drawxsig = 4;
		#200 drawysig = 29;
		
		#2000 reset = 0;
		#2000 Draw = 0;
		
		#2100 Draw = 1;
		#20000 Draw = 0;
		#20000 Draw= 1;
		#10000 Draw = 0;
		#30000 reset = 1;
		#400 escape = 12;
		#500 drawxsig = 34;
		#200 drawysig = 229;
		
		#2000 reset = 0;
		#2000 Draw = 0;
		
		#2100 Draw = 1;
		#20000 Draw = 0;
		#20000 Draw = 1;
		#10000 Draw = 0;
		//#200 Draw = 0;
		//#400 Draw = 1;
	end
endmodule

/*
logic startute;
logic draw_screen = 1;
logic ack;
logic [63:0] X, Y, X_Delta, Y_Delta;
logic [9:0] escape_value;
logic done;
logic [63:0] zoom = 64'h3FF0000000000000;
always begin : CLOCK_GENERATION
#1	clk = ~clk;
end

initial begin : CLOCK_INITIALIZATION
	X = 0;
	Y = 0;
	X_Delta = -10;
	Y_Delta = -10;
	clk = 0;
	startute = 0;
	$display("!!!! %X\n", `SCREEN_X_DIV);
end
wire[15:0] SRAM_DQ;
wire[19:0] SRAM_ADDR;



initial begin : TEST_VECTORS
#2 reset = 1;
#5 reset = 0;
#6 startute = 1;
#8 startute = 0;
#2 draw_screen = 0;
#12 X = 1;
#13 Y = 2;
#2 draw_screen = 1;
#200 startute = 1;
#2 startute = 0;
end


endmodule

*/