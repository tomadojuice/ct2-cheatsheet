# ADC / DAC — Analog-to-Digital & Digital-to-Analog Converter
**Computer Engineering 2 — ZHAW, School of Engineering, InES Institute of Embedded Systems**

---

## Motivation

Modern information processing is done in the digital domain because it is easier to process, store, and copy data. However, the real world is analog — signals are continuous and not discrete (e.g. a pressure sensor, music). This creates the need for devices to convert analog signals to digital and vice versa.

---

## Agenda

1. ADC and DAC — What it is, How it works, Characteristics, Types of error
2. ADCs on STM32F429 — Features and functionality, Programming the ADC
3. DACs on STM32F429 *(optional)* — Features and registers, DAC configuration example
4. Conclusions

---

## Learning Objectives

At the end of this lesson, you will be able to:

- Explain what an ADC/DAC is and what it is used for
- Describe how a (simple) Flash ADC/DAC works
- Name some application examples of ADC/DAC
- Name and explain important characteristics/error sources (sampling rate, voltage reference, offset and gain error)
- Name basic features of the ADC in the STM32F429
- Set up and use simple features of the ADC in STM32F429
- Use device documentation to understand features, interpret parameters, derive configuration, and find advanced features

> Note: The lecture focuses on *application* of ADCs in microcontrollers, not on ADC design. Advanced modes (injected mode, dual/triple modes) are not covered.

---

## ADC — Analog to Digital Converter

### What it is

- Converts an input signal (voltage) to a digital value (N-bit)
- Conversion results in one of **2^N** possible numerical levels
- Input signal can be **dynamic** (changing over time) or **static** (time-invariant)
  - Dynamic signals are sampled at specific time intervals
  - Samples are transformed into a series of discrete values

**Example — 3-bit ADC:**
- 8 possible levels (000 – 111)
- Each conversion corresponds to one of 8 levels

### Input Signals

- **Differential inputs:** V_in = V_in+ − V_in−
- **Single-ended mode:** only V_in+ used; V_in− is connected to ground
- **Reference voltage V_REF+:** internal or external stable voltage needed to weight the input voltage

Formula: `V_in = (digital value) × V_REF+ / 2^N`

### Resolution, LSB, and Full Scale Range

| Term | Definition |
|---|---|
| **Resolution** | Number of bits N (size of digital word) |
| **LSB** (Least Significant Bit) | 1 LSB ≙ V_REF / 2^N |
| **Full Scale Range (FSR)** | Range between analog levels of min and max digital codes; V_FSR is one LSB less than V_REF |

**Example:** V_REF = 8 V, N = 3 bits → 1 LSB = 1 V, FSR from 0 V to 7 V

---

## ADC — How it Works

### Flash ADC

- Network of **2^N resistors** divides V_REF into 2^N levels
- **2^N − 1 analog comparators** compare the input signal to the divided reference voltages
- An **encoder** transforms the comparator results into an N-bit word

**Example (3-bit, V_REF = 8V, V_in = 2.3V):**
- Comparator stream = `0000011`
- 3-bit output word = `010`

### Successive Approximation Register (SAR) ADC

Used on most microcontrollers. Approaches V_in by successive division by 2 (binary search):

1. Start with MSB = 1, all other bits at 0 (half the digital range)
2. DAC generates analog value V_DAC; compare to V_in
   - If V_DAC < V_in → keep bit at 1; else set to 0
3. Repeat for each of the N bits (N steps total)

**Example (3-bit):**
1. Higher than `100` → 1
2. Lower than `110` → 10
3. Higher than `101` → **101** ✓

### Flash vs SAR ADC

| | Flash ADC | SAR ADC |
|---|---|---|
| Speed | Very fast | Up to 5 Msps |
| Hardware | Many elements (255 comparators for 8-bit) | Compact |
| Power | High | Good trade-off |
| Use | High-speed applications | Most microcontrollers |
| Resolution | — | 8 to 16 bits |

---

## DAC — Digital to Analog Converter

### What it is

- Converts an N-bit digital input to an analog voltage level
- A series of digital values produces a series of voltage steps → dynamic output signal
- "Play-back" speed depends on sampling interval

Formula: `V_out = (digital value) × V_REF / 2^N`

