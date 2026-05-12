#include "stm32f3xx.h"
#include "timer.h"
#include "gpio.h"

//timer functions




TIM_TypeDef * get_timer(int timer) {
	TIM_TypeDef * tim;
	switch(timer) {
		case 1 : tim = TIM1;break;
		case 2 : tim = TIM2;break;
		case 3 : tim = TIM3;break;
		case 6 : tim = TIM6;break;
		case 7 : tim = TIM7;break;
		case 15 : tim = TIM15;break;
		case 16 : tim = TIM16;break;
		case 17 : tim = TIM17;break;
	}
	return tim;
}

TIM_TypeDef * UStimerInit(int timer, int micros) {
	//cpu default on start up is 8 MHz
	int prescalar = 8-1;
	TIM_TypeDef * tim;
	
	// This conditional statement is unique to STM32F334xx microcontrollers, will need to be updated for other types
	// enabling timer clock
	if(timer==1) {
		RCC -> APB2ENR |= 1<<11;
	} else if(timer > 10) {
		RCC -> APB2ENR |= 1<<(timer+1);
	} else if (timer == 2 | timer == 3 | timer == 6 | timer == 7) {
		RCC -> APB1ENR |= 1<<(timer-2);
	}
	
	tim = get_timer(timer);
	
	// initialize counter to start at 0
	tim -> CNT = 0;
	
	// Set prescale value to 8, divide clock by 8
	tim -> PSC = prescalar;
	
	// Initialize the Auto reload value
	tim -> ARR = (micros-1);
	
	// Enable the counter and One Pulse mode
	tim -> CR1 |= 1;
	
	return tim;
}
TIM_TypeDef * MStimerInit(int timer, int millis) {
	//cpu default on start up is 8 MHz, divide by 2 so it ticks twice per millisecond
	int prescalar = 4000-1;
	TIM_TypeDef * tim;
	
	// This conditional statement is unique to STM32F334xx microcontrollers, will need to be updated for other types
	// enabling timer clock
	if(timer==1) {
		RCC -> APB2ENR |= 1<<11;
	} else if(timer > 10) {
		RCC -> APB2ENR |= 1<<(timer+1);
	} else if (timer == 2 | timer == 3 | timer == 6 | timer == 7) {
		RCC -> APB1ENR |= 1<<(timer-2);
	}
	
	tim = get_timer(timer);
	
	// initialize counter to start at 0
	tim -> CNT = 0;
	
	// Set prescale value to 4000-1, divide clock by 4
	tim -> PSC = prescalar;
	
	// Initialize the Auto reload value, double the value it takes to saturate since timer counts twice per milli
	tim -> ARR = ((millis*2)-1);
	
	// Enable the counter
	tim -> CR1 |= 1;
	
	return tim;
}

// Timer Delay functions

void Delay(int millis) {
	int i=0;
	for(i=0; i<millis; ++i) {
	SysTick -> CTRL = 0;
	SysTick -> LOAD = 8000-1;
	SysTick -> VAL = 0;
	SysTick -> CTRL |= 5;
	while (!(SysTick -> CTRL & (1<<16))) 
	{}
	}	
}

void Timer_Delay_Micros(int timer, int micros) {
	TIM_TypeDef * tim = UStimerInit(timer, micros);

	tim -> CR1 |= 1<<3; // enable one pulse mode

	
	while(tim->CR1 & 1)
	{}
			
}



void Timer_Delay_Millis(int timer, int millis) {
	TIM_TypeDef * tim = MStimerInit(timer, millis);
	
	tim -> CR1 |= 1<<3; // enable one pulse mode
	
	while(tim->CR1 & 1)
	{}
}


// Timer interrupt functions


void SysTickInterrupt(int load) {
	__disable_irq();
	SysTick -> CTRL = 0;
	SysTick -> LOAD = load;
	SysTick -> VAL = 0;
	SysTick -> CTRL |= 7;
	__enable_irq();
}


