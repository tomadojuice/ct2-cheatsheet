# Computer Engineering 2 — Lecture Notes

---

## Lecture 1: Microcontroller Basics

### Motivation: From a CPU to an Embedded System

CT1 focused on the CPU itself. CT2 asks: **what do we need to communicate with the outside world?**

An embedded system extends the CPU with:
- **Memory** (on-chip flash, SRAM)
- **Peripherals (I/O)** — connected via the system bus

The system bus consists of:
- Data Lines
- Address Lines
- Control Signals

---

### Learning Objectives

By the end of this lecture, you will be able to:
- Explain the concept of peripherals and memory-mapped peripheral registers
- Enumerate the signal groups of a system bus
- Distinguish between synchronous and asynchronous bus timing
- Know what "tri-state" means
- Interpret simple bus timing diagrams
- Describe the function and purpose of control and status registers
- Explain full vs. partial address decoding
- Access control registers from C using the `volatile` qualifier
- Analyze address decoding logic and derive applicable addresses/ranges
- Explain the function of wait states

---

### From a CPU to an Embedded System

A **microcontroller** is a single-chip solution integrating:

| Component | Example Use |
|-----------|-------------|
| CPU (Cortex-M4) | Program execution |
| On-chip memories | Flash, SRAM |
| GPIO | LEDs, Buttons |
| SPI | LCD display |
| Timer/PWM | RGB colors, PWM signals |
| Timer/Counter | Counting pulses |
| ADC | Sensor voltage readings |
| FMC | External memories |
| UART | PC communication |
| GPIO-EXTI | Interrupts |

All components are interconnected through the **System Bus**.

---

### Peripherals

> *A peripheral is a configurable hardware block of a microcontroller that accepts a specific task from the CPU, executes this task and reports back the status (e.g., task completion, error). Many peripherals are interfaces to the outside world. Examples include GPIO, UART, SPI, ADC …*

#### Peripheral Register Types

The CPU controls and monitors peripherals through registers (arrays of flip-flops):

- **Control Registers** — CPU writes to configure the peripheral
- **Status Registers** — CPU reads to monitor peripheral state (usually read-only)
- **Data Registers** — CPU exchanges data with the peripheral

---

### Memory-Mapped Peripheral Registers

ARM & STM map peripheral registers into the memory address range. The Reference Manual defines addresses for each register.

**Example (CT-Board):**
```c
#define ADDR_LED_31_0      0x60000100
#define ADDR_DIP_SWITCH_31_0 0x60000200

uint32_t value = read_word(ADDR_DIP_SWITCH_31_0);
write_word(ADDR_LED_31_0, value);
```

**Memory map (simplified):**

| Address Range | Region |
|---------------|--------|
| `0x0000'0000` | System (boot) |
| `0x2000'0000` | On-chip RAM |
| `0x4000'0000` | ST Peripherals |
| `0x6000'0000` | CT Board I/O |
| `0xA000'0000` | External Memory |
| `0xE000'0000` | Cortex-M Peripherals |
| `0xFFFF'FFFF` | — |

Peripheral registers are spaced 4 bytes apart:
- Base address → Register 0
- Base address + 4 → Register 1
- Base address + 4×n → Register n

---

### System Bus

The system bus **interconnects the CPU with memory and peripherals**.

- **CPU = Master**: Initiates and controls all transfers
- **Peripherals / Memory = Slaves**: Respond to requests

> *Etymology: "Bus" from Latin omnibus — "for all"*

#### Signal Groups

| Group | Direction | Description |
|-------|-----------|-------------|
| Address lines | Master → Slave | Unidirectional; number of lines defines address space size |
| Data lines | Bidirectional | 8, 16, 32, or 64 parallel lines |
| Control signals | — | Control read/write direction and provide timing |

**Cortex-M:** 32 address lines → 2³² = 4 Giga addresses (`0x0000'0000` – `0xFFFF'FFFF`)

