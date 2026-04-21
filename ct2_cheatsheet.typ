// =========================================================
// Computer Engineering 2 — Zwischenprüfung Cheatsheet
// ZHAW · School of Engineering
// Compile with: typst compile ct2_cheatsheet.typ
// =========================================================

#set page(
  paper: "a4",
  margin: (x: 0.7cm, y: 0.7cm),
  numbering: "1 / 1",
  number-align: center,
  footer: context [
    #set text(size: 7pt, fill: gray)
    #h(1fr) Page #counter(page).display("1") of #context counter(page).final().last() #h(1fr)
  ],
)

#set text(size: 7.8pt, font: "New Computer Modern")
#set par(leading: 0.42em, justify: false)

// ------- Heading styles -------
#show heading.where(level: 1): it => block(
  fill: rgb("#1a1a1a"),
  inset: (x: 5pt, y: 3pt),
  width: 100%,
  radius: 2pt,
  above: 6pt,
  below: 4pt,
  text(white, weight: "bold", size: 10.5pt, it.body),
)

#show heading.where(level: 2): it => block(
  fill: rgb("#cccccc"),
  inset: (x: 4pt, y: 2pt),
  width: 100%,
  radius: 1pt,
  above: 5pt,
  below: 2pt,
  text(weight: "bold", size: 8.8pt, it.body),
)

#show heading.where(level: 3): it => block(
  above: 4pt,
  below: 1pt,
  text(weight: "bold", size: 8pt, fill: rgb("#1a1a1a"), it.body),
)

// ------- Table style -------
#set table(
  inset: 2.5pt,
  stroke: 0.4pt + rgb("#888"),
)

// ------- Helpers -------
#let formula(body) = block(
  fill: rgb("#f5f5f5"),
  inset: 4pt,
  radius: 2pt,
  width: 100%,
  stroke: 0.5pt + rgb("#555555"),
  body
)

#let trap(body) = block(
  fill: rgb("#e8e8e8"),
  inset: 3pt,
  radius: 2pt,
  width: 100%,
  stroke: 1pt + rgb("#111111"),
  text(size: 7.5pt)[#text(weight: "bold", fill: rgb("#111111"))[⚠ TRAP: ] #body]
)

#let tip(body) = block(
  fill: white,
  inset: 3pt,
  radius: 2pt,
  width: 100%,
  stroke: 0.5pt + rgb("#444444"),
  text(size: 7.5pt)[#text(weight: "bold", fill: rgb("#444444"))[✓ ] #body]
)

// ------- Title -------
#align(center)[
  #text(size: 14pt, weight: "bold", fill: rgb("#1a1a1a"))[
    Computer Engineering 2 — Zwischenprüfung Cheatsheet
  ]
  #v(-3pt)
  #text(size: 8pt, style: "italic", fill: gray)[
    STM32F429ZI · ZHAW InES · Open-Book Reference
  ]
]
#v(-6pt)
#line(length: 100%, stroke: 1pt + rgb("#1a1a1a"))

// ===== Begin two-column body =====
#show: rest => columns(2, gutter: 10pt, rest)

// ============================================================
= 1. Microcontroller Basics
// ============================================================

== System Bus

CPU = *master*; memory & peripherals = *slaves*. Bus has *3 signal groups*:

#table(
  columns: (auto, 1fr),
  [*Address*], [Master → Slave, unidirectional. $n$ lines → $2^n$ addresses],
  [*Data*], [Bidirectional, 8/16/32/64 bits wide],
  [*Control*], [NWE (write), NOE (read), NEx (chip select), NBLx (byte lanes)],
)

#trap[System bus = address + data + control. *Not* "data + control only" — many T/F questions phrase it this way.]

== Sync vs Async Bus

#table(
  columns: (auto, 1fr),
  [*Sync*], [Master & slave share a clock (on-chip, DDR)],
  [*Async*], [No shared clock; control signals carry timing (off-chip flash, async SRAM)],
)

In sync transfer, slave uses master's clock. In async, slave generates own clock.

== Memory Map (STM32F4)

#table(
  columns: (auto, 1fr),
  [`0x0000'0000`], [Boot alias of Flash],
  [`0x0800'0000`], [Flash (2 MB)],
  [`0x1000'0000`], [CCM RAM (64 KB, CPU only)],
  [`0x2000'0000`], [SRAM (192 KB total)],
  [`0x4000'0000`], [ST peripherals (GPIO, SPI, ADC...)],
  [`0x6000'0000`], [FMC ext. (CT board I/O)],
  [`0xA000'0000`], [FMC config registers],
  [`0xE000'0000`], [Cortex-M peripherals (NVIC...)],
)