void USInterrupt(int timer, int micros) {
	TIM_TypeDef * tim = UStimerInit(timer, micros);
	tim -> DIER |=1;
	
	__disable_irq();
	
	switch(timer) {
		case 1 : NVIC_EnableIRQ(TIM1_UP_TIM16_IRQn);break;
		case 2 : NVIC_EnableIRQ(TIM2_IRQn);break;
		case 3 : NVIC_EnableIRQ(TIM3_IRQn);break;
		case 6 : NVIC_EnableIRQ(TIM6_DAC1_IRQn);break;
		case 7 : NVIC_EnableIRQ(TIM7_DAC2_IRQn);break;
		case 15 : NVIC_EnableIRQ(TIM1_BRK_TIM15_IRQn);break;
		case 16 : NVIC_EnableIRQ(TIM1_UP_TIM16_IRQn);break;
		case 17 : NVIC_EnableIRQ(TIM1_TRG_COM_TIM17_IRQn);break;
	}
	
	__enable_irq();
}

void MSInterrupt(int timer, int millis) {
	TIM_TypeDef * tim = MStimerInit(timer, millis);
	tim -> DIER |=1;
	
	__disable_irq();
	
	switch(timer) {
		case 1 : NVIC_EnableIRQ(TIM1_UP_TIM16_IRQn);break;
		case 2 : NVIC_EnableIRQ(TIM2_IRQn);break;
		case 3 : NVIC_EnableIRQ(TIM3_IRQn);break;
		case 6 : NVIC_EnableIRQ(TIM6_DAC1_IRQn);break;
		case 7 : NVIC_EnableIRQ(TIM7_DAC2_IRQn);break;
		case 15 : NVIC_EnableIRQ(TIM1_BRK_TIM15_IRQn);break;
		case 16 : NVIC_EnableIRQ(TIM1_UP_TIM16_IRQn);break;
		case 17 : NVIC_EnableIRQ(TIM1_TRG_COM_TIM17_IRQn);break;
	}
	
	__enable_irq();
}

void Timer_irq_flag(int timer) {
	TIM_TypeDef * tim = get_timer(timer);
	tim -> SR &= 0xFFFE;
	
}

// Timer interrupt Handeler Functions

/*

void SysTick_Handler(void) {
	//do something
}

void TIM1_UP_TIM16_IRQHandler() {
	Timer_irq_flag(1);
	//do something
}

void TIM2_IRQHandler() {
	Timer_irq_flag(2);
	//do something
}

void TIM3_IRQHandler() {
	Timer_irq_flag(3);
	//do something
}

void TIM6_DAC1_IRQHandler() {
	Timer_irq_flag(6);
	//do something
}

void TIM7_DAC2_IRQHandler() {
	Timer_irq_flag(7);
	//do something
}

void TIM1_BRK_TIM15_IRQHandler() {
	Timer_irq_flag(15);
	//do something
}

void TIM1_UP_TIM16_IRQHandler() {
	Timer_irq_flag(16);
	//do something
}

void TIM1_TRG_COM_TIM17_IRQHandler() {
	Timer_irq_flag(17);
	//do something
}

*/


// Timer interrupt stop function
void Stop_Timer_Interrupt(int timer) {
	TIM_TypeDef * tim = get_timer(timer);
	tim -> DIER &= 0xFFFE;
	
	__disable_irq();
	
	switch(timer) {
		case 1 : NVIC_DisableIRQ(TIM1_UP_TIM16_IRQn);break;
		case 2 : NVIC_DisableIRQ(TIM2_IRQn);break;
		case 3 : NVIC_DisableIRQ(TIM3_IRQn);break;
		case 6 : NVIC_DisableIRQ(TIM6_DAC1_IRQn);break;
		case 7 : NVIC_DisableIRQ(TIM7_DAC2_IRQn);break;
		case 15 : NVIC_DisableIRQ(TIM1_BRK_TIM15_IRQn);break;
		case 16 : NVIC_DisableIRQ(TIM1_UP_TIM16_IRQn);break;
		case 17 : NVIC_DisableIRQ(TIM1_TRG_COM_TIM17_IRQn);break;
	}
	
	__enable_irq();
}

void Timer_Stop(int timer) {
	TIM_TypeDef * tim = get_timer(timer);
	
	tim -> CR1 = 0;
	
	if(timer==1) {
		RCC -> APB2ENR &= ~(1<<11);
	} else if(timer > 10) {
		RCC -> APB2ENR &= ~(1<<(timer+1));
	} else if (timer == 2 | timer == 3 | timer == 6 | timer == 7) {
		RCC -> APB1ENR &= ~(1<<(timer-2));
	}
	
	Stop_Timer_Interrupt(timer);
	
}

