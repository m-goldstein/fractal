/* Computes the complex-valued sum of two complex-numbers. The complex quantities are interpreted as IEEE754 datatype vectors 
 * with two entries each, so the sum is taken by adding entries component-wise. 
 * ie. re_z = re_a + re_b; im_z = im_a + im_b; No sophisticated control logic needed to compute this result.
 */
 
module adder_unit(
	input clk,
	input reset,
	input start,
	input ack,
	input [63:0] re_a,
	input [63:0] im_a,
	input [63:0] re_b,
	input [63:0] im_b,
	output done,
	output wire[63:0] re_z,
	output wire[63:0] im_z
	);
	
	wire sum_real_component_done;
	wire sum_imaginary_component_done;
	assign done = (sum_real_component_done && sum_imaginary_component_done);
	
	
	// compute real-component sum.
	double_adder re_z_sum (
						.clk(clk),
						.reset(reset),
						.a_in(re_a),
						.b_in(re_b),
						.a_in_done(start),
						.b_in_done(start),
						.z_out_ack(ack),
						.z_out_done(sum_real_component_done),
						.z_out(re_z)
						);
	
	// compute imaginary-component sum.
	double_adder im_z_sum (
						.clk(clk),
						.reset(reset),
						.a_in(im_a),
						.b_in(im_b),
						.a_in_done(start),
						.b_in_done(start),
						.z_out_ack(ack),
						.z_out_done(sum_imaginary_component_done),
						.z_out(im_z)
						);
	endmodule
	