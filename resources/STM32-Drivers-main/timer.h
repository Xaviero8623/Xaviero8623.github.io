#include "stm32f3xx.h"


// while any timer can be used, it is preferred for usability to rely on timers 16 or 17
void Timer_Delay_Micros(int timer, int micros);

// delay function using timer 17 in milliseconds
 void Delay(int millis);

// delay function using user specified timer in milliseconds
void Timer_Delay_Millis(int timer, int millis);

// Timer interrupt functions

// SysTick Timer
void SysTickInterrupt(int load);

// use for starting interrupt every however many micro/milli seconds
void USInterrupt(int timer, int micros);
void MSInterrupt(int timer, int millis);

// used in handler function to reset interrupt flag
void Timer_irq_flag(int timer);

// Stop functions
void Stop_Timer_Interrupt(int timer);
void Timer_Stop(int timer);

// Compare function
void Compare_Micro(int PortPin, int MaxCount, int Trigger, char Alt);
void Compare_Milli(int PortPin, int MaxCount, int Trigger, char Alt);

//PWM function
void PWM(int PortPin, int Resolution, double duty_cycle, char Alt);