Peripheral registers spaced *4 bytes* apart. Address = base + offset.

== Bus Hierarchies (STM32F4)

- *AHB* (high-perf): AHB1/AHB2 @ 84 MHz
- *APB1* (slow): @ 42 MHz
- *APB2* (fast): @ 84 MHz
- HCLK on CT-Board: *84 MHz*

== Wait States

For slow slaves, insert TW cycles between T1–T4. Two methods:
+ Programmed at bus interface (per address range)
+ Ready signal asserted by slave

== Control & Status Registers

- *Control bits* — CPU writes → HW reacts
- *Status bits* — HW writes → CPU reads
- A single register *can mix both*

== `volatile` in C

Forces compiler to honor every read/write (HW or ISR may change value).

```c
#define REG (*(volatile uint8_t*)(0x4F00C000))
while ((REG & (1 << 4)) == 0) { } // poll bit 4

// 16-bit version
#define R16 (*(volatile uint16_t*)(0x63008000))
while ((R16 & (1 << 5)) == 0) { }
```

// ============================================================
= 2. Address Decoding
// ============================================================

== Full vs Partial

- *Full*: all lines decoded → 1:1 mapping (e.g. `0x4000'8234` only)
- *Partial*: subset decoded → n:1 aliasing (e.g. `0x4000'82xx` all map to same reg)

== XOR Trick (exam recipe)

Given the addresses that select a peripheral, *XOR them all together*. Bits that come out as `1` are *ignored* lines (not decoded). Count = number of ignored lines.

#formula[
  Example: addresses `0x6D, 0x7F, 0x6F, 0x7D`
  
  `0110 1101 ⊕ 0111 1111 ⊕ 0110 1111 ⊕ 0111 1101`
  
  = `0001 0010` → bits *1* and *4* ignored (2 lines)
]

#tip[Past exam patterns: 2-bit ignored on FS23/FS24, 6-bit ignored on FS22 (only 2 of 8 decoded).]

// ============================================================
= 3. Bus Access — Little Endian
// ============================================================

STM32 is *little-endian*: lowest-order byte at lowest address.

#formula[
  Word `0x08003A99` written at address `0x...40`:
  #table(columns: (auto, auto),
    [`...40`], [`0x99`], 
    [`...41`], [`0x3A`],
    [`...42`], [`0x00`],
    [`...43`], [`0x08`],
  )
]

== Access Sizes (STR family)

#table(
  columns: 3,
  table.header([*Instr*], [*Size*], [*NBL active*]),
  [`STR`], [Word (32-bit)], [4 (all)],
  [`STRH`], [Half-word (16-bit)], [2],
  [`STRB`], [Byte (8-bit)], [1],
)

#trap[On 32-bit system bus, half-word write → exactly *2* NBL signals active. Byte write → exactly 1.]

// ============================================================
= 4. GPIO — STM32F4xx
// ============================================================

== Base Addresses

#table(
  columns: 4,
  [GPIOA], [`0x4002'0000`], [GPIOB], [`0x4002'0400`],
  [GPIOC], [`0x4002'0800`], [GPIOD], [`0x4002'0C00`],
  [GPIOE], [`0x4002'1000`], [GPIOF], [`0x4002'1400`],
  [GPIOG], [`0x4002'1800`], [GPIOH], [`0x4002'1C00`],
  [GPIOI], [`0x4002'2000`], [GPIOJ], [`0x4002'2400`],
  [GPIOK], [`0x4002'2800`],[],[],
)

#tip[Each port = base + n × `0x400`. Port letter to number: A=0, B=1, ...]

== Register Map

#table(
  columns: (auto, auto, 1fr),
  table.header([*Off*], [*Name*], [*Use*]),
  [`0x00`], [MODER], [Direction (2 bits/pin)],
  [`0x04`], [OTYPER], [Output type (1 bit/pin)],
  [`0x08`], [OSPEEDR], [Speed (2 bits/pin)],
  [`0x0C`], [PUPDR], [Pull-up/down (2 bits/pin)],
  [`0x10`], [IDR], [Input data (read-only)],
  [`0x14`], [ODR], [Output data],
  [`0x18`], [BSRR], [Atomic set/reset],
  [`0x20`], [AFRL], [AltFn pins 0–7],
  [`0x24`], [AFRH], [AltFn pins 8–15],
)

== Bit Encoding

#table(
  columns: (auto, 1fr),
  table.header([*MODER*], [Direction]),
  [`00`], [Input],
  [`01`], [General-purpose Output],
  [`10`], [Alternate Function],
  [`11`], [Analog],
)