#### Bus Specification Components
- Protocol and operations
- Signals (number and description)
- Timing (frequency, setup/hold times)
- Electrical properties (drive strength, load)
- Mechanical requirements

---

### Bus Timing

#### Synchronous Bus
- Master and slaves share a **common clock**
- Clock edges control bus transfers on both sides
- Used by most on-chip buses; also DDR and synchronous RAM off-chip

#### Asynchronous Bus
- Slaves have **no access to the master's clock**
- Control signals carry timing information for synchronization
- Used for low-data-rate off-chip memories (parallel flash, async RAM)

---

### Digital Logic Basics

#### CMOS Inverter
- Uses complementary p-type (closes when IN=0) and n-type (closes when IN=1) transistors
- `IN='0'` → p-type closed, n-type open → OUT='1'
- `IN='1'` → p-type open, n-type closed → OUT='0'
- A **buffer** is two inverters in series

#### Tri-State Buffer
Adds an ENABLE input to a buffer:

| ENABLE | OUT |
|--------|-----|
| '1' | Passes input through |
| '0' | **'Z'** (high impedance — electrically disconnected) |

> *When a signal is tri-state, it is said to be "floating" — it can be moved to either '0' or '1' by parasitic effects.*

This is how multiple devices share a single bus line without electrical conflicts:
- **Write**: CPU drives bus; all slave drivers in tri-state
- **Read**: CPU driver in tri-state; only selected slave drives bus

#### Bus Timing Diagram Notation (Groups of Signals)

| Symbol | Meaning |
|--------|---------|
| Hatched box | Unknown values |
| Box with hex value (e.g. `0x4`) | Bus holds that value |
| Open/dashed region | Tri-state — no driver active |

---

### Synchronous Bus Example (STM32F429xx FMC)

Signal names use the convention: prefix **N** = active-low (e.g. `NOE` = "NOT Output Enable").

#### Key Signals
| Signal | Meaning |
|--------|---------|
| `CLK` | Common clock |
| `NE` | Not Enable — marks start/end of cycle (active-low) |
| `NWE` | Not Write Enable (active-low) |
| `NOE` | Not Output Enable / read (active-low) |
| `A[31:0]` | Address lines |
| `D[31:0]` | Data lines |

#### Write Timing (Example)
```
CPU writes 0x8899'AABB to address 0x2100'0248
  LDR R0, =0x2100'0248
  LDR R1, =0x8899'AABB
  STR R1, [R0]
```
- T1–T2: Address and control signals asserted
- T2–T3: Data placed on bus by CPU
- T4: Data sampled by slave on rising CLK edge
- T5: Bus released

**Memory layout after write (little-endian):**
| Address | Byte |
|---------|------|
| `0x2100'0248` | `0xBB` (D[7:0]) |
| `0x2100'0249` | `0xAA` (D[15:8]) |
| `0x2100'024A` | `0x99` (D[23:16]) |
| `0x2100'024B` | `0x88` (D[31:24]) |

#### Bus Access Sizes
| Instruction | Size | NBL signals |
|-------------|------|-------------|
| `STR` | Word (32-bit) | All 4 NBL active |
| `STRH` | Half-word (16-bit) | 2 NBL active |
| `STRB` | Byte (8-bit) | 1 NBL active |

---

### Control and Status Registers

#### Hardware Slave Structure
Each peripheral contains an address decoder and registers:
- **OE cycle counter** + AND gate → `read_enable`
- **WE cycle counter** + AND gate → `write_enable`
- D flip-flops store register values
- Tri-state output buffers drive the data bus during reads

#### Register Bit Categories
- **Control bits**: CPU writes → hardware reacts to output
- **Status bits**: Hardware writes → CPU reads state

The same register may contain both control and status bits.

---

### Address Decoding

When the CPU performs a bus cycle, a slave must determine if it is the target.

#### Full Address Decoding
- All address lines (A31–A0) are decoded
- **1:1 mapping** — exactly one address maps to one register
- Example: Active only at `0x4000'8234`

