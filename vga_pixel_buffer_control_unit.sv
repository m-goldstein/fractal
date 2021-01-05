/* Control unit for pixel buffer module.
 * Generates R/W signals for RAM and control signals to indicate to fractal engine module
 * the current pixel has been mapped.
 */ 
 
`define GOTO(v)		next_state = (v)
module vga_pixel_buffer_control_unit(
	input logic clk,
	input logic reset,
	input logic Draw,
	output logic done_draw_esc,
	output logic OE_N,
	output logic WE_N
	);
	
	// states
	enum logic [1:0] {
		HALTED,
		DRAW_STEP_1,
		DRAW_STEP_2,
		STALL
	} state, next_state;
	
	always_ff @(posedge clk) begin
		state <= (reset) ? HALTED : next_state;
	end
	
	always_comb begin
		`GOTO(state);
		OE_N = Draw;
		WE_N = 0;
		done_draw_esc = 0;
		
		case (state)
			HALTED:
			begin
				done_draw_esc = 1;
				WE_N = 1;
				`GOTO((Draw) ? DRAW_STEP_1 : HALTED);
			end
			
			/* enable writing to the RAM during this clock cycle */
			DRAW_STEP_1:
			begin
				WE_N = 0;
				`GOTO(DRAW_STEP_2);
			end
			
			/* maintain write enable */
			DRAW_STEP_2:
			begin
				WE_N = 0;
				`GOTO(STALL);
			end
			
			/* disable write enable */
			STALL:
			begin
				WE_N = 1;
				`GOTO(HALTED);
			end
			
		endcase
	end
endmodule