#table(
  columns: (auto, 1fr),
  table.header([*OTYPER*], [Output type]),
  [`0`], [Push-pull (drives both H & L)],
  [`1`], [Open-drain (drives L only, needs pull-up)],
)

#table(
  columns: (auto, 1fr),
  table.header([*PUPDR*], [Pull resistor]),
  [`00`], [None (floating)],
  [`01`], [Pull-up],
  [`10`], [Pull-down],
)

#table(
  columns: (auto, 1fr),
  table.header([*OSPEEDR*], [Slew rate]),
  [`00`], [Low], [`01`], [Medium], [`10`], [High], [`11`], [Very high],
)

== Bit Position Recipe (THE 8-pt question)

For pin `n`:

#formula[
  *2-bit register* (MODER, OSPEEDR, PUPDR): bits `[2n+1 : 2n]`, shift = `2*n`
  
  *1-bit register* (OTYPER): bit `[n]`, shift = `n`
]

=== Worked example: Port F.14, fast/high speed, output, push-pull, no pull

Base GPIOF = `0x4002'1400`. Pin 14 → 2-bit shift = `28`, 1-bit shift = `14`.

#table(
  columns: 4,
  table.header([*Reg*], [*Addr*], [*Mask*], [*Shift*]),
  [MODER], [`0x40021400`], [`01`], [`<<28`],
  [OTYPER], [`0x40021404`], [`0`], [`<<14`],
  [OSPEEDR], [`0x40021408`], [`10`], [`<<28`],
  [PUPDR], [`0x4002140C`], [`00`], [`<<28`],
)

== Push-pull vs Open-drain

#table(columns: (auto, 1fr),
  [*PP*], [P-MOS + N-MOS active. Drives H *and* L. Bad for shared bus (short-circuit risk).],
  [*OD*], [N-MOS only. Drives L; H = floating. Needs pull-up. Used for I²C (multi-master).],
)

#trap[T/F: "PP can drive H, L, *or floating*" → FALSE. Only OD floats.]

== BSRR — atomic set/reset

- Bits `[15:0]`: write `1` to *set* pin
- Bits `[31:16]`: write `1` to *reset* pin
- Single write, no read-modify-write race

== Reading inputs

`GPIOx_IDR` (read-only). Push-pull driver overrides input value at the pin.

#table(
  columns: (auto, auto, auto, auto),
  table.header([*Driver*], [*Pull on input*], [*Output 0*], [*Output Z*]),
  [PP], [none], [reads 0], [undefined],
  [PP], [pull-up], [reads 0], [reads 1],
  [PP], [pull-down], [reads 0], [reads 0],
)

// ============================================================
= 5. Timer / Counter / PWM
// ============================================================

== The Three Formulas

#formula[
  $f_"tick" = f_"src" / ("PSC" + 1)$
  
  $T_"period" = ("ARR" + 1) / f_"tick"$
  
  Duty $= ("CCR") / ("ARR" + 1)$ #h(1em) (or `(CCR+1)/(ARR+1)` for downcounter exam variant)
]

#trap[*The −1 trap*: ARR & PSC values are *one less* than the divisor. PSC=21 means divide by 22? *NO*, PSC field value 21 → divisor 22, but the lecture treats "Prescaler teilt durch 21" → write `21−1 = 20` into PSCR if "teilt durch" means divisor. Read carefully: if exam says "Prescaler teilt durch 21", divisor is 21 → in formula use `f_src / 21`. The −1 only applies when *writing the register*.]

== Worked example (FS22, Q4)

32-bit timer, $f_"src" = 84$ MHz, prescaler ÷21, want 47 ms interrupt period.

#formula[
  $f_"tick" = 84"MHz" / 21 = 4"MHz"$
  
  Ticks = $4"MHz" times 0.047"s" = 188000$
  
  ARR = $188000 - 1 = 187999$
]

== PWM example (FS22, Q8)

16-bit downcounter, 35 MHz src, ÷70, period 96 ms, duty 6/8.

#formula[
  $f_"tick" = 35"MHz"/70 = 500"kHz"$, tick = 2 µs
  
  ARR = $96"ms" / 2"µs" = 48000$
  
  CCR = $6/8 times 48000 = 36000$
]

== Choosing PSC for max ARR (FS23, Q10)

16-bit ARR (max $2^16 = 65536$), 40 MHz, want 20 ms period.

#formula[
  $T_"max with PSC=1" = 65536 / 40"MHz" = 1.638"ms" arrow.r$ too short
  
  Need PSC ≥ $20"ms" / 1.638"ms" approx 12.2 arrow.r$ next int = *13* (or 16 if "next pow-of-2")
]