#### Partial Address Decoding
- Only a **subset** of address lines are decoded
- **n:1 mapping** — multiple addresses map to the same register
- Motivations: simpler logic, address aliasing
- Example: Active for any address `0x4000'82xx` (A7–A0 ignored)

---

### Slow Slaves and Wait States

Different slaves have different access times. Rather than limiting all bus cycles to the slowest slave, **wait states** are inserted per-slave based on address:

- TW clock cycles are inserted between the normal T1–T4 phases
- Two approaches:
  1. **Programmed wait states** at the bus interface unit (based on address)
  2. **Ready signal** from slave — slave asserts when it is ready (useful for variable-latency slaves)

---

### Bus Hierarchies

The STM32F429ZI uses multiple buses:
- **System bus (on-chip)**: 32 data lines, 32 address lines
- **External bus (off-chip via FMC)**: 16 data lines, 26 address lines

ARM bus names:
- **AHB** (ARM High-performance Bus) — high-speed peripherals (AHB1 @ 84 MHz, AHB2 @ 84 MHz)
- **APB** (ARM Peripheral Bus) — slower peripherals (APB1 @ 42 MHz, APB2 @ 84 MHz)

---

### Accessing Control Registers in C

#### The Problem: Compiler Optimization
An optimizing compiler may eliminate seemingly redundant reads/writes:
```c
uint32_t ui;
ui = 0xAAAAAAA;   // may be removed — overwritten immediately
ui = 0xBBBBBBB;
while (ui == 0) { ... }  // loop may be optimized away
```

#### The Solution: `volatile`
```c
volatile uint32_t ui;  // compiler MUST execute every read/write
```
- Tells the compiler the variable may change outside its control (e.g., by hardware or an interrupt)
- Prevents read/write elimination and reordering

#### Access via Pointer
```c
volatile uint32_t *p_reg;

// Write to LEDs
p_reg = (volatile uint32_t *)(0x60000100);
*p_reg = 0xAA55AA55;

// Wait for DIP switches to be non-zero
p_reg = (volatile uint32_t *)(0x60000200);
while (*p_reg == 0) { }
```

#### Using `#define` Macros
```c
#define LED31_0_REG   (*((volatile uint32_t *)(0x60000100)))
#define BUTTON_REG    (*((volatile uint32_t *)(0x60000210)))

LED31_0_REG = 0xBBCCDDEE;    // Write LEDs
aux_var = BUTTON_REG;          // Read buttons
```

---

### Conclusions — Microcontroller Basics

| Topic | Key Points |
|-------|------------|
| Microcontrollers | Single-chip, low-cost, real-time, low-power |
| System Bus | Address + data + control lines; synchronous or async |
| Bus Transfers | CPU (master) reads/writes slaves with defined timing |
| Wait States | Allow slow peripherals without degrading fast ones |
| Address Decoding | Full (1:1) vs. partial (n:1 aliasing) |
| C Register Access | Use `volatile` pointer; `#define` macros |

---
---

## Lecture 2: General Purpose I/O (GPIO)

*Reference: STM32 Reference Manual RM0090 Rev 19, Pages 267–288*

---

### Learning Objectives

By the end of this lecture, you will be able to:
- Work with register descriptions in reference manuals
- Explain the concept and implementation of GPIOs
- Explain the differences between open-drain and push-pull
- Use GPIOs in your own programs
- Explain the idea of a Hardware Abstraction Layer (HAL)

---

### Working with STM32 Documents

Two key documents:
1. **STM32F429 Datasheet** — pin-out, block diagram, electrical characteristics
2. **Reference Manual RM0090** — register descriptions, peripheral chapters

#### Register Address Formula
```
Register address = Base address + Offset
```

**GPIO Base Addresses (from RM0090 memory map):**

