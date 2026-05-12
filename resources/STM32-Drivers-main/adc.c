#include "gpio.h"
#include "timer.h"
#include "clock.h"
#include "adc.h"
#include "dac.h"
#include "stm32f3xx.h"


void EnableDAC1(void) {
	RCC -> APB1ENR |= 1<<29; // enable clock for DAC 1
	SetPinAnalog(PA4); // set pin to analog function
	DAC1 -> CR |= 1; // enable dac 1
	DAC1 -> CR &= ~(1<<1); // enable output trigger
	DAC1 -> CR &= ~ (1<<2); // no trigger and update value of DAC every one APB1 clock cycle

	DAC1 -> DHR12R1 = 0; // initialize to 0
}

void DAC1Output(int value) {
	DAC1 -> DHR12R1 = value; // output voltage out of 4095
}

void EnableDAC2(void) {
	RCC -> APB1ENR |= 1<<26; // enable clock for DAC 2
	SetPinAnalog(PA6); // set pin to analog function
	DAC2 -> CR |= 1; // enable dac 2
	DAC2 -> CR |= (1<<1); // enable output
	DAC2 -> CR &= ~ (1<<2); // no trigger and update value of DAC every one APB1 clock cycle

	DAC2 -> DHR12R1 = 0; // initialize to 0
}

void DAC2Output(int value) {
	DAC2 -> DHR12R1 = value; // output voltage out of 4095
}