== Up-counter vs Down-counter PWM (IMPORTANT)

#table(columns: (auto, 1fr),
  table.header([*Mode*], [*Output behavior*]),
  [Up-counter], [Output HIGH while counter < CCR; LOW when counter ≥ CCR],
  [Down-counter], [Output LOW while counter = 0 (reset), HIGH when counter > CCR],
)

#formula[
  *Up-counter*: Duty $= "CCR" / ("ARR" + 1)$

  *Down-counter*: signal is high for counts CCR..ARR, low for 0..CCR-1 \
  → Duty $= ("ARR" - "CCR" + 1) / ("ARR" + 1)$ or per exam: $"CCR" / "ARR"$ — *read carefully*
]

#trap[CCR −1 trap: some exam variants use CCR as the tick count (no −1), others define it differently for downcounters. FS23 Q12 downcounter gives CCR = 36000−1 = 35999; FS24 Q12 gives CCR = 30000 as-is. Read the definition in the question.]

== Up-counter example (FS23, Q11)

Up-counter, $f_"tick" = 100$ kHz, period 600 ms, duty 80%.

#formula[
  Tick = $1/100"kHz" = 10"µs"$

  Ticks = $600"ms" / 10"µs" = 60000$

  ARR = $60000 - 1 = 59999$

  CCR = $0.8 times 60000 - 1 = 47999$
]

== PWM Reverse (FS24, Q12)

Given PSC=99, ARR=39999, CCR=30000, $f_"src"$=50 MHz:
- $f_"tick" = 50"MHz"/100 = 500"kHz"$ → tick 2 µs
- $T = 40000 times 2"µs" = 80"ms"$
- Duty $= 30000/40000 = 75%$

// ============================================================
= 6. ADC (STM32F429)
// ============================================================

== Core formulas

#formula[
  $1 "LSB" = V_"REF" / 2^N$

  $V_"in" = "digital" times V_"REF" / 2^N$

  *FSR* (Full Scale Range) $= V_"REF" - 1"LSB" = V_"REF" times (2^N - 1) / 2^N$

  Max digital output code = $2^N - 1$ (not $2^N$)

  $T_"total" = T_"sample" + T_"conv"$ \[ADC clocks\]

  $f_"ADCCLK" = f_"APB2" / "prescaler"$ (÷2/4/6/8)
]

== Conversion times by resolution

#table(columns: 4,
  table.header([12-bit], [10-bit], [8-bit], [6-bit]),
  [12 cyc], [10 cyc], [8 cyc], [6 cyc],
)

Sample times (SMPx): 3, 15, 28, 56, 84, 112, 144, 480 cycles.

== Data Register Addresses (memorize!)

ADC base = `0x4001'2000`. Data register at offset `0x4C`.

#table(
  columns: 2,
  table.header([*ADC*], [*ADC_DR address*]),
  [ADC1], [`0x4001'204C`],
  [ADC2], [`0x4001'214C`],
  [ADC3], [`0x4001'224C`],
)

#tip[Each ADC offset is `0x100` apart. Common regs at `0x300+`.]

== Offset Error Voltage (recurring question)

#formula[
  Step 1: $1 "LSB" = V_"REF" / 2^N$
  
  Step 2: $V_"offset" = "offset"_"LSB" times 1 "LSB"$
]

Examples from past exams:
- $V_"REF"=3"V"$, 10-bit: 1 LSB ≈ 2.93 mV. +4 LSB → *11.7 mV* (FS24)
- $V_"REF"=3"V"$, 8-bit: 1 LSB ≈ 11.7 mV. +2 LSB → *23.4 mV* (FS23)
- $V_"REF"=3"V"$, 10-bit: 1 LSB ≈ 2.93 mV. +2 LSB → *5.86 mV* (FS22)

== Resolution from desired LSB (FS24, Q13)

$V_"REF"=4$V, want LSB ≈ 64 mV → $4/64 = 0.0625$ → $2^N = 64$ → *N = 6 bits*.

== Error Types

- *Quantization*: ±0.5 LSB inherent
- *Offset (zero-scale)*: shift at input 0
- *Gain*: slope mismatch
- *Full-scale = offset + gain*

== Conversion modes

#table(columns: 3,
  table.header([], [*Single ch*], [*Multi ch (scan)*]),
  [Single], [1 conv, stop], [seq, then stop],
  [Cont.], [1 ch repeating], [seq repeating],
)

== Key Control Bits

- `ADON` (CR2): ADC on
- `SWSTART` (CR2 bit 30): start conv
- `EOC` (SR bit 1): end-of-conv. *Cleared by reading DR*.
- `RES[1:0]` (CR1): 00=12b, 01=10b, 10=8b, 11=6b
- `SCAN` (CR1): scan multiple channels
- `CONT` (CR2): continuous mode

