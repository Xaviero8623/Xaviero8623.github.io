

#include "stm32f3xx.h"
#include "gpio.h"

//GPIO functions

void RCCPortInit(char GPIO_port) {
	// note we add 17 because the IO bits start at 17, this is specific to the stm32f334xx
	RCC->AHBENR |= (1<<(GPIO_port+17));
}

GPIO_TypeDef * get_GPIO(char GPIO_port) {
	GPIO_TypeDef * target_port;
	// Get GPIO address
	switch(GPIO_port)
	{
		#ifdef GPIOA
		case PortA: target_port = GPIOA;break;
		#endif
		#ifdef GPIOB
		case PortB: target_port = GPIOB;break;
		#endif
		#ifdef GPIOC
		case PortC: target_port = GPIOC;break;
		#endif
		#ifdef GPIOD
		case PortD: target_port = GPIOD;break;
		#endif
		#ifdef GPIOE
		case PortE: target_port = GPIOE;break;
		#endif
		#ifdef GPIOF
		case PortF: target_port = GPIOF;break;
		#endif
		#ifdef GPIOG
		case PortG: target_port = GPIOG;break;
		#endif
		#ifdef GPIOH
		case PortH: target_port = GPIOH;break;
		#endif
		#ifdef GPIOI
		case PortI: target_port = GPIOI;break;
		#endif
		#ifdef GPIOJ
		case PortJ: target_port = GPIOJ;break;
		#endif
		#ifdef GPIOK
		case PORTK: target_port = GPIOK;break;
		#endif
		
	}
	return target_port;
}
	
void PinMode(int PortPin, char mode) {
	char port = PortPin / 16;
	char pin = PortPin % 16;
	
	GPIO_TypeDef * GPIO = get_GPIO(port);
	
	
	
	GPIO -> MODER &= ~(0x3 << pin*2); // clear pin mode bits
	GPIO -> MODER |= (mode << pin*2); // enter pin mode bits
	
}

void SetModeOutput(int PortPin) {
	PinMode(PortPin, OUT); // set out
}

void SetModeInput(int PortPin) {
	PinMode(PortPin, IN); // set in
}

void SetModeAlt(int PortPin) {
	PinMode(PortPin, AF); // set alternate function
}

void SetModeAnalog(int PortPin) {
	PinMode(PortPin, AN); // set analog mode
}

void SetPinOutput(int PortPin, char speed) {
	char port = PortPin / 16; // port
	char pin = PortPin % 16; // pin number
	GPIO_TypeDef * GPIO = get_GPIO(port); // extract port address
	RCCPortInit(port); // initialize port clock
	SetModeOutput(PortPin); // set pin as an  output
	GPIO -> OTYPER &= ~(0b1<<pin); // set pin as push pull
	
	GPIO -> OSPEEDR &= ~(0x3<<pin*2); //resetting speed bits
	GPIO -> OSPEEDR |= (speed<<pin*2); // set pin as high speed
}

void SetPinInput(int PortPin, char speed, char pullres) {
	char port = PortPin / 16; // port
	char pin = PortPin % 16; // pin number
	GPIO_TypeDef * GPIO = get_GPIO(port); // extract port address
	RCCPortInit(port); // initialize the port
	SetModeInput(PortPin); // set pin as input
	
	GPIO -> OTYPER &= ~(0b1<<pin); // set pin as push pull
	
	GPIO -> OSPEEDR &= ~(0x3<<pin*2); //resetting speed bits
	GPIO -> OSPEEDR |= (speed<<pin*2); // set pin as high speed
	
	GPIO -> PUPDR &= ~(0x3<<pin*2); //resetting bits
	GPIO -> PUPDR |= (pullres<<pin*2); // set as pullup, pulldown, or neither
}

void SetPinAlt(int PortPin, char speed, char AlternateMapping) {
	char port = PortPin / 16; // port
	char pin = PortPin % 16; // pin number
	GPIO_TypeDef * GPIO = get_GPIO(port); // extract port address
	RCCPortInit(port); // initialize port clock
	SetModeAlt(PortPin); // set pin as an alternative function
	GPIO -> OTYPER &= ~(0b1<<pin); // set pin as push pull
	
	GPIO -> OSPEEDR &= ~(0x3<<pin*2); //resetting speed bits
	GPIO -> OSPEEDR |= (speed<<pin*2); // set pin as high speed
	
	if (pin < 8) {
		GPIO -> AFR[0] |= AlternateMapping << pin * 4; // map alternative function
	} else {
		GPIO -> AFR[1] |= AlternateMapping << (pin - 8) * 4; // map alternative function
	}
}
void SetPinAnalog(int PortPin) {
	char port = PortPin / 16; // port
	//char pin = PortPin % 16; // pin number
	//GPIO_TypeDef * GPIO = get_GPIO(port); // extract port address
	RCCPortInit(port); // initialize port clock
	SetModeAnalog(PortPin); // set pin as an  output
}


void PinWrite(int PortPin, char state) {
	char port = PortPin / 16; // port
	char pin = PortPin % 16; // pin number
	GPIO_TypeDef * GPIO = get_GPIO(port); // extract port address
	if (state) {
		GPIO -> BSRR = (1<<pin); // use BSRR register to write to ODR
	} else {
		GPIO -> BSRR = (1<<(pin+16)); // ^^^^
	}
}

char PinRead(int PortPin) {
	char port = PortPin / 16; // port
	char pin = PortPin % 16; // pin number
	GPIO_TypeDef * GPIO = get_GPIO(port); // extract port address
	
	if(GPIO->IDR & (1<<pin)) {
		return 0xFF;
	} else {
		return 0;
	}
}