// Compare Functions
int get_channel(int PortPin) {
	int port = PortPin / 16; // port
	int pin = PortPin % 16; // pin number
	
	if(port == 0) {
		switch(pin) {
			case 0 : return 1;
			case 1 : return 2;
			case 2 : return 3;
			case 3 : return 4;
			case 4 : return 2;
			case 5 : return 1;
			case 6 : return 1;
			case 7 : return 1; // channel for timer 17(AF1)
			case 12: return 1;
			case 15: return 1;
		}
		return 0;
	} else if(port == 1) {
		switch(pin) {
			case 0 : return 3;
			case 1 : return 4;
			case 3 : return 2;
			case 4 : return 1;
			case 5 : return 2;
			case 8 : return 1;
			case 9 : return 1;
			case 10: return 3;
			case 11: return 4;
			case 14: return 1;
			case 15: return 2;
		}
		return 0;
	} else if(port == 2) {
		switch(pin) {
			case 0 : return 1;
			case 2 : return 3;
			case 3 : return 4;
			case 6 : return 1;
			case 7 : return 2;
			case 8 : return 3;
			case 9 : return 4;
		}
		return 0;
	}
	return 0;

}

int get_timer_pin(int PortPin) {
	int port = PortPin / 16; // port
	int pin = PortPin % 16; // pin number
	if(port == 0) {
		switch(pin) {
			case 0 : return 2;
			case 1 : return 2;
			case 2 : return 2;
			case 3 : return 2;
			case 4 : return 3;
			case 5 : return 2;
			case 6 : return 16;
			case 7 : return 17; // channel for timer 17(AF1)
			case 12: return 16;
			case 15: return 2;
		}
		return 0;
	} else if(port == 1) {
		switch(pin) {
			case 0 : return 3;
			case 1 : return 3;
			case 3 : return 2;
			case 4 : return 16;
			case 5 : return 3;
			case 8 : return 16;
			case 9 : return 17;
			case 10: return 2;
			case 11: return 2;
			case 14: return 15;
			case 15: return 15;
		}
		return 0;
	} else if(port == 2) {
		switch(pin) {
			case 0 : return 1;
			case 2 : return 1;
			case 3 : return 1;
			case 6 : return 3;
			case 7 : return 3;
			case 8 : return 3;
			case 9 : return 3;
		}
		return 0;
	}
	return 0;
}

TIM_TypeDef * get_timer_addy(int PortPin) {
	int port = PortPin / 16; // port
	int pin = PortPin % 16; // pin number
	if(port == 0) {
		switch(pin) {
			case 0 : return TIM2;
			case 1 : return TIM2;
			case 2 : return TIM2;
			case 3 : return TIM2;
			case 4 : return TIM3;
			case 5 : return TIM2;
			case 6 : return TIM16;
			case 7 : return TIM17; // channel for timer 17(AF1)
			case 12: return TIM16;
			case 15: return TIM2;
		}
		return 0;
	} else if(port == 1) {
		switch(pin) {
			case 0 : return TIM3;
			case 1 : return TIM3;
			case 3 : return TIM2;
			case 4 : return TIM16;
			case 5 : return TIM3;
			case 8 : return TIM16;
			case 9 : return TIM17;
			case 10: return TIM2;
			case 11: return TIM2;
			case 14: return TIM15;
			case 15: return TIM15;
		}
		return 0;
	} else if(port == 2) {
		switch(pin) {
			case 0 : return TIM1;
			case 2 : return TIM1;
			case 3 : return TIM1;
			case 6 : return TIM3;
			case 7 : return TIM3;
			case 8 : return TIM3;
			case 9 : return TIM3;
		}
		return 0;
	}
	return 0;
}
			
			
void Compare_Micro(int PortPin, int MaxCount, int Trigger, char Alt) {
	TIM_TypeDef * tim = get_timer_addy(PortPin);
	int timer = get_timer_pin(PortPin);
	int channel = get_channel(PortPin);
	
	if ((tim -> CCER & (1<< ((channel-1) *4))) == 0) {
		if(timer==1) {
			RCC -> APB2ENR |= 1<<11;
		} else if(timer > 10) {
			RCC -> APB2ENR |= 1<<(timer+1);
		} else if (timer == 2 | timer == 3 | timer == 6 | timer == 7) {
			RCC -> APB1ENR |= 1<<(timer-2);
		}
		SetPinAlt(PortPin, HS, Alt);
		tim -> PSC = (8-1); // cpu speed is 8 MHz
		switch(channel) {
			case 1: tim -> CCMR1 |= 0x30;break;
			case 2: tim -> CCMR1 |= 0x3000;break;
			case 3: tim -> CCMR2 |= 0x30;break;
			case 4: tim -> CCMR2 |= 0x3000;break;
		}
		tim -> CCER |= (1<< ((channel-1) *4));
		tim -> BDTR |= 0x8;
		tim -> CR1 |= 1;
	}
	tim -> ARR = MaxCount-1;
	switch(channel) {
		case 1: tim -> CCR1 = Trigger;break;
		case 2: tim -> CCR2 = Trigger;break;
		case 3: tim -> CCR3 = Trigger;break;
		case 4: tim -> CCR4 = Trigger;break;
	}
}

