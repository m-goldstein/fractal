/* computes the (squared) magnitude of a complex number using |z|^2 = (z)(z*) where z* is the complex conjugate */
`include "Magic_Numbers.sv"
`define GOTO(x)		next_state = (x)
module magnitude_unit(
					input clk,
					input reset, 
					input ack,
					input start,
					input logic[63:0] re_in,
					input logic[63:0] im_in,
					output logic done,
					output wire[63:0] mag_out
			);
	// internal register for magnitude of complex number
	logic [63:0] mag;
	
	// control signals
	logic get_mag;
	logic calc_re;
	logic calc_im;
	logic calc_sum;
	logic get_re;
	logic get_im;
	
	// logical connections (wires) to FPU module signals on datapath 
	wire [63:0] mag_out_wire;
	wire [63:0] re_wire;
	wire [63:0] im_wire;
	wire done_re;
	wire done_im;
	wire done_sum;
	
	// define a relationship between output mag_out and internal register mag.
	assign mag_out = mag;
	
	enum logic [3:0] {
		HALT,
		CALCULATE_SQUARES,
		ACK_SQUARES,
		CALCULATE_SUMS,
		ACK_SUMS
	} state, next_state;
	
	// module computes the square of the real-component of input.
	double_multiplier re_sq (
					.clk(clk),
					.reset(reset),
					.a_in(re_in),
					.b_in(re_in),
					.a_in_done(calc_re),
					.b_in_done(calc_re),
					.z_out_done(done_re),
					.z_out_ack(get_re),
					.z_out(re_wire)
					);
	
	// module computes the square of the imaginary-component of input.
	double_multiplier im_sq (
					.clk(clk),
					.reset(reset),
					.a_in(im_in),
					.b_in(im_in),
					.a_in_done(calc_im),
					.b_in_done(calc_im),
					.z_out_done(done_im),
					.z_out_ack(get_im),
					.z_out(im_wire)
					);
	
	// module computes the sum of the squared real-component and imaginary-component of input. z^2 = (re_in)^2 + (im_in)^2.
	double_adder z_mag_adder (
					.clk(clk),
					.reset(reset),
					.a_in(re_wire),
					.b_in(im_wire),
					.a_in_done(calc_sum),
					.b_in_done(calc_sum),
					.z_out_done(done_sum),
					.z_out_ack(get_mag),
					.z_out(mag_out_wire)
					);
	
	
	always_ff @ (posedge clk) begin
		state <= (reset) ? HALT : next_state;
	end
	
	always_comb begin
		next_state = state;
		
		// default control signal values
		calc_re = 0;
		calc_im = 0;
		get_re = 0;
		get_im = 0;
		get_mag = 0;
		calc_sum = 0;
		done = 0;
		
		// default register assignment
		mag = mag_out;
		
		case (state)
			HALT: begin
				mag = `ZERO;
				`GOTO ( (start) ? CALCULATE_SQUARES : HALT);				// upon start signal, begin first state transition.
			end
			
			CALCULATE_SQUARES: begin
				calc_re = 1;						// signal to fpu modules to calculate square of complex components
				calc_im = 1;						// 
				`GOTO ( (done_re && done_im) ? ACK_SQUARES : CALCULATE_SQUARES); 		// transition states when results are ready
			end
			
			ACK_SQUARES: begin
				get_re = 1;							// signal to fpu modules to acknowledge results before next state transition
				get_im = 1;							//
				`GOTO (CALCULATE_SUMS);
			end
			
			CALCULATE_SUMS: begin
				calc_sum = 1;													// signal to fpu module to calculate sum of squares of components.
				`GOTO ( (done_sum) ? ACK_SUMS : CALCULATE_SUMS); 	// transition when complete
			end
			
			ACK_SUMS: begin
				get_mag = 1;													// send acknowledgement signal
				done = 1;														// send done signal to upper-level datapath
				mag = mag_out_wire;											// assign internal mag register to output wire value
				`GOTO ( (ack) ? HALT : ACK_SUMS);						// begin next cycle on rising edge of ack signal received from upper-level datapath
			end
		endcase
	end
endmodule