void PinToggle(int PortPin) {	
	PinRead(PortPin) ? PinWrite(PortPin, OFF) : PinWrite(PortPin, ON); // toggle pin based on current state
}

// Interrupt Initialize functions

void IRQInit(int PortPin, char pullconfig) {
	char port = PortPin / 16; // port
	char pin = PortPin % 16; // pin number
	int exti = pin / 4;
	char extiPin = pin % 4;
	
	RCC -> APB2ENR |= 1; //Enable clock for IRQ	
	SetPinInput(PortPin, HS, pullconfig); // set pin input
	
	SYSCFG -> EXTICR[exti] &= ~(0xF<<extiPin*4); //clearing 
	SYSCFG -> EXTICR[exti] |= (port<<extiPin*4); //setting PortPin as external interrupt
	
	//enable NVIC
	__disable_irq();
	// conditional to choose proper statement
	if(pin==0) {
		NVIC_EnableIRQ(EXTI0_IRQn);
	} else if(pin==1) {
		NVIC_EnableIRQ(EXTI1_IRQn);
	} else if(pin==2) {
		NVIC_EnableIRQ(EXTI2_TSC_IRQn);
	} else if(pin==3) {
		NVIC_EnableIRQ(EXTI3_IRQn);
	} else if(pin==4) {
		NVIC_EnableIRQ(EXTI4_IRQn);
	} else if(pin<10) {
		NVIC_EnableIRQ(EXTI9_5_IRQn); // using an if statement is less typing than a case cause we type out 5-15
	} else {
		NVIC_EnableIRQ(EXTI15_10_IRQn);
	}
	__enable_irq();
	
	EXTI -> IMR |= 1<<pin; // turn on mask for interrupt
}

void IRQEdgeInit(int PortPin, char Edge, char pullconfig) {
	IRQInit(PortPin, pullconfig);
	char pin = PortPin % 16;
	
	if(Edge) {
		EXTI -> RTSR |= 1<<pin; // enable rising trigger
	} else {
		EXTI -> FTSR |= 1<<pin; // enable falling trigger
	}
}

void SetRisingIRQ(int PortPin, char pullconfig) {
	IRQEdgeInit(PortPin, Rising, pullconfig); 
}

void SetFallingIRQ(int PortPin, char pullconfig) {
	IRQEdgeInit(PortPin, Falling, pullconfig);
}

void SetRisingandFallingIRQ(int PortPin, char pullconfig) {
	SetRisingIRQ(PortPin, pullconfig);
	SetFallingIRQ(PortPin, pullconfig);
}


/* External Interupt Handler Functions, copy and paste as needed 

for pin 0:
void EXTI0_IRQHandler() {
	EXTI -> PR |= 1;
	stuff that occurs in interrupt goes here
}
for pin 1:
void EXTI1_IRQHandler() {
	EXTI -> PR |= 1<<1;
	stuff that occurs in interrupt goes here
}

for pin 2:
void EXTI2_TSC_IRQHandler() {
	EXTI -> PR |= 1<<2;
	stuff that occurs in interrupt goes here
}

for pin 3:
void EXTI3_IRQHandler() {
	EXTI -> PR |= 1<<3;
	stuff that occurs in interrupt goes here
}

for pin 4:
void EXTI4_IRQHandler() {
	EXTI -> PR |= 1<<4;
	stuff that occurs in interrupt goes here
}

for pins 5-9 (to differentiate between pins 5 through 9, use the pending register to check first which flag was called):
void EXTI9_5_IRQHandler() {
	EXTI -> PR |= 1<<(put pin number here);
	stuff that occurs in interrupt goes here
}

for pins 10+ ((to differentiate between pins 10 through 15, use the pending register to check first which flag was called) :
void EXTI15_10_IRQHandler() {
	EXTI -> PR |= 1<<(put pin number here);
	stuff that occurs in interrupt goes here
}

*/


// Interrupt stop funcs
void IRQEdgeStop(int PortPin, char Edge) {
	char pin = PortPin % 16;
	
	if(Edge) {
		EXTI -> RTSR &= ~(1<<pin); // disable rising trigger
	} else {
		EXTI -> FTSR &= ~(1<<pin); // disable falling trigger
	}
}

void StopRisingIRQ(int PortPin) {
	IRQEdgeStop(PortPin, Rising);
}

void StopFallingIRQ(int PortPin) {
	IRQEdgeStop(PortPin, Falling);
}

void StopRisingandFallingIRQ(int PortPin) {
	StopRisingIRQ(PortPin);
	StopFallingIRQ(PortPin);
}

void StopIRQ(int PortPin) {
	char pin = PortPin % 16; // pin number
	int exti = pin / 4;
	char extiPin = pin % 4;
	
	SYSCFG -> EXTICR[exti] &= ~(0xF<<extiPin*4); //clearing/stopping
	StopRisingandFallingIRQ(PortPin);
	EXTI -> IMR &= ~(1<<pin); //disable mask
	
	//disable NVIC
	__disable_irq();
	// conditional to choose proper statement
	if(pin==0) {
		NVIC_DisableIRQ(EXTI0_IRQn);
	} else if(pin==1) {
		NVIC_DisableIRQ(EXTI1_IRQn);
	} else if(pin==2) {
		NVIC_DisableIRQ(EXTI2_TSC_IRQn);
	} else if(pin==3) {
		NVIC_DisableIRQ(EXTI3_IRQn);
	} else if(pin==4) {
		NVIC_DisableIRQ(EXTI4_IRQn);
	} else if(pin<10) {
		NVIC_DisableIRQ(EXTI9_5_IRQn); // using an if statement is less typing than a case cause we type out 5-15
	} else {
		NVIC_DisableIRQ(EXTI15_10_IRQn);
	}
	__enable_irq();
}

	
	
