#include "stm32f3xx.h"
#include "gpio.h"
#include "clock.h"

void ClockHSEInit(void) {
	RCC -> CR |= 1<<16;
	while(!(RCC -> CR & (1<<17)));
}

void ClockHSEoff(void) {
	RCC -> CR &= ~(1<<16);
}

void ClockPLLInit(void) {
	RCC -> CR |= 1<<24;
	while(!(RCC -> CR & (1<<25)));
}

void ClockPLLoff(void) {
	RCC -> CR &= ~(1<<24);
}

void ReadClock(char clk, char div) {
	SetPinAlt(PA8, HS, AF0);
	
	RCC -> CFGR &= ~(0x7 << 24); // clear clock bits
	RCC -> CFGR |= clk << 24; // set which clock
	
	RCC -> CFGR &= ~(0x7 << 28); // clear divisor bits
	RCC -> CFGR |= div << 28; // set divisor
}

int PLL_Speed(void) {
	int speed = 0;
	int source = 0;
	int PLLMULT = 2;
	int HSEDIV = (RCC -> CFGR2 & 0xF) + 1;
	if(RCC -> CFGR & (1<<16)) {
		source = HSEClkSpeed / HSEDIV;
	} else {
		source = HSIClkSpeed / 2;
	}
	PLLMULT = (RCC -> CFGR & (0xF<<18)) + 2;
	
	speed = source * PLLMULT;
	return speed;
}

int SYSCLK_Speed(void) {
	int speed = 0;
	char SWS = (RCC -> CFGR & 0xc) >> 2;
	
	if (SWS == SWS_HSI) {
		speed = HSIClkSpeed;
	} else if(SWS == SWS_HSE) {
		speed = HSEClkSpeed;
	} else if(SWS == SWS_PLL) {
		speed = PLL_Speed();
	}
	return speed;
}

void SetPLLSpeed(char source, char mult, char HSEDIV) {
	// setting source
	if (source == HSI_SRC) {
		RCC -> CFGR &= ~(1<<16);
	} else if(source == HSE_SRC) {
		// if HSE is source, set as source and set divisor
		RCC -> CFGR |= 1<<16;
		RCC -> CFGR2 |= HSEDIV;
	}
	
	// Setting multiplier
	RCC -> CFGR |= mult << 18;
	
	ClockPLLInit();
	
}

void SetSYSCLOCKSource(char source) {
	RCC -> CFGR |= source;
}

void SetHClock(char HPRE) {
	RCC -> CFGR |= HPRE << 4;
}

void APB1Clock(char prescalar) { 
	RCC -> CFGR |= prescalar << 8;
}

void APB2Clock(char prescalar) { 
	RCC -> CFGR |= prescalar << 11;
}


		

	