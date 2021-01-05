`include "Magic_Numbers.sv"

module smart_color_mapper (
    input logic clk,
	 input logic math_clk,
	 input logic vga_clk,
	 input logic reset,
	 input logic Clear,
    input logic [7:0] escape,
	 input logic Draw,
	 input logic[9:0] drawxsig, drawysig,
    input logic draw_screen,
	 output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B,
	 
	 output logic done
	 
);
	logic do_coloring;
	logic do_draw;
	//logic [63:0] escape_ieee;
	//logic [63:0] coloring_ieee;
	//assign escape_ieee = 64'(unsigned'(escape));
	assign do_draw = Draw;
	//wire [63:0] _RGB;
	logic [15:0] _R, _G, _B;
	
	logic[23:0] palette[15:0];
	always_comb begin
			palette[0] = 24'h1415ff;
			palette[1] = 24'h1ea18f;
			palette[2] = 24'he4d58f;
			palette[3] = 24'h03d5ef;
			palette[4] = 24'hf713ef;
			palette[5] = 24'hdd7828;
			palette[6] = 24'hf478bd;
			palette[7] = 24'h36eff5;
			palette[8] = 24'h9d3df5;
			palette[9] = 24'h68fe38;
			palette[10] = 24'h09f4dc;
			palette[11] = 24'h190a7a;
			palette[12] = 24'h660dc6;
			palette[13] = 24'hc150fc;
			palette[14] = 24'heeec19;
			palette[15] = 24'hbf4ad8;
		end
	assign _R = {16{(palette[escape][23:16])}};
	assign _G = {16{(palette[escape][15:8])}};
	assign _B = {16{(palette[escape][7:0])}};
	wire[31:0] R_asF, G_asF, B_asF;
	wire[15:0] R_asI, G_asI, B_asI;
	logic do_to_float;
	logic do_to_int;
	fp_rgb_to_float rf (
						.clk(math_clk),
						.areset(reset),
						.en(do_to_float),
						.a(_R),
						.q(R_asF)
					);
	fp_rgb_to_float gf (
						.clk(math_clk),
						.areset(reset),
						.en(do_to_float),
						.a(_G),
						.q(G_asF)
					);
	fp_rgb_to_float bf (
						.clk(math_clk),
						.areset(reset),
						.a(_B),
						.en(do_to_float),
						.q(B_asF)
					);
	logic do_cos;
	wire[31:0] r_cos, g_cos, b_cos;
	fp_sinusoid rcos (
						.clk(math_clk),
						.areset(reset),
						.en(do_cos),
						.a(R_asF),
						.q(r_cos)
					);
	fp_sinusoid gcos (
						.clk(math_clk),
						.areset(reset),
						.en(do_cos),
						.a(G_asF),
						.q(g_cos)
					);
	fp_sinusoid bcos (
						.clk(math_clk),
						.areset(reset),
						.en(do_cos),
						.a(B_asF),
						.q(b_cos)
					);
	logic do_scale;
	
	wire [31:0] cR, cG, cB;
	fp_rgb_mult scaleR (
					.clk(math_clk),
					.areset(reset),
					.en(do_scale),
					.a(r_cos),
					.b(`RGB_MAX),
					.q(cR)
				);
	fp_rgb_mult scaleG (
					.clk(math_clk),
					.areset(reset),
					.en(do_scale),
					.a(g_cos),
					.b(`RGB_MAX),
					.q(cG)
				);
	fp_rgb_mult scaleB (
					.clk(math_clk),
					.areset(reset),
					.en(do_scale),
					.a(b_cos),
					.b(`RGB_MAX),
					.q(cB)
				);
	fp_rgb_to_int rInt (
						.clk(math_clk),
						.areset(reset),
						.en(do_to_int),
						.a(cR),
						.q(R_asI)
					);
	
	fp_rgb_to_int gInt (
						.clk(math_clk),
						.areset(reset),
						.en(do_to_int),
						.a(cG),
						.q(G_asI)
					);
	
	fp_rgb_to_int bInt (
						.clk(math_clk),
						.areset(reset),
						.en(do_to_int),
						.a(cB),
						.q(B_asI)
					);
	logic [7:0] Ro, Go, Bo;
	logic [7:0] R_next, G_next, B_next;
	always_ff @ (posedge reset or negedge clk) begin: colorize
		if (reset) begin
			if (drawxsig & drawysig) begin
				R <= 8'h00;
				G <= 8'h00;
				B <= 8'h00;
			end
			else begin
				R <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0 : 8'h0a;
				G <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0 : 8'h0a;
				B <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0 : 8'h0a;
			end
		end
		else begin
			//R <= R_next;
			//G <= G_next;
			//B <= B_next;
			//if (done) begin//(do_draw == 1) begin
				R <= R_asI[7:0];//R <= (palette[escape][23:16]);
				G <= G_asI[7:0];//G <= (palette[escape][15:8]);
				B <= B_asI[7:0];//B <= (palette[escape][7:0]);
			//end
		end
	end
	//assign R = Ro;
	//assign G = Go;
	//assign B = Bo;
	logic [5:0] count, next_count;
	logic clear_count;
	enum logic[3:0] { HALTED, STALL, CONVERT_TO_FLOAT, CALC_COS, SCALE, CONVERT_TO_INT, ACK, DONE } state, next_state;
	always_ff @ (posedge clk or posedge reset or posedge clear_count) begin
		state <= (reset) ? HALTED : next_state;
		count <= (reset || clear_count) ? 6'h000000: next_count;
		
		end
	//logic ack_out;
	//assign ack = ack_out;
	always_comb begin
		 next_state = state;
		 do_to_float = 0;
		 do_to_int = 0;
		 do_cos = 0;
		 do_scale = 0;
		 next_count = count;
		 done = 0;
		 clear_count = 0;
		 R_next = R;
		 G_next = G;
		 B_next = B;
		 case (state)
			HALTED: begin
				R_next = 8'h0;
				G_next = 8'h0;
				B_next = 8'h0;
				next_state = (reset) ? HALTED : STALL;
			end
			
			STALL: begin
				next_state = (do_draw ) ? CONVERT_TO_FLOAT : STALL;
			end
			
			CONVERT_TO_FLOAT: begin
				do_to_float = 1;
				next_count = count + 1;
				if (count > 5) begin
					next_state = CALC_COS;
					clear_count = 1;
				end else
					next_state = CONVERT_TO_FLOAT;
				//next_state = (count > 11) ? CALC_PHI: CONVERT_escape_TO_IEEE;
				//next_state = (done_escape_as_ieee) ? CALC_PHI : CONVERT_escape_TO_IEEE;
			end
			
			CALC_COS: begin
				do_cos = 1;
				next_count = count + 1;
				if (count > 34) begin
					next_state = SCALE;
					clear_count = 1;
				end else
					next_state = CALC_COS;
				
				//next_state = CALC_COS;
				//next_state = (done_phi) ? CALC_COS : CALC_PHI;
				
			end
			
			SCALE: begin
				do_scale = 1;
				next_count = count + 1;
				if (count > 6) begin
					next_state = CONVERT_TO_INT;
					clear_count = 1;
				end else
					next_state = SCALE;
				
				//next_state = SCALE_STEP_1;
				//next_state = (calc_cos_done) ? CONVERT_TO_LONG : CALC_COS;
			end
		
			CONVERT_TO_INT: begin
				do_to_int = 1;
				
				next_count = count + 1;
				if (count > 4) begin
					next_state = ACK;
					clear_count = 1;
				end else
					next_state = CONVERT_TO_INT;
				
				//next_state = ACK;
			end
			
			ACK: begin
				next_state = DONE;
				R_next <= R_asI[7:0];//R <= (palette[escape][23:16]);
				G_next <= G_asI[7:0];//G <= (palette[escape][15:8]);
				B_next <= B_asI[7:0];//B <= (palette[escape][7:0]);
			end
			
			DONE: begin
				done = 1;
				next_state = (~do_draw) ? HALTED: DONE;
			end
		endcase
	end
