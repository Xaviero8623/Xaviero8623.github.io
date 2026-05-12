
//Mco clocks
#define LSI 2
#define LSE 3
#define SYSCLK 4
#define HSI 5
#define HSE 6
#define PLL 7

// APB divides
#define APB_DIV_1 0
#define APB_DIV_2 4
#define APB_DIV_4 5
#define APB_DIV_8 6
#define APB_DIV_16 7

// MCO clock divides
#define MCO_DIV_1 0
#define MCO_DIV_2 1
#define MCO_DIV_4 2
#define MCO_DIV_8 3
#define MCO_DIV_16 4
#define MCO_DIV_32 5
#define MCO_DIV_64 6
#define MCO_DIV_128 7

// SYSCLK divides
#define SYS_DIV_1 0
#define SYS_DIV_2 8
#define SYS_DIV_4 9
#define SYS_DIV_8 10
#define SYS_DIV_16 11
#define SYS_DIV_64 12
#define SYS_DIV_128 13
#define SYS_DIV_256 14
#define SYS_DIV_512 15

// PLL multipliers
#define x2 0
#define x3 1
#define x4 2
#define x5 3
#define x6 4
#define x7 5
#define x8 6
#define x9 7
#define x10 8
#define x11 9
#define x12 10
#define x13 11
#define x14 12
#define x15 13
#define x16 14

// HSEDIV 
#define DIV1 0
#define DIV2 1
#define DIV3 2
#define DIV4 3
#define DIV5 4
#define DIV6 5
#define DIV7 6
#define DIV8 7
#define DIV9 8
#define DIV10 9
#define DIV11 10
#define DIV12 11
#define DIV13 12
#define DIV14 13
#define DIV15 14
#define DIV16 15


// SWS states
#define SWS_HSI 0
#define SWS_HSE 1
#define SWS_PLL 2


// Clock speeds in MHz
#define HSEClkSpeed 8 // really zero becasue there is none on the nucleo board
#define HSIClkSpeed 8

// Clock sources
#define HSI_SRC 0
#define HSE_SRC 1
#define PLL_SRC 2
#define SYS_SRC 3





// Clock Functions 
// High speed external clock on
void ClockHSEInit(void);
// High speed external clock off
void ClockHSEoff(void);
// PLL on
void ClockPLLInit(void);
// PLL off
void ClockPLLoff(void);
// Read specific clocks off of MCO pin
void ReadClock(char clk, char div);
// Check PLL speed
int PLL_Speed(void);
// Check Sysclk speed
int SYSCLK_Speed(void);

// Set functions
void SetPLLSpeed(char source, char mult, char HSEDIV);
void SetSYSCLOCKSource(char source);
void SetHClock(char HPRE);
void APB1Clock(char prescalar);
void APB2Clock(char prescalar);