### Flash DAC

- Network of equal-value resistors creates 2^N voltage levels
- N-bit digital input is decoded into 2^N select signals (S0 … Sx)
- One voltage level is selected as the DAC output
- A voltage follower reduces load on the resistor network

---

## ADC Characteristics

### Sampling Rate

- Input is sampled at discrete time points → discontinuities
- Must be **at least twice the highest frequency** component of the input signal (**Nyquist–Shannon theorem**)

### Conversion Time

- Time from start of sampling until digital output is available
- Higher resolution → longer conversion time

### Monotonicity

- An increase in V_in results in an increase or no change of the digital output (and vice versa)

---

## ADC — Types of Error

### Quantization Error

- Analog input has infinite states; digital output has finite states
- Introduces an error between **−0.5 LSB** and **+0.5 LSB**
- Reducible by increasing N (more bits) or reducing V_REF (reduces FSR too)

### Offset Error (Zero-Scale Error)

- Deviation of the real ADC from the ideal ADC at input point zero
- Ideal: first transition at 0.5 LSB above zero
- Can be corrected in software/hardware
- Measured by increasing input from zero until the first transition occurs

### Gain Error

- Indicates how well the slope of the actual transfer function matches the ideal
- Expressed in LSB or as %FSR
- Calibration with hardware or software is possible

> **full-scale error = offset error + gain error**

---

## ADCs on STM32F429 — Features and Functionality

### Simplified ADC Diagram

- GPIO pins → Analog Mux → up to 16 regular channels → ADC1
- Internal sources: Temperature sensor, V_REFINT, V_BAT
- Configuration registers: SQR1/2/3 (sequence), SMPR1/2 (sampling time), CR1/2 (control)
- Status register with EOC (End of Conversion) flag → ADC interrupt to NVIC
- Conversion triggered by timer signals, external pins, or by setting SWSTART in CR2

### Conversion Modes

|  | Single channel | Multi-channel (scan mode) |
|---|---|---|
| **Single conversion** | Convert 1 channel, then stop | Convert all channels in sequence, then stop |
| **Continuous conversion** | Continuously convert 1 channel until stopped | Continuously convert a group of channels until stopped |

### ADC Timing

1. **ADC activation** by software (ADON bit)
2. **ADC stabilization** (t_STAB)
3. **Start conversion** by software (SWSTART) or trigger signal
4. **EOC flag** signals end of conversion
5. Reading the data register **clears the EOC flag**

### Total Conversion Time

```
T_total = T_sample + T_conv
```

- **T_sample:** individually programmable per channel (ADC_SMPR1/2); 3 to 480 cycles
- **T_conv** depends on resolution:
  - 12-bit → 12 ADCCLK cycles
  - 10-bit → 10 ADCCLK cycles
  - 8-bit  → 8 ADCCLK cycles
  - 6-bit  → 6 ADCCLK cycles

**Example:** APB2 = 48 MHz, Prescaler /2 → ADCCLK = 24 MHz, 3 cycles sample, 12-bit:
`T_total = (3 + 12) / 24 MHz = 0.625 µs` → max sampling rate ≈ 1.6 Msps

### Analog Watchdog

- Monitors one or more channels with minimal CPU overhead
- Compares converted value to programmable min/max limits
- Generates flag/interrupt if signal is outside limits

### STM32F429 ADC Static Accuracy (f_ADC = 30 MHz)

| Parameter | Typ | Max | Unit |
|---|---|---|---|
| Total unadjusted error | ±2 | ±5 | LSB |
| Offset error | ±1.5 | ±2.5 | LSB |
| Gain error | ±1.5 | ±3 | LSB |

- Max sampling rate: up to **2.4 Msps** (at V_DD = 2.7–3.6 V)
- Each active ADC adds ~1.6 mA current consumption

---

## Programming the ADC (STM32F429)

### Register Memory Map

| ADC Region | Offset | Address |
|---|---|---|
| ADC1 specific | 0x000–0x04C | 0x4001 2000 + offset |
| ADC2 specific | 0x100–0x14C | 0x4001 2000 + 0x100 + offset |
| ADC3 specific | 0x200–0x24C | 0x4001 2000 + 0x200 + offset |
| Common | 0x300–0x308 | 0x4001 2000 + 0x300 + offset |

