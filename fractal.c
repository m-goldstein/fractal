/*
 * fractal.c
 *
 *  Created on: Nov 30, 2020
 *      Author: Max Goldstein
 */
#ifndef FRACTAL_C_
#define FRACTAL_C_
#include "fractal.h"
static fractal_regs_t regs;
void init_fractal_regs()
{
	regs.curx[0] = (PIO_t*)CUR_X_PIO_0;
	regs.curx[1] = (PIO_t*)CUR_X_PIO_1;
	regs.cury[0] = (PIO_t*)CUR_Y_PIO_0;
	regs.cury[1] = (PIO_t*)CUR_Y_PIO_1;
	regs.zoom[0] = (PIO_t*)MAG_PIO_0;
	regs.zoom[1] = (PIO_t*)MAG_PIO_1;
	regs.signewx = (PIO_t*)SIGNEWX_PIO;
	regs.signewx = (PIO_t*)SIGNEWY_PIO;
	regs.signewzoom = (PIO_t*)SIGNEWMAG_PIO;
	printf("Fractal Registers initialized!\n");
}
void set_magnification(ieee754_t _mag)
{
	uint64_t bits = (union {ieee754_t ieee; uint64_t asInt;}){_mag}.asInt;
	*(regs.zoom[0]) = bits & BITMASK;
	*(regs.zoom[1]) = bits & ~BITMASK;
	*(regs.signewzoom) = 1;
}

void set_curX(ieee754_t _curX)
{
	uint64_t bits = (union {ieee754_t ieee; uint64_t asInt;}){_curX}.asInt;
	*(regs.curx[0]) = bits & BITMASK;
	*(regs.curx[1]) = bits & ~BITMASK;
	*(regs.signewx) = 1;
}


void set_curY(ieee754_t _curY)
{
	uint64_t bits = (union {ieee754_t ieee; uint64_t asInt;}){_curY}.asInt;
	*(regs.cury[0]) = bits & BITMASK;
	*(regs.cury[1]) = bits & ~BITMASK;
	*(regs.signewy) = 1;
}

void set_param(int paramcode)
{
	unsigned char input[33];
	unsigned char *charp;
	ieee754_t arg;
	printf("Value to send to hardware: ");
	scanf("%s", input);
	arg = strtod(input, &charp);
	switch (paramcode) {
	case CURX:
		set_curX(arg);
		break;
	case CURY:
		set_curY(arg);
		break;
	case ZOOM:
		set_magnification(arg);
		break;
	default:
		break;
	}
}

ieee754_t get_curX()
{
	ieee754_t result;
	result = ((*(regs.curx[1])) << 32) | (*(regs.curx[0]));
	//printf("Result: %LG\n", result);
	return result;
}

ieee754_t get_curY()
{
	ieee754_t result;
	result = ((*(regs.cury[1])) << 32) | (*(regs.cury[0]));
	//printf("Result: %LG\n", result);
	return result;
}

ieee754_t get_magnification()
{
	ieee754_t result;
	result = ((*(regs.zoom[1])) << 32) | (*(regs.zoom[0]));
	//printf("Result: %LG\n", result);
	return result;
}
#endif


