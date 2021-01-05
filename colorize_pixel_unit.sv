/* This module assigns a RGB value to a pixel based on its escape value, and the corresponding index in a LUT.
 * The RAM limits the amount of data used to index into the LUT to 4 bits so only 2^4 colors available. I tried different
 * ways to get around this constraint but it made the critical path too long and the calculations could not be done on time so
 * as to cooperate with VGA.
 */
 
`include "Magic_Numbers.sv"
module colorize_pixel_unit (
    input logic clk,
	 input logic vga_clk,
	 input logic reset,
    input logic [7:0] escape_value,
	 input logic start,
	 input logic[9:0] drawxsig, drawysig,
    output logic [7:0] R,
    output logic [7:0] G,
    output logic [7:0] B
	 
);
	
	logic _start;
	assign _start = start;
	
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
			if (_start == 1) begin
				if (escape_value[2])
					R <= ~(palette[escape_value][23:16]);
				else
					R <= (palette[escape_value][23:16]);
				
				if (escape_value[1])
					G <= ~(palette[escape_value][15:8]);
				else
					G <= (palette[escape_value][15:8]);
				
				if (escape_value[0])
					B <= ~(palette[escape_value][7:0]);
				else
					B <= (palette[escape_value][7:0]);
			end
		end
	end
endmodule