### Common Register: ADC_CCR

| Bit field | Description |
|---|---|
| TSVREFE | Enable/disable temperature sensor and V_REFINT |
| VBATE | Enable/disable V_BAT |
| ADCPRE[1:0] | ADC prescaler: 00/01/10/11 → APB2 ÷ 2/4/6/8 |

### Specific Registers per ADC

**ADC_SR — Status Register**

| Bit | Description |
|---|---|
| OVR | Overrun — result data overwritten |
| STRT | Conversion started (regular channel) |
| EOC | End of Conversion — cleared by reading ADC_DR |

**ADC_CR1 — Control Register 1**

| Bit | Description |
|---|---|
| OVRIE | OVR Interrupt Enable |
| EOCIE | EOC Interrupt Enable |
| RES[1:0] | Resolution: 00/01/10/11 → 12/10/8/6-bit |
| SCAN | Enable scan mode |

**ADC_CR2 — Control Register 2**

| Bit | Description |
|---|---|
| SWSTART | Start conversion (regular channel) by software; cleared by HW |
| EXTEN[1:0] | External trigger: disabled / pos edge / neg edge / both edges |
| EXTSEL | External event select for regular group trigger |
| ALIGN | 0 = right-aligned, 1 = left-aligned |
| EOCS | 0 = EOC at end of sequence; 1 = EOC at end of each conversion |
| DMA | Enable DMA |
| CONT | 0 = single conversion mode; 1 = continuous conversion mode |
| ADON | ADC On |

**ADC_SMPR1/2 — Sample Time Registers**

| SMPx[2:0] | Cycles |
|---|---|
| 000 | 3 |
| 001 | 15 |
| 010 | 28 |
| 011 | 56 |
| 100 | 84 |
| 101 | 112 |
| 110 | 144 |
| 111 | 480 |

**ADC_SQR1/2/3 — Sequence Registers**

| Field | Description |
|---|---|
| L[3:0] | Sequence length: L+1 conversions (0000 = 1, 1111 = 16) |
| SQx[4:0] | Channel number for the x-th conversion in sequence |

**Example:** Scan 3 channels CH7 → CH5 → CH9:
```
SCAN = 1, L[3:0] = 0x2
SQ1[4:0] = 0x7, SQ2[4:0] = 0x5, SQ3[4:0] = 0x9
```

### Code Example — Single-Channel Polling on PF8 (ADC3, CH6)

```c
hal_rcc_set_peripheral(PER_GPIOF, ENABLE);   // enable GPIO
hal_rcc_set_peripheral(PER_ADC3, ENABLE);    // enable ADC3

GPIOF->MODER |= (0x3 << 16);                 // analog mode on PF8
ADCCOM->CCR   = (0x3 << 16);                 // ADC prescaler /8

ADC3->CR1  = 0x0;                            // 12-bit resolution, no scan
ADC3->CR2  = 0x1;                            // single conv., enable ADC, right-align
ADC3->SMPR1 = 0x0;
ADC3->SMPR2 = (0x2 << (3*6));               // 28 cycles sample time for CH6
ADC3->SQR1  = 0x0;                           // sequence length = 1
ADC3->SQR2  = 0x0;
ADC3->SQR3  = 0x6;                           // CH6 is first in sequence

while (1) {
    ADC3->CR2 |= (0x1 << 30);               // start conversion (SWSTART)
    while (!(ADC3->SR & 0x2)) {}            // wait for EOC
    CT_SEG7->BIN.HWORD = ADC3->DR;         // read result
}
```

> **Q: Max sampling rate with APB2 = 42 MHz?**
> Prescaler /8 → ADCCLK = 5.25 MHz; T_total = (28 + 12) / 5.25 MHz ≈ 7.6 µs → ~131 ksps

---

## DACs on STM32F429 *(Optional)*

### Features

- **2 independent 12-bit voltage output DACs** (also support 8-bit mode)
- Left or right data alignment in 12-bit mode
- Can be combined with DMA
- Integrated **output buffers** to reduce output impedance (no external op-amp needed)
- The 2 DACs can be grouped for **simultaneous update**
- **Noise / triangular-wave generation** built in
- Operating range: 1.8 V ≤ V_DDA ≤ 3.6 V; 1.8 V ≤ V_REF+ ≤ V_DDA