void Compare_Milli(int PortPin, int MaxCount, int Trigger, char Alt) {
	TIM_TypeDef * tim = get_timer_addy(PortPin);
	int timer = get_timer_pin(PortPin);
	int channel = get_channel(PortPin);
	
	if ((tim -> CCER & (1<< ((channel-1) *4))) == 0) {
		if(timer==1) {
			RCC -> APB2ENR |= 1<<11;
		} else if(timer > 10) {
			RCC -> APB2ENR |= 1<<(timer+1);
		} else if (timer == 2 | timer == 3 | timer == 6 | timer == 7) {
			RCC -> APB1ENR |= 1<<(timer-2);
		}
		SetPinAlt(PortPin, HS, Alt);
		tim -> PSC = (4000-1); // cpu speed is 8 MHz
		switch(channel) {
			case 1: tim -> CCMR1 |= 0x30;break;
			case 2: tim -> CCMR1 |= 0x3000;break;
			case 3: tim -> CCMR2 |= 0x30;break;
			case 4: tim -> CCMR2 |= 0x3000;break;
		}
		tim -> CCER |= (1<< ((channel-1) *4));
		tim -> BDTR |= 0x8;
		tim -> CR1 |= 1;
	}
	Trigger *= 2; //multiply compare by 2
	tim -> ARR = (MaxCount*2)-1;
	switch(channel) {
		case 1: tim -> CCR1 = Trigger;break;
		case 2: tim -> CCR2 = Trigger;break;
		case 3: tim -> CCR3 = Trigger;break;
		case 4: tim -> CCR4 = Trigger;break;
	}
}

// PWM Mode
void PWM(int PortPin, int Resolution, double duty_cycle, char Alt) {
	
	int compare = duty_cycle * Resolution;
	TIM_TypeDef * tim = get_timer_addy(PortPin);
	int timer = get_timer_pin(PortPin);
	int channel = get_channel(PortPin);
	
	if ((tim -> CCER & (1<< ((channel-1) *4))) == 0) {
		if(timer==1) {
			RCC -> APB2ENR |= 1<<11;
		} else if(timer > 10) {
			RCC -> APB2ENR |= 1<<(timer+1);
		} else if (timer == 2 | timer == 3 | timer == 6 | timer == 7) {
			RCC -> APB1ENR |= 1<<(timer-2);
		}
		SetPinAlt(PortPin, HS, Alt);
		tim -> PSC = (8-1); // cpu speed is 8 MHz
		switch(channel) {
			case 1: tim -> CCMR1 |= 0x60;break;
			case 2: tim -> CCMR1 |= 0x6000;break;
			case 3: tim -> CCMR2 |= 0x60;break;
			case 4: tim -> CCMR2 |= 0x6000;break;
		}
		tim -> CCER |= (1<< ((channel-1) *4));
		tim -> BDTR |= 0x8;
		tim -> CR1 |= 1;
	}
	tim -> ARR = Resolution-1;
	switch(channel) {
		case 1: tim -> CCR1 = compare;break;
		case 2: tim -> CCR2 = compare;break;
		case 3: tim -> CCR3 = compare;break;
		case 4: tim -> CCR4 = compare;break;
	}
}
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
