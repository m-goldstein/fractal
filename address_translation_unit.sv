/* computes offset into RAM used to implement frame buffer by using current draw coordinate of VGA beam */
`include "Magic_Numbers.sv"
module address_translation_unit (
						input logic [9:0] curX,
						input logic [8:0] curY,
						output logic[18:0] address
	);
	// This is the same as (curY * 640 + curX) since (1 << 9) + (1 << 7) = 640.
	// Packing the bits like this is more efficient in hardware.
	wire[18:0] _addr = ({1'b0, curY, 9'b0} + {1'b0, curY, 7'b0} + {1'b0, curX});
	always @(*) begin
		address = _addr;
	end
endmodule