// ============================================================
= 7. DAC (STM32F429)
// ============================================================

== Output formula

#formula[
  $V_"out" = V_"REF+" times "DOR" / 4095$ #h(1em) (12-bit)
]

- 2 channels, 12-bit (also 8-bit), L/R align
- Trigger: SW, TIM2/4/5/6/7/8, EXTI_9
- Settling time: typ 3 µs, max 6 µs (full-scale)
- DAC base: `0x4000'7400`

== Channel pins (auto-connected when EN=1)

CH1 → PA4, CH2 → PA5. *Configure as analog (MODER=11) first* to avoid parasitic current.

// ============================================================
= 8. Memory Technologies
// ============================================================

== Big classification

*Non-volatile*: PROM, EEPROM, Flash (NOR/NAND), NV-RAM \
*Volatile*: SRAM, SDRAM (SDR/DDR)

== Address ↔ size

#formula[
  $n$ address lines (each addr = 1 byte) → $2^n$ bytes
  
  20 lines → 1 MiB = *1024 kBytes* \
  22 lines → 4 MiB = *4096 kBytes*
]

== Units

KiB = 1024 B, MiB = 1024², GiB = 1024³ (chips). \
HDDs/SSDs often use SI: kB = 1000.

== SRAM vs SDRAM (cell-recognition)

#table(columns: (1fr, 1fr),
  table.header([*SRAM*], [*SDRAM*]),
  [Flip-flop (4T + 2R), two complementary bit lines b/!b], [1 transistor + 1 capacitor],
  [No refresh], [*Periodic refresh* (leakage)],
  [Async, ~5 ns uniform], [Sync, latency + burst],
  [Low density, expensive], [High density, cheap],
)

#tip[Exam shows a transistor schematic — pick *SRAM* if there are two cross-coupled inverters, *SDRAM* if you see a single transistor + capacitor.]

== Flash — write/erase rules

- Program *can only flip 1 → 0* (looks like AND with old value)
- Erase resets all to *1* (sector-level only)
- Endurance: ~10000 erase cycles

#formula[
  Old `0xC3`, no erase, program `0xF3` → result `0xC3` ($"AND"="0xC3"$) \
  Old `0xC3`, erase, program `0xF3` → result `0xF3`
]

== NOR vs NAND

#table(columns: (auto, 1fr, 1fr),
  table.header([], [*NOR*], [*NAND*]),
  [Use], [eXecute-in-Place; config], [SD/SSD; bulk data],
  [Density], [≤ 256 MB], [≤ 128 GB],
  [Read], [random, ~0.12 µs], [block; first byte 25 µs],
  [Iface], [SRAM-like / SPI], [special, w/ ECC],
)

== STM32F429 SRAM Regions

#table(columns: (auto, auto, 1fr),
  [SRAM1], [112 KB], [`0x2000'0000` – `0x2001'BFFF`],
  [SRAM2], [16 KB], [`0x2001'C000` – `0x2001'FFFF`],
  [SRAM3], [64 KB], [`0x2002'0000` – `0x2002'FFFF`],
  [CCM], [64 KB], [`0x1000'0000` – `0x1000'FFFF`],
)

== STM32F429 Flash sectors

- Bank 1: sect 0–3 (4×16 KB), sect 4 (64 KB), sect 5–11 (7×128 KB)
- Bank 2: sect 12–15 (4×16 KB), sect 16 (64 KB), sect 17–23 (7×128 KB)
- Erase 128 KB sector: 1–2 s. Cannot read/write that sector during erase.

// ============================================================
= 9. FMC — External Memory
// ============================================================

== Address space

External memory: `0x6000'0000` – `0xDFFF'FFFF`

#table(columns: (auto, 1fr),
  [`0x60..0x6F`], [Bank 1: SRAM/NOR/PSRAM (4×64 MB)],
  [`0x70..0x7F`], [Bank 2: NAND],
  [`0x80..0x9F`], [Banks 3–4: PC Card],
  [`0xC0..0xCF`], [SDRAM Bank 1],
  [`0xD0..0xDF`], [SDRAM Bank 2],
)

Within Bank 1: bits `[27:26]` select NE1–NE4.

== Width Mismatch — extra cycles

Internal bus is 32-bit. If external bus is narrower:

#table(columns: (auto, 1fr, 1fr),
  table.header([*Ext*], [*Write 1 word*], [*Read 1 word*]),
  [32-bit], [1 cyc], [1 cyc],
  [16-bit], [2 cyc (no wait)], [2 cyc (CPU waits)],
  [8-bit], [4 cyc (no wait)], [4 cyc (CPU waits)],
)

