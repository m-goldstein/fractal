`ifndef MAGIC_NUMBERS
	`define MAGIC_NUMBERS
	`define ZERO					64'h0000000000000000
	`define NEG_BITMASK 			64'h8000000000000000
	`define ROUND_BITMASK		53'h1fffffffffffff // bitmask for the mantissa when rounding a float 
	`define ULIM_ESCAPE 			64'd128						// this seems to be the standard choice in mandelbrot implementations 
	`define ULIM_MOD	 			64'h4010000000000000		// upperbound on squared magnitude is 1'd4; this is also standard
	`define DEFAULT_SPEED 		1'hA					// 10
	`define MIN_SPEED		 		1'h1					// 1
	`define MAX_SPEED		 		2'h14				// 20
	`define NEG_IDENT				64'hBFF0000000000000	// = -1

	/* 320 x 240 */
	//`define SCALE_X				64'h3F8999999999999A // = 1/80  (1/(160/2))
	//`define SCALE_Y				64'h3F91111110F3BF11 // = 1/60  (1/(120/2))
	//`define SCREEN_X				64'd320
	//`define SCREEN_Y				64'd240
	/* */
	/* 640 x 480 */
	`define SCALE_X				64'h3F7999999999999A	// = 1/160 (1/(320/2))
	`define SCALE_Y				64'h3F711111109BC912 // = 1/240 (1/(480/2))
	`define NEG_SCALE_Y			64'hBF711111109BC912
	`define SCREEN_X				64'd640
	`define SCREEN_Y				64'd480
	`define SCREEN_X_DIV			(((`SCREEN_X) >> 1))
	`define SCREEN_Y_DIV			(((`SCREEN_Y) >> 1))
	`define NEG_SCREEN_X_DIV 	(-1*((`SCREEN_X) >> 1))
	`define NEG_SCREEN_Y_DIV 	(-1*((`SCREEN_Y) >> 1))
	`define IDENTITY 				64'h3FF0000000000000 // = 1 in IEEE754 format
	`define INC_STEP 				64'h3FF0CCCCCCCCCCCD // = 1.05 in IEEE754 format
	`define DEC_STEP 				64'h3FEE79E79E79C61C // = 0.9523 in IEEE754 format
	
	`define KEY_UP 				16'h1A // 'W'
	`define KEY_DOWN 				16'h16 // 'S'
	`define KEY_LEFT				16'h4	 // 'A'
	`define KEY_RIGHT				16'h7  // 'D'
	`define KEY_ZOOM_IN			16'h14 // 'Q'
	`define KEY_ZOOM_OUT			16'h8  // 'E'
	`define KEY_INC_SPEED 		16'h1e // '1'
	`define KEY_DEC_SPEED 		16'h1f // '2'
	
	`define RE_C_DEFAULT			64'hBFE947AE147AE148 // -.79
	`define IM_C_DEFAULT			64'hBFC3333333333333 // .15
	
	`define RE_C_RIPPLE			64'hBFC4BC6A7EF9DB23 // -.162
	`define IM_C_RIPPLE			64'h3FBA9FBE76C8B439 // .104
	//`define COEFF_A				32'h40549A78
	//`define COEFF_B				32'h3F4871C5
	//`define COEFF_C				32'h3ED3CC4E
	`define COEFF_A				32'h3D6D7AF3
	`define COEFF_B				32'h3C5FE607
	`define COEFF_C				32'h3BEC94A9
	`define NEG_HALF				32'hBF000000
	`define HALF					32'h3F000000
	`define RGB_MAX				32'h437F0000
	//`define COEFF_A				64'h400A934F0979BAA5
	//`define COEFF_B				64'h3FE90E3892DFBE5C
	//`define COEFF_C				64'h3FDA7989C36B57C5
	//`define NEG_HALF				64'hBFE0000000000000
	//`define HALF					64'h3FE0000000000000
	//`define RGB_MAX				64'h406FE00000000000
`endif
