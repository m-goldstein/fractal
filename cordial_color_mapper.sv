`include "Magic_Numbers.sv"

module cordial_color_mapper (
				input logic clk,
				input logic math_clk,
				input logic vga_clk,
				input logic reset,
				input logic do_color,
				input logic[15:0] data_in,
				input logic[31:0] coeff,
				output logic [3:0] data_out,
				output logic done
			);
	logic exec;
	assign exec = do_color;
	
	logic conv_to_float;
	logic calc_phi;
	logic calc_cos;
	logic calc_scale_1;
	logic calc_scale_2;
	logic apply_rgb_scaling;
	logic get_arg_as_float;
	logic done_arg_as_float;
	logic conv_to_int;
	wire [63:0] arg_as_ieee;
	
	int_to_ieee l2d (
					.clk(math_clk),
					.reset(reset),
					.a_in(data_in),
					.a_in_done(conv_to_float),
					.z_out_ack(get_arg_as_float),
					.z_out_done(done_arg_as_float),
					.z_out(arg_as_ieee)
					);
					
	/*fp_rgb_to_float to_float_unit (
			.clk(math_clk),
			.areset(reset),
			.en(conv_to_float),
			.a(data_in),
			.q(arg_as_ieee)
			);
	*/
	
	assign data_out = arg_as_ieee[3:0];
	//logic clear_count;
	//logic[5:0] count, next_count;
	enum logic[3:0] { HALTED, STALL, CONV_TO_FLOAT, ACK, DONE } state, next_state;
	always_ff @ (posedge clk) begin
		state <= (reset) ? HALTED : next_state;
		//count <= (reset) ? 6'b000000 : next_count;
	end
	
	always_comb begin
		done = 0;
		//clear_count = 0;
		//next_count = count;
		conv_to_float = 0;
		get_arg_as_float = 0;
		case (state)
			HALTED: next_state = (reset) ? HALTED : STALL;
			STALL: next_state = (exec) ? CONV_TO_FLOAT : STALL;
			DONE: begin 
				next_state = (~exec) ? DONE : HALTED;
				done = 1;
		
			end
			
			CONV_TO_FLOAT: begin
				conv_to_float = 1;
				next_state = (done_arg_as_float) ? ACK : CONV_TO_FLOAT;
				
			end
			
			ACK: begin
				get_arg_as_float = 1;
				next_state = DONE;
			end
		endcase
	end
endmodule
	/*
	wire[31:0] arg_as_ieee;
	fp_rgb_to_float to_float_unit(
				.clk(math_clk),
				.areset(reset),
				.en(conv_to_float),
				.a(data_in),
				.q(arg_as_ieee)
			);
			
	wire [31:0] _phi;
	logic[31:0] phi;
	fp_rgb_mult phiunit (
				.clk(math_clk),
				.areset(reset),
				.en(calc_phi),
				.a(coeff),
				.b(arg_as_ieee),
				.q(_phi)
				);
	assign phi = _phi;
	wire [31:0] cos_val;
	fp_sinusoid cosunit (
				.clk(math_clk),
				.areset(reset),
				.en(calc_cos),
				.a(phi),
				.q(cos_val)
			);
			
	wire [31:0] scale_1;
	fp_rgb_mult scale_1_unit (
				.clk(math_clk),
				.areset(reset),
				.en(calc_scale_1),
				.a(`NEG_HALF),
				.b(cos_val),
				.q(scale_1)
				);
	
	wire [31:0] scale_2;
	fp_rgb_add scale_2_unit (
				.clk(math_clk),
				.areset(reset),
				.en(calc_scale_2),
				.a(`HALF),
				.b(scale_1),
				.q(scale_2)
				);
				
	wire [31:0] out_as_ieee;
	fp_rgb_mult rgb_scale_unit (
				.clk(math_clk),
				.areset(reset),
				.en(apply_rgb_scaling),
				.a(`RGB_MAX),
				.b(scale_2),
				.q(out_as_ieee)
				);
				
	wire[15:0] out_as_int;
	fp_rgb_to_int to_int_unit (
				.clk(math_clk),
				.areset(reset),
				.en(conv_to_int),
				.a(out_as_ieee),
				.q(out_as_int)
				);
	
	enum logic [4:0] {
		HALTED, CLEAR_COUNT, STALL, CONVERT_TO_IEEE, CALC_PHI, CALC_COS, CONVERT_TO_LONG, SCALE_STEP_1, SCALE_STEP_2, APPLY_RGB_SCALE, CONVERT_TO_INT, DONE, ACK
		} state, next_state;
		
	logic [5:0] count;
	logic [5:0] next_count;
	logic clear_count;
	
	always_ff @ (posedge math_clk or posedge reset) begin
			state <= (reset) ? HALTED : next_state;
			count[5:0] <= (reset || clear_count) ? 6'b000000: next_count[5:0];
			//if (done) begin
				data_out <= out_as_int[3:0];
			//end
		end
		
	always_comb begin
		// next_state = state;
		 conv_to_float = 0;
		 calc_phi = 0;
		 calc_cos = 0;
		 calc_scale_1 = 0;
		 calc_scale_2 = 0;
		 apply_rgb_scaling = 0;
		 conv_to_int = 0;
		 clear_count = 0;
		 next_count = count;
		 //next_count[5:0] = count[5:0];
		 done = 0;
		 //ack_out = 0;
		 case (state)
			HALTED: begin
				next_state = (reset) ? HALTED : STALL;
			end
			
			STALL: begin
				next_state = (exec == 1) ? CONVERT_TO_IEEE : STALL;
			end
			
			CONVERT_TO_IEEE: begin
				conv_to_float = 1;
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 6) begin
					next_state = CALC_PHI;
					clear_count = 1;
				end else
					next_state = CONVERT_TO_IEEE;
				end
			
			CALC_PHI: begin
				calc_phi = 1;
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 6) begin
					next_state = CALC_COS;
					clear_count = 1;
				end else
					next_state = CALC_PHI;
			end
			
			CALC_COS: begin
				calc_cos = 1;
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 34) begin
					next_state = SCALE_STEP_1;
					clear_count = 1;
				end else
					next_state = CALC_COS;
			end
			
			SCALE_STEP_1: begin
				calc_scale_1 = 1;
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 6) begin
					next_state = SCALE_STEP_2;
					clear_count = 1;
				end else
					next_state = SCALE_STEP_1;
				end
			
			SCALE_STEP_2: begin
				calc_scale_2 = 1;
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 9) begin
					next_state = APPLY_RGB_SCALE;
					clear_count = 1;
				end else
					next_state = SCALE_STEP_2;
				end
			
			APPLY_RGB_SCALE: begin
				apply_rgb_scaling = 1;
				
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 6) begin
					next_state = CONVERT_TO_INT;
					clear_count = 1;
				end else
					next_state = APPLY_RGB_SCALE;
			end
			
			CONVERT_TO_INT: begin
				conv_to_int = 1;
				
				next_count[5:0] = count[5:0] + 1'b1;
				if ({6{count}} > 4) begin
					next_state = ACK;
					clear_count = 1;
				end else
					next_state = CONVERT_TO_INT;
			end
			
			ACK: begin
				//ack_out = 1;
				clear_count = 1;
				done = 1;
				next_state = DONE;
			end
			
			DONE: begin
				done = 1;
				clear_count = 1;
				next_state = (~exec) ? HALTED: DONE;
			end
		endcase
	end
endmodule
*/