### Conversion Trigger Sources

- Software (SWTRIG)
- Internal timers (TIM2/4/5/6/7/8)
- External event (EXTI_9)

### DAC Output Voltage Formula

```
DAC_output = V_REF+ × DOR / 4095
```

where DOR is the 12-bit digital value to convert.

### DAC Conversion Timing

- Write value to **DAC_DHRx** (data holding register)
- Data transfers to **DAC_DORx** after 1 APB1 clock cycle (3 cycles if HW trigger)
- Analog output available after settling time **t_SETTLING** (typ. 3 µs, max. 6 µs for full-scale transition)
- Max update rate for 1 LSB changes: **1 MS/s**

### DAC Electrical Characteristics (Selected)

| Parameter | Value | Unit |
|---|---|---|
| Resistive load (buffer ON) | ≥ 5 | kΩ |
| Output impedance (buffer OFF) | max 15 | kΩ |
| Capacitive load | max 50 | pF |
| Settling time (full scale, 10-bit transition) | typ 3 / max 6 | µs |
| Offset error (12-bit, V_REF+ = 3.6 V) | max ±12 | LSB |

### DAC Register Map (Base: 0x4000 7400)

| Offset | Register | Description |
|---|---|---|
| 0x00 | DAC_CR | Control register (both channels) |
| 0x04 | DAC_SWTRIGR | Software trigger register |
| 0x08 | DAC_DHR12R1 | CH1 12-bit right-aligned data |
| 0x0C | DAC_DHR12L1 | CH1 12-bit left-aligned data |
| 0x10 | DAC_DHR8R1 | CH1 8-bit right-aligned data |
| 0x14 | DAC_DHR12R2 | CH2 12-bit right-aligned data |
| 0x18 | DAC_DHR12L2 | CH2 12-bit left-aligned data |
| 0x1C | DAC_DHR8R2 | CH2 8-bit right-aligned data |

**Key DAC_CR bits (per channel):**

| Bit | Description |
|---|---|
| EN | Enable DAC channel |
| BOFF | Buffer Off (1 = disabled, 0 = enabled) |
| TEN | Trigger Enable |
| TSEL[2:0] | Trigger source select (111 = software trigger) |
| WAVE[1:0] | Wave generation (00 = disabled) |
| MAMP[3:0] | Mask/amplitude for wave generation |

> When a DAC channel is enabled, the corresponding GPIO pin (PA4 or PA5) is automatically connected to the analog output. Configure the pin as analog (AIN) first to avoid parasitic current.

### DAC Configuration Example (Assembler — CH1, 8-bit, PA4)

```asm
; Enable clocks
LDR R6, =REG_RCC_AHB1ENR
LDR R7, =0x1           ; GPIOA clock
BL  set_sfr

LDR R6, =REG_RCC_APB1ENR
LDR R7, =0x20000000    ; DAC clock
BL  set_sfr

; Configure PA4 as analog
LDR R6, =REG_GPIOA_MODER
LDR R7, =0x300
BL  set_sfr

; Enable DAC channel 1
LDR R6, =REG_DAC_CR
LDR R7, =0x1
BL  set_sfr

; Set initial output to 0
LDR R6, =REG_DAC_DHR8R1
LDR R7, =0x0
BL  set_sfr
```

---

## Conclusions

- ADC/DAC are used to **interface the analog and digital world** (instrumentation, audio, control)
- **Conversion rate** and **number of bits** are the key parameters
- Real devices introduce **errors** (quantization, offset, gain) that affect conversion results
- The STM32F429 provides ADCs and DACs with many configurable features — details are found in the datasheet and reference manual
- ADC and DAC contain both analog and digital parts → they are **mixed-signal devices**

---

## References

1. STM32F42xxx Datasheet
2. STM32F42xxx Reference Manual (RM0090)
3. AN3116 — "STM32's ADC modes and their applications"
4. Maxim Integrated App Note 641 — https://www.maximintegrated.com/en/app-notes/index.mvp/id/641
5. Atmel AVR127 — Understanding ADC Parameters
