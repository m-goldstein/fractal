/* This module implements the magnification register. With keycodes from the NIOS-II, the scaling factor either increases or decreases
 * by some factor proportional to the current level using floating point multiplications.
 */
 
`include "Magic_Numbers.sv"
`define GOTO(x)			next_state = (x)
module Magnifier_Reg (
	input clk,
	input math_clk,
	input reset,
	input Increase_Magnification,
	input Decrease_Magnification,
	output logic [63:0] Magnification,
	output logic ack
	);
	
	// internal registers
	logic[63:0] signextmag;
	logic[63:0] scaling;
	logic[63:0] next_scaling;
	
	// logical connection to magnifier0 module
	wire [63:0] signewmag;
	//wire [63:0] sigtrash; // don't care
	
	// control signals
	logic calc_magnification;
	logic calc_magnification_done;
	logic get_new_magnification;
	
	
	/* calculate scaling factor based on current magnification level */
	multiplier_unit magnifier0 (
				.clk(math_clk),
				.reset(reset),
				.start(calc_magnification),
				.ack(get_new_magnification),
				.re_a(Magnification),
				.im_a(`ZERO),
				.re_b(scaling),
				.im_b(`ZERO),
				.done(calc_magnification_done),
				.re_z(signewmag)
				//.im_z(sigtrash) // commented out to save the effort from the fitter
	);
	
	
	enum logic [2:0] {
		HALT,
		CALC_MAGNIFICATION_STEP,
		UPDATE_MAGNIFICATION,
		SEND_ACK,
		DONE
	} state, next_state;
	
	always_ff @ (posedge clk) begin
		state	<= (reset) ? HALT : next_state;
		scaling <= next_scaling;
		Magnification <= signextmag;
	end
	
	always_comb begin
		next_state = state;
		
		// default register assignments
		signextmag = Magnification;
		next_scaling = scaling;
		
		// default control signal values
		calc_magnification = 0;
		get_new_magnification = 0;
		ack = 0;
		
		case(state)
			HALT: begin
				if (reset) begin
					signextmag   = `IDENTITY;
					next_scaling = `INC_STEP;
					`GOTO(HALT);
				end else begin
					case (({Increase_Magnification, Decrease_Magnification}))
						2'b00: begin
								next_scaling = `IDENTITY;						// = 1.00000
								`GOTO(HALT);
							end
						2'b01: begin												// demagnify, so scaling coefficient becomes larger
								next_scaling = `INC_STEP;
								`GOTO(CALC_MAGNIFICATION_STEP);
							end
						2'b10: begin
								next_scaling = `DEC_STEP;							// magnify, so scaling coefficient becomes smaller
								`GOTO(CALC_MAGNIFICATION_STEP);
							end
						default: begin
								next_scaling = `IDENTITY;						// = 1.0000000
								`GOTO(HALT);
							end
					endcase
				end
			end
				
			CALC_MAGNIFICATION_STEP: begin
				calc_magnification = 1;						// signal to magnifier0 to perform a computation
				`GOTO( (calc_magnification_done) ? UPDATE_MAGNIFICATION : CALC_MAGNIFICATION_STEP);
			end
			
			UPDATE_MAGNIFICATION: begin
				signextmag = signewmag;						// set register to output value from magnifier0
				`GOTO(SEND_ACK);
			end
			
			SEND_ACK: begin
				get_new_magnification = 1;					// send acknowledgement sig to magnifier0 
				`GOTO(DONE);
			end
			
			DONE: begin
				ack = 1;																			// send ack signal to higher level design entities
				`GOTO( (~(Increase_Magnification || Decrease_Magnification)) ? HALT : DONE);
			end
		endcase
	end
	
endmodule

			