#tip[*Writes use FIFO*: CPU is freed immediately. *Reads block CPU* until all bytes arrive.]

== FS22 Q10 example (16-bit ext bus, 8-bit memory)

#table(columns: (auto, auto, auto),
  table.header([*Access*], [*Bus accesses*], [*CPU waits?*]),
  [Write 8-bit], [2], [No],
  [Read 16-bit], [3], [Yes],
  [Write 32-bit], [5], [No],
  [Read 32-bit], [5], [Yes],
)

(Counts include the address phase + each data transfer.)

== FMC Bank & Device Selection (bits [31:26])

#image("images/Pasted image 20260421174421.png", width: 100%)

Bits *[31:26]* of internal address select bank/device (NOE/NWE for flash/SRAM, NE1–NE4 from bits *[27:26]* within Bank 1). Lower bits [25:0] are the actual memory address sent to the device.

== Address shift by width

- 8-bit ext: ext A[25:0] = int A[25:0]
- 16-bit ext: ext A[24:0] = int A[25:1], NBL[1:0] from A[0]
- 32-bit ext: ext A[23:0] = int A[25:2], NBL[3:0] from A[1:0]

== FMC Config

Registers at `0xA000'0000`–`0xA000'0FFF`.
- `MWID[1:0]` (BCRx): 00=8b, 01=16b, 10=32b
- `ADDSET[3:0]` (BTRx): 1–15 HCLK
- `DATAST[7:0]` (BTRx): 1–255 HCLK

// ============================================================
= 10. SPI — Serial Peripheral Interface
// ============================================================

== Signals (4-wire)

#table(columns: (auto, 1fr),
  [SCLK], [Master → Slave (master generates)],
  [MOSI], [Master Out, Slave In],
  [MISO], [Master In, Slave Out],
  [SS̄], [Slave select, active *low*; *one per slave*],
)

*Sync, full-duplex, no addressing, no ACK/NACK.*

== Modes (CPOL, CPHA)

#table(columns: 3,
  table.header([*Mode*], [*CPOL*], [*CPHA*]),
  [0], [0 (idle L)], [0 (sample 1st edge)],
  [1], [0 (idle L)], [1 (sample 2nd edge)],
  [2], [1 (idle H)], [0],
  [3], [1 (idle H)], [1],
)

#formula[
  *CPOL* = SCLK idle level \
  *CPHA=0*: data toggled on *leading* edge, sampled on *trailing* edge \
  *CPHA=1*: toggled on *trailing*, sampled on *leading*
]

#image("images/Pasted image 20260421110650.png", width: 100%)

== Reading SPI Timing Diagrams

For *CPOL=1, CPHA=0, MSB first*: SCLK starts H, drops on first edge → that's the sample edge → MSB must be valid before first falling edge.

#trap[Always check *MSB-first* vs *LSB-first*. FS23 had `0x59` MSB-first → "no diagram" was correct because all shown were LSB-first.]

== STM32 SPI Registers

#table(columns: 3,
  table.header([*Off*], [*Reg*], [*Use*]),
  [`0x00`], [SPI_CR1], [CPOL, CPHA, MSTR, BR, SPE, LSBFIRST, DFF],
  [`0x04`], [SPI_CR2], [Interrupt enables],
  [`0x08`], [SPI_SR], [TXE, RXNE, BSY],
  [`0x0C`], [SPI_DR], [TX/RX data],
)

== Status flags

- *TXE* = TX buffer empty → safe to write next byte
- *RXNE* = RX buffer not empty → byte arrived
- *BSY* = transmission in progress

== Send byte recipe

```
write SPI_DR
wait TXE=1
write next SPI_DR ...
wait TXE=1 AND BSY=0  // last byte done
```

== Bases

`SPI1=0x40013000`, `SPI2=0x40003800`, `SPI3=0x40003C00`, `SPI4=0x40013400`, `SPI5=0x40015000`, `SPI6=0x40015400`

== Common T/F (SPI)