| Peripheral | Base Address |
|-----------|--------------|
| GPIOA | `0x4002 0000` |
| GPIOB | `0x4002 0400` |
| GPIOC | `0x4002 0800` |
| GPIOD | `0x4002 0C00` |
| GPIOE | `0x4002 1000` |
| GPIOF | `0x4002 1400` |
| GPIOG | `0x4002 1800` |
| GPIOH | `0x4002 1C00` |
| GPIOI | `0x4002 2000` |
| GPIOJ | `0x4002 2400` |
| GPIOK | `0x4002 2800` |

**Example:** `GPIOA_OTYPER` address = `0x4002 0000` + `0x0004` = **`0x4002 0004`**

---

### Why GPIOs?

**Situation:** A microcontroller is a general-purpose device with many built-in functional blocks but a limited number of physical pins.

**Problem:** Not all functions can be simultaneously routed to I/O pins.

**Solution:** Pin sharing — each pin is configurable as one of several functions:
- Digital input/output (GPIO)
- Serial interface (UART TX/RX, SPI, I²C)
- Timer/Counter
- ADC input

> *Programming internal registers selects the active function for each pin. Configuration is usually static (set once at startup).*

---

### STM32F4xx GPIO Features

- Pins configurable by software:
  - **Output**: push-pull or open-drain; with/without pull-up or pull-down
  - **Input**: floating, with/without pull-up or pull-down
  - **Alternate function**: routes internal peripheral signal to/from pin
- High-current-capable
- Speed selection
- Maximum I/O toggling up to **90 MHz**
- Most pins shared with alternate digital or analog functions

---

### GPIO Hardware Structure

*Describes a single bit in a 16-bit GPIO port (e.g., GPIO D.7)*

#### Step 1 — Input Path
- I/O pin connected through Schmitt trigger to an **Input Data Register (IDR)** flip-flop
- `idr_read_enable` (from address decoder) gates the flip-flop output onto the data bus

**GPIOx_IDR** — Port input data register (read-only)
- Contains the current logic level of each I/O pin

#### Step 2 — Adding Output
- An **Output Data Register (ODR)** flip-flop driven by `odr_write_enable`
- Its Q output feeds through the OTYPER-controlled output driver to the I/O pin
- Problem: output always overwrites input → need direction control

**GPIOx_ODR** — Port output data register (read-write)
- Controls the output value of each I/O pin

#### Step 3 — Direction Control (MODER)
- **MODER[0]** flip-flop: when '1' (output mode), enables the output driver
- When '0' (input mode), output driver is placed in tri-state

#### Full Structure
The complete GPIO bit includes:
- IDR (input data register flip-flop)
- ODR (output data register flip-flop)
- MODER direction control
- OTYPER output type control (push-pull vs. open-drain)
- PUPDR pull-up/pull-down resistors
- Analog input path (Schmitt trigger disabled)
- Alternate function input/output muxes

---

### Configuring GPIO

#### Direction — `GPIOx_MODER`

Each pin uses **2 bits** (MODER[1:0]):

| MODER[1:0] | Function |
|-----------|----------|
| `00` | Input |
| `01` | General purpose output |
| `10` | Alternate function |
| `11` | Analog |

> For alternate function mode, the specific function is selected via `GPIOx_AFRL` (pins 0–7) or `GPIOx_AFRH` (pins 8–15).

---

#### Output Type — `GPIOx_OTYPER`

One bit per pin (OT):

| OT | Output Type |
|----|-------------|
| `0` | **Push-pull** — output stage drives both high and low |
| `1` | **Open-drain** — output stage can only drive low |

---

#### Push-Pull vs. Open-Drain

**Push-pull** (OT = 0):
- Both P-MOS and N-MOS transistors active
- Can actively drive pin to VDD ('1') or GND ('0')

**Open-drain** (OT = 1):
- Only N-MOS transistor present
- ODR.x = '0' → transistor conducts → pin pulled to GND
- ODR.x = '1' → transistor blocks → pin is **floating** (high impedance)
- Requires an external pull-up resistor to achieve a logical '1'

**When to use open-drain:**
- Multiple devices sharing a single bus line (e.g., I²C)
- No electrical conflicts possible — any device can pull low at any time
- Common external pull-up to VDD defines the idle state

