`include "Magic_Numbers.sv"
module colormap_engine(
		input logic clk,
		input logic reset,
		input logic math_clk,
		input logic start,
		output wire ack,
		input logic[15:0] escape,
		input logic[31:0] coeff,
		output logic [3:0] color,
		output logic done
);
	logic[3:0] color_out, next_color;
	//assign color = color_out;

	logic do_draw;
	assign do_draw = start;
	wire [15:0] escape_ieee;
	logic [31:0] coloring_ieee;
	assign escape_ieee = 16'(signed'(escape)); //64'(signed'(escape));
	logic [31:0] escape_as_ieee;
	//logic get_escape_as_ieee;
	//wire  done_escape_as_ieee;
	logic calc_escape_as_ieee;
	logic reset_int_to_float;
	fp_rgb_to_float to_float(
				.clk(math_clk),
				.areset(reset),
				.en(calc_escape_as_ieee),
				.a(escape_ieee),
				.q(escape_as_ieee)
				);
	/*
	int_to_ieee escape_as_ieee_term(
				.clk(math_clk),
				.reset(reset),
				.a_in(escape_ieee),
				.a_in_done(calc_escape_as_ieee),
				.z_out_ack(get_escape_as_ieee),
				.z_out_done(done_escape_as_ieee),
				.z_out(escape_as_ieee)
	);
	*/
	
	logic [31:0] phi;
	wire get_phi;
	wire done_phi;
	reg calc_phi;
	reg reset_calc_phi;
	fp_rgb_mult mult0 (
					.clk(math_clk),
					.areset(reset),
					.en(calc_phi),
					.a(coeff),
					.b(escape_as_ieee),
					.q(phi)
				);
	reg calc_cos;
	reg reset_calc_cos;
	logic [31:0] cos_out;
	fp_sinusoid cos_unescape (
					.clk(math_clk),
					.areset(reset),
					.en(calc_cos),
					.a(phi),
					.q(cos_out)
				);
	reg calc_scale_1;
	logic [31:0] scale_1;
	reg reset_scale_1;
	fp_rgb_mult scale0 (
					.clk(math_clk),
					.areset(reset),
					.en(calc_scale_1),
					.a(`NEG_HALF),
					.b(cos_out),
					.q(scale_1)
				);
	
	reg calc_scale_2;
	logic [31:0] scale_2;
	reg reset_scale_2;
	fp_rgb_add scale1 (
					.clk(math_clk),
					.areset(reset),
					.en(calc_scale_2),
					.a(`HALF),
					.b(scale_1),
					.q(scale_2)
				);
	reg calc_scale_3;
	logic [31:0] scale_3;
	reg reset_scale_3;
	fp_rgb_mult scale2 (
					.clk(math_clk),
					.areset(reset),
					.en(calc_scale_3),
					.a(`RGB_MAX),
					.b(scale_2),
					.q(scale_3)
				);
	
	reg convert_to_int;
	reg reset_to_int;
	wire [15:0] rgb_as_int;
	fp_rgb_to_int to_int(
					.clk(math_clk),
					.areset(reset),
					.en(convert_to_int),
					.a(scale_3),
					.q(rgb_as_int)
				);
	assign color = rgb_as_int[3:0];
	enum logic [4:0] {
		HALTED, CLEAR_COUNT, STALL, CONVERT_escape_TO_IEEE, CALC_PHI, CALC_COS, CONVERT_TO_LONG, SCALE_STEP_1, SCALE_STEP_2, SCALE_STEP_3, CONVERT_TO_INT, DONE, ACK
		} state, next_state;
	logic [5:0] count, next_count;
	logic clear_count;
		always_ff @ (posedge clk) begin
			state <= (reset) ? HALTED : next_state;
			count <= (reset || clear_count) ? 6'h000000: next_count;
		end
	logic ack_out;
	assign ack = ack_out;
	always_comb begin
		 next_state = state;
		 calc_escape_as_ieee = 0;
		 //reset_int_to_float = 0;
		 calc_phi = 0;
		 //reset_calc_phi = 0;
		 calc_cos = 0;
		 //reset_calc_cos = 0;
		 calc_scale_1 = 0;
		 ///reset_scale_1 = 0;
		 //reset_scale_2 = 0;
		 //reset_scale_3 = 0;
		 calc_scale_2 = 0;
		 calc_scale_3 = 0;
		 convert_to_int = 0;
		 //reset_to_int = 0;
		 clear_count = 0;
		 next_count = count;
		 done = 0;
		 ack_out = 0;
		 case (state)
			HALTED: begin
				//done = 1;
				//reset_int_to_float = 1;
				//reset_calc_phi = 1;
				//reset_calc_cos = 1;
				//reset_scale_1 = 1;
				//reset_scale_2 = 1;
				//reset_scale_3 = 1;
				//reset_to_int = 1;
				next_state = (reset) ? HALTED : STALL;
			end
			
			STALL: begin
				next_state = (do_draw == 1) ? CONVERT_escape_TO_IEEE : STALL;
			end
			
			CONVERT_escape_TO_IEEE: begin
				calc_escape_as_ieee = 1;
				next_count = count + 1;
				if (count > 5) begin
					next_state = CALC_PHI;
					clear_count = 1;
				end else
					next_state = CONVERT_escape_TO_IEEE;
				//next_state = (count > 11) ? CALC_PHI: CONVERT_escape_TO_IEEE;
				//next_state = (done_escape_as_ieee) ? CALC_PHI : CONVERT_escape_TO_IEEE;
			end
			
			CALC_PHI: begin
				calc_phi = 1;
				next_count = count + 1;
				if (count > 6) begin
					next_state = CALC_COS;
					clear_count = 1;
				end else
					next_state = CALC_PHI;
				
				//next_state = CALC_COS;
				//next_state = (done_phi) ? CALC_COS : CALC_PHI;
				
			end
			
			CALC_COS: begin
				calc_cos = 1;
				next_count = count + 1;
				if (count > 34) begin
					next_state = SCALE_STEP_1;
					clear_count = 1;
				end else
					next_state = CALC_COS;
				
				//next_state = SCALE_STEP_1;
				//next_state = (calc_cos_done) ? CONVERT_TO_LONG : CALC_COS;
			end
			SCALE_STEP_1: begin
				calc_scale_1 = 1;
				next_count = count + 1;
				if (count > 6) begin
					next_state = SCALE_STEP_2;
					clear_count = 1;
				end else
					next_state = SCALE_STEP_1;
				
				//next_state = SCALE_STEP_2;
				//calc_cos_as_long = 1;
				//next_state = (done_cos_as_long) ? SCALE_STEP_1 : CONVERT_TO_LONG;
			end
			
			SCALE_STEP_2: begin
				//scale_2 = int'(-0.5 * cos_as_long + 0.5);
				calc_scale_2 = 1;
				next_count = count + 1;
				if (count > 9) begin
					next_state = SCALE_STEP_3;
					clear_count = 1;
				end else
					next_state = SCALE_STEP_2;
				
				//next_state = SCALE_STEP_3;
				//apply_scale_1 = 1;
				//next_state = (done_scale_1) ? SCALE_STEP_2 : SCALE_STEP_1;
			end
			
			SCALE_STEP_3: begin
				calc_scale_3 = 1;
				
				next_count = count + 1;
				if (count > 6) begin
					next_state = CONVERT_TO_INT;
					clear_count = 1;
				end else
					next_state = SCALE_STEP_3;
				
				//scale_2 = 255 * scale_1;
				//next_state = CONVERT_TO_INT;
				//coloring = 255 * coloring;
				//apply_scale_2 = 1;
				//next_state = (done_scale_2) ? SCALE_STEP_3 : SCALE_STEP_2;
			end
			CONVERT_TO_INT: begin
				convert_to_int = 1;
				
				next_count = count + 1;
				if (count > 4) begin
					next_state = ACK;
					clear_count = 1;
				end else
					next_state = CONVERT_TO_INT;
				
				//next_state = ACK;
			end
			
			ACK: begin
				//next_state = state;
				//calc_rcos = 0;
				//calc_bcos = 0;
				//get_escape_as_ieee = 1;
				//get_phi = 1;
				//get_gphi = 1;
				//next_color = scale_2;
				//color_next = color_out;
				//get_scale_1 = 1;
				//get_scale_2 = 1;
				//get_rgb = 1;
				//done = 1;
				//get_color_as_long = 1;
				//get_cos_as_long = 1;
				ack_out = 1;
				clear_count = 1;
				next_state = DONE;
			end
			
			DONE: begin
				//next_color = scale_2;
				done = 1;
				//clear_count = 1;
				next_state = (~do_draw) ? HALTED: DONE;
			end
			//SCALE_STEP_3: begin
				//calc_rgb = 1;
				//next_state = (done_rgb) ? CONVERT_ARGS_TO_LONGS : SCALE_STEP_3;
			//end
			
			//CONVERT_ARGS_TO_LONGS: begin
			//	calc_color_as_long = 1;
			//	next_state = (done_color_as_long ) ? DONE : CONVERT_ARGS_TO_LONGS;
			//end
			
			//DONE:begin
			//	next_color = 8'(unsigned'(coloring));
				//next_color = 8'(signed'(coloring[63:57]));
			//	next_state = ACK;
			//end
			
		endcase
	end
	
endmodule