endmodule
	/*
	wire[63:0] escape_as_ieee;
	logic ack_r, ack_g, ack_b;
	logic done_r, done_g, done_b;
	assign done = (done_r && done_g && done_b);
	logic[7:0] _R, _G, _B, R_out, G_out, B_out;
	colormap_engine rgb_r (
							.clk(clk),
							.reset(reset),
							.math_clk(math_clk),
							.start(do_coloring),
							.ack(ack_r),
							.escape(escape),
							.coeff(`COEFF_A),
							.color(_R),
							.done(done_r)
						);
	
	colormap_engine rgb_g (
							.clk(clk),
							.reset(reset),
							.math_clk(math_clk),
							.start(do_coloring),
							.ack(ack_g),
							.escape(escape),
							.coeff(`COEFF_B),
							.color(_G),
							.done(done_g)
						);
	colormap_engine rgb_b (
							.clk(clk),
							.reset(reset),
							.math_clk(math_clk),
							.start(do_coloring),
							.ack(ack_b),
							.escape(escape),
							.coeff(`COEFF_C),
							.color(_B),
							.done(done_b)
						);
	*/
	//assign _B = palette[escape[3:0]][7:0];
	//assign R = R_out;
	//assign G = G_out;
	//assign B = B_out;
	//logic[7:0] R_next, G_next, B_next;
	/*enum logic[2:0] { HALTED, STALL, DO_COLORING, ACK, DONE } state, next_state;
	always_ff @ (posedge reset or posedge clk) begin
		state <= (reset) ? HALTED : next_state;
		R_out <= (reset) ? 8'(drawxsig[3] ^ drawysig[4]) : R_next; //R_next;
		G_out <= (reset) ? 8'(drawxsig[3] ^ drawysig[4]) : G_next; //G_next;
		B_out <= (reset) ? 8'(drawxsig[3] ^ drawysig[4]) : B_next; //B_next;
	end
	
	always_ff @ (posedge reset or negedge clk or posedge Clear) begin: colorize
		if (Clear) begin
			if (drawxsig & drawysig) begin
				//R <= 8'h00;
				//G <= 8'h00;
				//B <= 8'h00;
			end
			else begin
				//R <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0 : 8'h0a;
				//G <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0 : 8'h0a;
				//B <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0 : 8'h0a;
			end
		end
		else begin
		//	if (do_draw == 1) begin
				//R <= _R;//R_next; //(palette[escape][23:16]);
				//G <= _G;//G_next; //(palette[escape][15:8]);
				//B <= _B;//B_next; //(palette[escape][7:0]);
		//	end
		end
	end

	
	always_comb begin
		do_coloring = 0;
		//ack_r = 0;
		//ack_g = 0;
		//ack_b = 0;
		R_next = R_out;
		G_next = G_out;
		B_next = B_out;
		
		case (state)
			HALTED: begin
				next_state = (reset) ? HALTED : STALL;
				R_next = 8'h0;
				G_next = 8'h0;
				B_next = 8'h0;
			end
			STALL: begin
				next_state = (do_draw) ? DO_COLORING : STALL;
			end
			DO_COLORING: begin
				do_coloring = 1;
				next_state = (done_r) ? ACK : DO_COLORING; //(done_r && done_g && done_b) ? ACK : DO_COLORING;
			
				//next_state = (done_r && done_g && done_b) ? ACK : DO_COLORING; //(done_r && done_g && done_b) ? ACK : DO_COLORING;
			end
			ACK: begin
				//ack_r = 1;
				//ack_g = 1;
				//ack_b = 1;
				next_state = DONE;
				R_next = _R;
				G_next = _G;
				B_next = _B;
			end
			DONE: begin
				//R_next = _R;
				//G_next = _G;
				//B_next = _B;
				next_state = (~do_draw) ? HALTED : DONE;
			end
		endcase
	end
endmodule
*/

	/*
	logic get_escape_as_ieee;
	wire  done_escape_as_ieee;
	logic calc_escape_as_ieee;
	int_to_ieee escape_as_ieee_term(
				.clk(math_clk),
				.reset(reset),
				.a_in(escape_ieee),
				.a_in_done(calc_escape_as_ieee),
				.z_out_ack(get_escape_as_ieee),
				.z_out_done(done_escape_as_ieee),
				.z_out(escape_as_ieee)
			);
	logic [63:0] phi;
	logic get_phi;
	wire done_phi;
	logic calc_phi;
	double_multiplier phi_term (
				.clk(math_clk),
				.reset(reset),
				.a_in(`COEFF_A),
				.b_in(escape_as_ieee),
				.a_in_done(calc_phi),
				.b_in_done(calc_phi),
				.z_out(phi),
				.z_out_done(done_phi),
				.z_out_ack(get_phi)
				);
	logic [63:0] cos_out;
	logic calc_cos;
	wire calc_cos_done;
	cordic Cos (
				.clock(math_clk),
				.reset(reset),
				.start(calc_cos),
				.done(calc_cos_done),
				.angle_in(phi),
				.cos_out(cos_out)
		);	
		
	logic apply_scale_1;
	logic get_scale_1;
	wire done_scale_1;
	wire[63:0] scale_1;
	double_multiplier scale_1_term (
				.clk(math_clk),
				.reset(reset),
				.a_in(`NEG_HALF),
				.b_in(cos_out),
				.a_in_done(apply_scale_1),
				.b_in_done(apply_scale_1),
				.z_out(scale_1),
				.z_out_done(done_scale_1),
				.z_out_ack(get_scale_1)
				);
	
	logic apply_scale_2;
	logic get_scale_2;
	wire done_scale_2;
	wire[63:0] scale_2;
	
	double_adder scale_step_2_term (
					.clk(math_clk),
					.reset(reset),
					.a_in(`HALF),
					.b_in(scale_1),
					.a_in_done(apply_scale_2),
					.b_in_done(apply_scale_2),
					.z_out_ack(get_scale_2),
					.z_out_done(done_scale_2),
					.z_out(scale_2)
				);
	logic calc_rgb;
	logic get_rgb;
	wire done_rgb;
	logic[63:0] rgb;
	//wire[24:0] rgb;
	assign coloring_ieee = 64'(unsigned'(palette[escape[3:0]]));
	double_multiplier rgb_term (
				.clk(math_clk),
				.reset(reset),
				.a_in(coloring_ieee),
				.b_in(scale_2),
				.a_in_done(calc_rgb),
				.b_in_done(calc_rgb),
				.z_out(rgb),
				.z_out_done(done_rgb),
				.z_out_ack(get_rgb)
				);
	//assign rgb = 24'(unsigned'(_rgb));
	//assign R = rgb[23:16];
	//assign G = rgb[15:8];
	//assign B = rgb[7:0];
			//
	enum logic [4:0] {
		HALTED, STALL, CONVERT_escape_TO_IEEE, CALC_PHI, CALC_COS, SCALE_STEP_1, SCALE_STEP_2, SCALE_STEP_3, CONVERT_ARGS_TO_LONGS, ACK
		} state, next_state;
		
	always_ff @ (posedge reset or posedge clk or posedge done) begin: colorize//clk) begin: colorize
		if (reset) begin
			R <= (drawxsig[3] ^ drawysig[4]) ? 8'h0a:8'ha0;
			G <= (drawxsig[3] ^ drawysig[4]) ? 8'ha0:8'h0a;
			B <= (drawxsig[3] ^ drawysig[4]) ? 8'hb0:8'h0b;
		end
		else begin
			//if (do_draw) begin // && done //) begin
				R <= rgb[23:16];
				G <= rgb[15:8];
				B <= rgb[7:0];
			//end
		end
	end
	
	always_comb begin
		 done = 0;
		 next_state = state;
		 get_escape_as_ieee = 0;
		 calc_escape_as_ieee = 0;
		 get_phi = 0;
		 calc_phi = 0;
		 calc_cos = 0;
		 apply_scale_1 = 0;
		 get_scale_1 = 0;
		 apply_scale_2 = 0;
		 get_scale_2 = 0;
		 calc_rgb = 0;
		 get_rgb = 0;
		
		//get_rgb_as_long = 0;
	  // calc_rgb_as_long = 0;
		
		case (state)
			HALTED: begin
				done = 1;
				next_state = (reset) ? HALTED : STALL;
			end
			
			STALL: begin
				next_state = (do_draw == 1) ? CONVERT_escape_TO_IEEE : STALL;
			end
			
			CONVERT_escape_TO_IEEE: begin
				calc_escape_as_ieee = 1;
				next_state = (done_escape_as_ieee) ? CALC_PHI : CONVERT_escape_TO_IEEE;
			end
			
			CALC_PHI: begin
				calc_phi = 1;
				next_state = (done_phi) ? CALC_COS : CALC_PHI;
				//next_state = (done_rphi && done_gphi && done_bphi) ? CALC_COS : CALC_PHI;
			end
			
			CALC_COS: begin
				calc_cos = 1;
				next_state = (calc_cos_done) ? SCALE_STEP_1 : CALC_COS;
			end
			
			SCALE_STEP_1: begin
				apply_scale_1 = 1;
				next_state = (done_scale_1) ? SCALE_STEP_2 : SCALE_STEP_1;
			end
			SCALE_STEP_2: begin
				apply_scale_2 = 1;
				next_state = (done_scale_2) ? SCALE_STEP_3 : SCALE_STEP_2;
			end
			SCALE_STEP_3: begin
				calc_rgb = 1;
				next_state = (done_rgb) ? ACK : SCALE_STEP_3;
			end
			//CONVERT_ARGS_TO_LONGS: begin
			//	calc_rgb_as_long = 1;
			//	next_state = (done_rgb_as_long ) ? ACK : CONVERT_ARGS_TO_LONGS;
			//end
			ACK: begin
				//next_state = state;
				//calc_rcos = 0;
				//calc_bcos = 0;
				get_escape_as_ieee = 1;
				get_phi = 1;
				//get_gphi = 1;
				
				get_scale_1 = 1;
				get_scale_2 = 1;
				get_rgb = 1;
				done = 1;
				//get_rgb_as_long = 1;
				next_state = (~do_draw) ? HALTED : ACK;
			end
		endcase
	end
	
endmodule
*/