---

#### Pull-up / Pull-down — `GPIOx_PUPDR`

Each pin uses 2 bits (PUPDR[1:0]):

| PUPDR[1:0] | Configuration |
|-----------|---------------|
| `00` | No pull-up, no pull-down (floating) |
| `01` | Pull-up |
| `10` | Pull-down |
| `11` | Reserved |

---

#### Output Speed — `GPIOx_OSPEEDR`

Each pin uses 2 bits (OSPEEDR[1:0]):

| OSPEEDR[1:0] | Speed |
|-------------|-------|
| `00` | Low speed |
| `01` | Medium speed |
| `10` | High speed |
| `11` | Very high speed |

> *Motivation: Match output stage impedance to transmission line; control edge steepness for EMC compliance.*

---

#### Configuration Overview

| MODER[1:0] | OTYPER | PUPDR[1:0] | I/O Configuration |
|-----------|--------|-----------|-------------------|
| `01` | `0` | `00` | GP output, Push-pull |
| `01` | `0` | `01` | GP output, PP + Pull-up |
| `01` | `0` | `10` | GP output, PP + Pull-down |
| `01` | `1` | `00` | GP output, Open-drain |
| `01` | `1` | `01` | GP output, OD + Pull-up |
| `01` | `1` | `10` | GP output, OD + Pull-down |
| `00` | x | `00` | Input, Floating |
| `00` | x | `01` | Input, Pull-up |
| `00` | x | `10` | Input, Pull-down |
| `10` | `0` | `00` | Alternate function, PP |
| `10` | `1` | `00` | Alternate function, OD |
| `11` | x | `00` | Analog input/output |

---

### Setting and Clearing Output Bits

#### `GPIOx_BSRR` — Bit Set/Reset Register

Provides **atomic** set and clear operations (no read-modify-write needed):

| Bits [15:0] | BS (Bit Set) | Write '1' to set pin high |
|-------------|-------------|---------------------------|
| Bits [31:16] | BR (Bit Reset) | Write '1' to clear pin low |

```
To set   bit x:  write '1' to BSRR[x]
To clear bit x:  write '1' to BSRR[x+16]
```

> *Advantage over ODR: setting/clearing via ODR requires read→OR→write (3 steps). An interrupt between steps could corrupt the result. BSRR is a single atomic write.*

---

### GPIO Register Map Summary

| Offset | Register | Description |
|--------|----------|-------------|
| `0x00` | `GPIOx_MODER` | Mode register |
| `0x04` | `GPIOx_OTYPER` | Output type register |
| `0x08` | `GPIOx_OSPEEDR` | Output speed register |
| `0x0C` | `GPIOx_PUPDR` | Pull-up/pull-down register |
| `0x10` | `GPIOx_IDR` | Input data register (read-only) |
| `0x14` | `GPIOx_ODR` | Output data register |
| `0x18` | `GPIOx_BSRR` | Bit set/reset register (write-only) |
| `0x1C` | `GPIOx_LCKR` | Port lock register |
| `0x20` | `GPIOx_AFRL` | Alternate function low (pins 0–7) |
| `0x24` | `GPIOx_AFRH` | Alternate function high (pins 8–15) |

---

### GPIO Cookbook — Procedure

1. Find the physical pin number in the datasheet and map it to GPIOx.y
2. Calculate register address: base address + offset
3. Configure:
   - `GPIOx_MODER` — direction / function
   - `GPIOx_OTYPER` — push-pull or open-drain
   - `GPIOx_OSPEEDR` — speed
   - `GPIOx_PUPDR` — pull-up/pull-down
4. Data operations:
   - Input → read `GPIOx_IDR`
   - Output → write `GPIOx_ODR` or `GPIOx_BSRR`

---

### Worked Example: Configure Pin 37 as Low-Speed Open-Drain Output with Pull-up

**Step 1 — Identify pin:**
- Pin 37 (LQFP144) = GPIOA Bit 3
- Base address GPIOA = `0x4002 0000`

