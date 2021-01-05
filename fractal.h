/*
 * fractal.h
 *
 *  Created on: Nov 30, 2020
 *      Author: Max Goldstein
 *
 *
 * KEYCODES:
 * 	W - move up
 * 	A - move left
 * 	S - move down
 * 	D - move right
 * 	Q - Magnify
 * 	E - De-magnify
 * 	Z - Send magnification factor to hardware
 * 	X - Send an X coordinate to hardware
 * 	Y - Send a Y coordinate to hardware
 */

#ifndef FRACTAL_H_
#define FRACTAL_H_
#define BITMASK	  0x00000000ffffffff
#define MAG_PIO_0 0x0260  // lower 32-bits
#define MAG_PIO_1 0x0250 // upper 32-bits

#define CUR_X_PIO_0 0x0240  // lower 32-bits
#define CUR_X_PIO_1 0x0230 // upper 32-bits

#define CUR_Y_PIO_0 0x0220  // lower 32-bits
#define CUR_Y_PIO_1 0x0210 // upper 32-bits

#define SIGNEWX_PIO 0x0200 // signewx
#define SIGNEWY_PIO 0x01f0 // signewy
#define SIGNEWMAG_PIO 0x01e0 // signewmag
typedef volatile unsigned int PIO_t;
typedef long double ieee754_t;
typedef long long int uint64_t;
struct fractal_regs {
	PIO_t* curx[2];
	PIO_t* cury[2];
	PIO_t* zoom[2];
	PIO_t* signewx;
	PIO_t* signewy;
	PIO_t* signewzoom;
};
enum params {
	CURX,
	CURY,
	ZOOM
};
typedef struct fractal_regs fractal_regs_t;
void init_fractal_regs();
void set_param(int paramcode);
void set_magnification(ieee754_t _mag);
ieee754_t get_magnification();

void set_curX(ieee754_t _curX);
ieee754_t get_curX();

void set_curY(ieee754_t _curY);
ieee754_t get_curY();


#endif /* FRACTAL_H_ */