#table(columns: (1fr, auto),
  [MOSI: master sends to slave], [✓],
  [MISO: slave sends to master], [✓],
  [SPI uses 7-bit addressing], [✗],
  [SPI = "2-wire bus"], [✗ (it's 4-wire)],
  [Sync transmission], [✓],
  [Sync bits required], [✗ (no, that's UART)],
  [Onboard connections], [✓],
  [Separate clock line], [✓],
)

// ============================================================
= 11. UART
// ============================================================

== Frame format

```
[idle=H] [START=L] [D0 D1 ... D7] [par?] [STOP=H ...]
                    LSB first
```

- 5–8 data bits, LSB first
- Optional parity (none/even/odd/mark/space)
- 1, 1.5, or 2 stop bits

== Sampling

Receiver re-syncs on falling edge of START, then samples each bit *in the middle* (1.5 × bit period after start edge).

== Baud / byte rate

#formula[
  $T_"bit" = 1 / "baud"$
  
  bits/frame = 1 (start) + N (data) + parity + stop_bits
  
  byte rate = baud / (bits/frame)
]

== Examples (FS24)

8 data, 1 stop, even parity, 9600 baud:
- 1+8+1+1 = 11 bits/frame → 9600/11 = *872 B/s*
- Sync overhead = 3/8 = *37.5%* (start + parity + stop = 3 sync bits per 8 data bits)

8 data, 2 stop, odd parity, 14400 baud:
- 1+8+1+2 = 12 bits/frame → 14400/12 = *1200 B/s*
- Overhead = 4/8 = *50%*

== Decoding bit numbers in a stream

Number bits 0..N from start. Bit 0 = start. Then 1..8 = data (LSB at bit 1). Then parity, then stop. *Watch which bit number maps to parity vs stop*.

E.g. 8 data + parity + 1 stop, "Bit 14 = parity"? Bits 1–13 = ? actually 1+8+parity = bit positions 0(start), 1–8 (data), 9 (parity), 10 (stop). So bit number 14 only fits if we're in a *second* frame.

== USART Registers (STM32)

#table(columns: 3,
  table.header([*Off*], [*Reg*], [*Use*]),
  [`0x00`], [SR], [TXE, TC, RXNE],
  [`0x04`], [DR], [TX/RX data],
  [`0x08`], [BRR], [Baud rate],
  [`0x0C`], [CR1], [UE, TE, RE, M (8/9 bit)],
  [`0x10`], [CR2], [STOP bits],
  [`0x14`], [CR3], [],
)

Bases: `USART1=0x40011000`, `USART2=0x40004400`, `USART3=0x40004800`, `UART4=0x40004C00`, `UART5=0x40005000`, `USART6=0x40011400`.

== Long-distance standards

- *RS-232*: single-ended, point-to-point, ~10 m
- *RS-485*: differential, half-duplex, multi-point, 100+ m

// ============================================================
= 12. I²C
// ============================================================

== Lines & basics

- *SCL* (clock) + *SDA* (data), both *open-drain* with pull-ups
- Sync, half-duplex
- 7-bit addresses (10-bit optional)
- 8-bit data, *MSB first*, ACK after each byte
- Bit rates up to 5 Mbit/s

== Start / Stop conditions

#formula[
  *START*: SDA falling edge *while SCL is HIGH* \
  *STOP*: SDA rising edge *while SCL is HIGH*
]

Rule: *SDA may only change while SCL is LOW* (otherwise it's S or P).

== Address byte format (after START)

```
[A6][A5][A4][A3][A2][A1][A0][R/W̄]
        7-bit address       0=write, 1=read
```

== Decoding example (FS22 Q1)

Byte `1010'0011`:
- Address bits = `1010001` = `0x51`
- R/W = 1 → *read*
- Range answer: `0x40 ≤ addr < 0x60` (because top 3 bits `101` → `0xA0` shifted... actually conventional: `0x51` lies in `0x40..0x5F` if you only check 6 MSB)

#tip[Past exams accept either the exact 7-bit value (`0x51`) or a range (`0x40 ≤ addr < 0x60`).]

== ACK / NACK

ACK: receiver pulls SDA *low* on bit-9 clock. NACK: leaves SDA high.

5 reasons for NACK:
+ No device at that address
+ Receiver busy
+ Command not understood
+ Receiver full
+ Master signals end-of-read

== I²C Registers (STM32)

#table(columns: 3,
  table.header([*Off*], [*Reg*], [*Use*]),
  [`0x00`], [CR1], [PE, START, STOP, ACK, SWRST],
  [`0x04`], [CR2], [],
  [`0x10`], [DR], [TX/RX],
  [`0x14`], [SR1], [SB, ADDR, BTF, TxE, RxNE, AF],
  [`0x18`], [SR2], [MSL, BUSY, TRA],
)

Bases: `I2C1=0x40005400`, `I2C2=0x40005800`, `I2C3=0x40005C00`.

// ============================================================
= 13. Comparison Table — UART / SPI / I²C
// ============================================================