**Step 2 — Register addresses:**

| Register | Offset | Address |
|----------|--------|---------|
| GPIOA_MODER | `0x00` | `0x4002 0000` |
| GPIOA_OTYPER | `0x04` | `0x4002 0004` |
| GPIOA_OSPEEDR | `0x08` | `0x4002 0008` |
| GPIOA_PUPDR | `0x0C` | `0x4002 000C` |

**Step 3 — Register values:**

| Register | Bits | Value | Meaning |
|----------|------|-------|---------|
| GPIOA_MODER | [7:6] (MODER3) | `01` | General purpose output |
| GPIOA_OTYPER | [3] (OT3) | `1` | Open-drain |
| GPIOA_OSPEEDR | [7:6] (OSPEEDR3) | `00` | Low speed |
| GPIOA_PUPDR | [7:6] (PUPDR3) | `01` | Pull-up |

---

### Hardware Abstraction Layer (HAL)

Directly writing `#define` macros for every register would result in 110 macros (11 ports × 10 registers) with repetitive code.

#### Solution: C Struct + Pointer

**`reg_stm32f4xx.h`** defines:

```c
typedef struct {
    volatile uint32_t MODER;    // Port mode register
    volatile uint32_t OTYPER;   // Output type register
    volatile uint32_t OSPEEDR;  // Output speed register
    volatile uint32_t PUPDR;    // Pull-up/pull-down register
    volatile uint32_t IDR;      // Input data register
    volatile uint32_t ODR;      // Output data register
    volatile uint32_t BSRR;     // Bit set/reset register
    volatile uint32_t LCKR;     // Port lock register
    volatile uint32_t AFRL;     // AF low register (pins 0..7)
    volatile uint32_t AFRH;     // AF high register (pins 8..15)
} reg_gpio_t;

#define GPIOA  ((reg_gpio_t *) 0x40020000)
#define GPIOB  ((reg_gpio_t *) 0x40020400)
// ... etc.
```

**Usage:**
```c
GPIOA->MODER = 0x55555555;   // set all pins as output
```

The struct member order matches the register offsets, so `GPIOA->MODER` automatically maps to `0x4002 0000 + 0x00`, `GPIOA->OTYPER` to `0x4002 0000 + 0x04`, etc.

---

### Complete Configuration Example in C

```c
#include "reg_stm32f4xx.h"

// Configure GPIOA pin 3: GP output, open-drain, low speed, pull-up
void config_gpioa_pin3(void)
{
    // MODER3 = 01 (GP output) — clear bits [7:6], then set bit [6]
    GPIOA->MODER &= ~(0x03 << 6);
    GPIOA->MODER |=  (0x01 << 6);

    // OT3 = 1 (open-drain)
    GPIOA->OTYPER |= (0x01 << 3);

    // OSPEEDR3 = 00 (low speed) — clear bits [7:6]
    GPIOA->OSPEEDR &= ~(0x03 << 6);

    // PUPDR3 = 01 (pull-up) — clear bits [7:6], then set bit [6]
    GPIOA->PUPDR &= ~(0x03 << 6);
    GPIOA->PUPDR |=  (0x01 << 6);
}
```

---

### Conclusions — GPIO

| Topic | Key Points |
|-------|------------|
| Pin sharing | Limited pins serve multiple functions; registers select function |
| GPIO direction | MODER: `00` input, `01` GP output, `10` AF, `11` analog |
| Output type | OTYPER: `0` push-pull (drives high & low), `1` open-drain (drives low only) |
| Pull resistors | PUPDR: `00` float, `01` pull-up, `10` pull-down |
| Speed | OSPEEDR: low/medium/high/very-high — controls edge steepness |
| Data I/O | IDR to read inputs; ODR or BSRR to set outputs |
| Atomic access | Use BSRR to set/clear bits without read-modify-write race conditions |
| HAL | Struct + pointer maps register names to addresses cleanly |