#table(
  columns: (auto, 1fr, 1fr, 1fr),
  table.header([], [*UART*], [*SPI*], [*I²C*]),
  [Wires], [TX, RX], [SCLK, MOSI, MISO, SS], [SCL, SDA],
  [Topology], [Point-to-point], [Multi-slave (SS per slave)], [Multi-point],
  [Duplex], [Full], [Full], [Half],
  [Timing], [Async], [Sync], [Sync],
  [Addressing], [—], [SS line], [7/10-bit addr],
  [Error det.], [Parity opt.], [None], [None (ACK only)],
  [Bit order], [LSB first], [Either], [MSB first],
)

// ============================================================
= 14. Common Exam Pitfalls
// ============================================================

== True/False traps that recur

#table(columns: (1fr, auto),
  [Harvard arch = shared bus for instr+data], [F (split)],
  [Async bus = master & slave share clock], [F],
  [Slave reachable on multiple addresses → partial decoding], [T],
  [CPU lowers bus freq for slow peripherals], [F (use wait states)],
  [Async transmission: slave generates own clock], [T],
  [NOE/NWE tell the *CPU* whether slave wants to read/write], [F (CPU drives them)],
  [Half-word write on 32-bit bus → exactly 2 NBL active], [T],
  [Sync transfer: slave uses master's clock], [T],
  [System bus = data + control only], [F (missing address!)],
  [CPU configures slaves via *control* bits], [T],
  [CPU configures slaves via *status* bits], [F],
  [\# data lines determines addressable size], [F (it's address lines)],
  [\# address lines determines address space], [T],
  [Wait states for slow peripherals], [T],
  [`volatile` warns compiler of external change], [T],
  [Each slave has own select line on system bus], [F (uses address decoding)],
  [Address lines unidirectional], [T],
  [Register can mix control + status bits], [T],
  [Push-pull suitable for shared bus], [F (short-circuit risk)],
  [Push-pull can drive H, L, *or float*], [F (only H/L)],
  [Push-pull needs pull-up for H], [F (that's open-drain)],
  [SPI = 2-wire bus], [F (4-wire)],
  [SPI uses 7-bit addressing], [F],
  [SPI needs sync bits], [F (clock is wired)],
  [SPI clock on separate line], [T],
  [SPI requires one SS per slave], [T],
)

== Numerical traps

- *−1 in ARR/CCR*: register value vs tick count. Read carefully whether they ask for the *register* or the *count*.
- *Memory units*: 1 KiB = 1024 B (not 1000) for chip questions.
- *Little-endian*: lowest byte at lowest address (not the other way!).
- *Hex address arithmetic*: each port offset is `0x400`, each ADC offset `0x100`.
- *PSC vs divisor*: "Prescaler teilt durch N" → divisor = N → in formula use $f / N$. The value stored in PSC register may be N − 1 (peripheral-dependent).

// ============================================================
= 15. Quick-Lookup Constants
// ============================================================

== Useful base addresses

#table(columns: (auto, 1fr),
  [GPIO base], [`0x4002'0000` (+`0x400` per port)],
  [ADC1 DR], [`0x4001'204C`],
  [ADC2 DR], [`0x4001'214C`],
  [ADC3 DR], [`0x4001'224C`],
  [ADC common], [`0x4001'2300`],
  [DAC base], [`0x4000'7400`],
  [SPI1], [`0x4001'3000`],
  [USART1], [`0x4001'1000`],
  [I2C1], [`0x4000'5400`],
  [TIM2], [`0x4000'0000`],
  [FMC config], [`0xA000'0000`],
)

== Powers of two

#table(
  columns: 4,
  [$2^8$], [256], [$2^16$], [65536],
  [$2^10$], [1024], [$2^20$], [1 048 576],
  [$2^12$], [4096], [$2^22$], [4 194 304],
  [$2^14$], [16384], [$2^32$], [≈4.29 × $10^9$],
)

== ADC LSB pre-computed ($V_"REF" = 3.0$ V)

#table(columns: 3,
  table.header([*Bits*], [*1 LSB*], [*FSR*]),
  [12], [732 µV], [≈3.000 V],
  [10], [2.93 mV], [≈2.997 V],
  [8], [11.7 mV], [≈2.988 V],
  [6], [46.9 mV], [≈2.953 V],
)

== ADC LSB pre-computed ($V_"REF" = 2.5$ V)

#table(columns: 2,
  [12-bit], [610 µV],
  [10-bit], [2.44 mV],
  [8-bit], [9.77 mV],
)

#v(0.5em)
#align(center)[
  #text(size: 7pt, style: "italic", fill: gray)[
    — Made for the CT2 Zwischenprüfung. Read the question twice. Watch the −1. Good luck! —
  ]
]

