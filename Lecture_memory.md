# Memory
**Computer Engineering 2 — ZHAW, School of Engineering, InES Institute of Embedded Systems**

---

## Agenda

1. **Memory Technologies** — PROM, EEPROM and Flash, SRAM, SDRAM
2. **On-Chip Memories STM32F429ZI** — SRAM and Flash
3. **External Memory (Off-Chip)** — Flexible Memory Controller, Connecting Asynchronous SRAM
4. **Appendix** — Trends and Figures

---

## Learning Objectives

At the end of this lesson, you will be able to:

- Classify widely used memory technologies
- Discuss the structure and function of an SRAM (static RAM)
- Discuss the structure and function of flash memory
- Outline the structure and function of an asynchronous SRAM device
- Outline how an external asynchronous SRAM device can be connected to an STM32 through the Flexible Memory Controller (FMC)
- Explain how an internal 32-bit access is partitioned into several external half-word or byte accesses
- Interpret timing diagrams for read and write accesses to external, asynchronous SRAMs
- Summarize the differences between a NOR and a NAND flash
- Summarize the differences between a static RAM (SRAM) and a dynamic RAM (SDRAM)

---

## Memory Technologies

### Classification

Semiconductor memories are divided into two major categories:

**Non-volatile** — holds data even if power is turned off:
- **PROM** (Programmable Read Only Memory): Mask-programmed (factory) or fusible one-time programmable (OTP)
- **EEPROM** (Electrically Erasable PROM): Floating gate technology, random read and write, low density → expensive
- **Flash** (Block-wise EEPROM):
  - **NOR**: Random read access, block-wise erase
  - **NAND**: Block-wise read, block-wise erase
- **NV-RAM** (non-volatile RAM): nvSRAM, FRAM (Ferroelectric RAM)

**Volatile** — loses data when power is turned off:
- **SRAM** (Static Random Access Memory)
- **SDRAM** (Synchronous Dynamic Random Access Memory):
  - SDR (Single Data Rate)
  - DDR (Double Data Rate)

---

### Units

- `b` = bit, `B` = Byte
- Memory chips use **binary prefixes** (JEDEC / IEC):
  - KiB = 1 024 bytes
  - MiB = 1 024 × 1 024 = 1 048 576 bytes
  - GiB = 1 024³ = 1 073 741 824 bytes
  - TiB = 1 024⁴ ≈ 10 % more than the SI tera prefix
- Hard disks often use **SI (metric) prefixes**: k = 1 000, M = 10⁶, G = 10⁹, T = 10¹²

---

### Memory Architecture — Arrays of Bit Cells

- Memory is organized as an **n × m array**: n words, each m bits wide
- Address with k bits selects one of n = 2^k word lines
- Each bit cell stores a '1' or '0'

---

### PROM — Programmable Read Only Memory

- n × m array (e.g. 512 × 4 bit, 9 address lines)
- Uses **fusible transistors**:
  - Word line = '1' → transistor pulls bit line to GND → reads '0'
  - Word line = '0' → transistor open, pull-up → reads '1'
  - Destroyed transistor (blown fuse) → always open → reads '1'
- Programming applies a higher voltage to blow fuses — **not reversible**

---

### EEPROM and Flash Memory

Both use **floating gate transistors** instead of fusible transistors:

- **Write (program) to '0' → ON**: High voltage deposits charge on the floating gate (isolated by SiO₂); transistor conducts when control gate = '1'
- **Erase to '1' → OFF**: Negative voltage discharges floating gate; transistor is off regardless of control gate value

| Feature | EEPROM | Flash |
|---------|--------|-------|
| Erase granularity | Per byte/word | Whole sector only |
| Cell area | High | Small |
| Density | Low | High |
| Cost per bit | High | Low |

#### Flash Write/Erase Characteristics

- **Write (programming)**: Can only change bits from '1' → '0'; to flip '0' → '1', an erase is first required
- Word, half-word, or byte write access supported
- Writing a double word takes ~16 µs (~1 000× slower than SRAM)
- **Erase**: Changes all bits from '0' → '1'; only by sector or by bank (not word-level)
- Erase of a 128 KB sector: 1–2 seconds
- Endurance: 10 000 erase cycles (STM32F429ZI)
- Sector cannot be read or written during an erase operation

---

### Flash — NOR vs NAND

| | NOR Flash | NAND Flash |
|---|---|---|
| **Applications** | Execute code directly from memory; persistent device configurations (EEPROM replacement) | File-based I/O; SD cards, SSDs; large sequential data; programs loaded into RAM before execution |
| **Density** | Medium — up to 2 Gbit = 256 MB | High — up to 1 Tbit = 128 GB |
| **Interface** | Same as asynchronous SRAM; SPI variants available | Special NAND interface; error correction for defective blocks |
| **Random read** | ~0.12 µs | 1st byte 25 µs, then 0.03 µs each |
| **Write** | Individual bytes possible; ~180 µs / 32 B | Individual bytes difficult; fast block write ~300 µs / 2 112 B |

---

### SRAM — Static Random Access Memory

#### Architecture

- n × m array using **flip-flop (latch) based cells**
- Each cell: 4 transistors + 2 resistors, two complementary bit lines b and !b
- Address decoder activates one of n word lines

#### Writing a Row

1. Set bit lines b and !b to (1, 0) or (0, 1)
2. Set the addressed word line to '1'
3. Data is stored in the cells
4. Set word line back to '0'

#### Reading a Row

1. Pre-charge both bit lines b and !b to '1'
2. Briefly set the word line to '1'
3. Cell inverters pull b or !b slightly toward GND
4. Sense amplifier amplifies the small voltage difference

#### Key Properties

- **Read and write**: All accesses take roughly the same time; independent of location and previous access
- **Volatile**: Content retained only while powered
- **Static**: No refresh required (unlike DRAM)

#### Asynchronous Interface (example 8 × 4-bit)

No clock input. Control signals (all active-low):

| Signal | Function |
|--------|----------|
| `CS̄` | Chip Select |
| `OĒ` | Output Enable |
| `W̄E` | Write Enable |

| CS̄ | OĒ | W̄E | I/O | Function |
|----|----|-----|-----|----------|
| L | L | H | DATA OUT | Read Data |
| L | X | L | DATA IN | Write Data |
| L | H | H | HIGH-Z | Outputs Disabled |
| H | X | X | HIGH-Z | Deselected |

---

### SDRAM — Synchronous Dynamic RAM

- Data stored as **charge in a capacitor** (one transistor + one capacitor per cell)
- High integration → large memories at low cost
- Leakage current causes charge loss → must be **refreshed periodically** (refresh logic usually on-chip)

#### Structure

- Row and column addresses are **multiplexed** on shared address lines
- RAS̄ (Row Address Strobe) latches the row address; CÃS (Column Address Strobe) latches the column address
- Internal row buffer acts as a cache

#### Access Pattern

- **Long latency** for the first data item in a row
- **Short access time** for subsequent items in the same row (burst)
- Clock up to 1 200 MHz

---

### SRAM vs SDRAM

| | SRAM | SDRAM |
|---|---|---|
| Storage element | Flip-flop/latch (4T + 2R) | Transistor + capacitor |
| Cell size | Large | Small |
| Density | Up to 64 Mb/device | Up to 4 Gb/device |
| Cost | High | Low |
| Refresh | Not required | Required (periodic) |
| Interface | Asynchronous (no clock) | Synchronous (clocked, needs controller) |
| Access time | ~5 ns (uniform, 200 MHz) | Long first-access latency; fast for bursts |
| Best for | Distributed / random accesses | Large block transfers |

---

## On-Chip Memories — STM32F429ZI

The STM32F429ZI microcontroller contains:

- **CPU** Cortex-M4 with NVIC
- **On-chip memory**: Flash and SRAM
- **Flexible Memory Controller (FMC)** for connecting external memories
- **On-chip I/O peripherals**: GPIO, Timer, UART, ADC, …
- **System bus**: 32 data lines, 32 address lines, control signals

### SRAM Address Regions

| Region | Size | Address Range |
|--------|------|---------------|
| SRAM1 | 112 KB | 0x2000'0000 – 0x2001'BFFF |
| SRAM2 | 16 KB | 0x2001'C000 – 0x2001'FFFF |
| SRAM3 | 64 KB | 0x2002'0000 – 0x2002'FFFF |
| CCM RAM | 64 KB | 0x1000'0000 – 0x1000'FFFF |

> **CCM (Core Coupled Memory)**: Fast memory exclusively addressable by the CPU.

### Flash

- **Non-volatile** NOR topology — retains content after power off
- Used to store code and persistent data
- Located at 0x0800'0000 – 0x081F'FFFF (2 MB total, aliased at 0x0000'0000)
- Partitioned into **sectors** (can only be erased as a whole); written via control registers (no direct write access)
- Read requires up to **8 wait states**; mitigated by a 128-bit pre-fetch buffer

#### Flash Sector Map (STM32F429ZI)

| Bank | Sector | Address Range | Size |
|------|--------|---------------|------|
| 1 | 0–3 | 0x0800'0000 – 0x0800'FFFF | 4 × 16 KB |
| 1 | 4 | 0x0801'0000 – 0x0801'FFFF | 64 KB |
| 1 | 5–11 | 0x0802'0000 – 0x080F'FFFF | 7 × 128 KB |
| 2 | 12–15 | 0x0810'0000 – 0x0810'FFFF | 4 × 16 KB |
| 2 | 16 | 0x0811'0000 – 0x0811'FFFF | 64 KB |
| 2 | 17–23 | 0x0812'0000 – 0x081F'FFFF | 7 × 128 KB |

---

## External Memory (Off-Chip)

External memory occupies address range **0x6000'0000 – 0xDFFF'FFFF**.

Supported types: SRAM, NOR flash, PSRAM, NAND flash, PC card, SDRAM.

### Flexible Memory Controller (FMC)

The FMC is a **configurable bus bridge**:
- Slave on the internal 32-bit system bus
- Master on the external bus (8, 16, or 32 data lines depending on device)

#### FMC Signals

| Signal | Direction | Function |
|--------|-----------|----------|
| A[25:0] | OUT | Address bus |
| D[31:0] | INOUT | Bidirectional data bus |
| NE[4:1] | OUT | Four chip-enable lines (active-low) |
| NOE | OUT | Output enable (active-low) |
| NWE | OUT | Write enable (active-low) |
| NBL[3:0] | OUT | Byte lane enables |

#### FMC Memory Banks

| Address Range | Bank | Memory Type |
|---------------|------|-------------|
| 0x6000'0000 – 0x6FFF'FFFF | Bank 1 (4 × 64 MB) | SRAM / NOR / PSRAM |
| 0x7000'0000 – 0x7FFF'FFFF | Bank 2 (4 × 64 MB) | NAND Flash |
| 0x8000'0000 – 0x9FFF'FFFF | Banks 3–4 | PC Card |
| 0xC000'0000 – 0xCFFF'FFFF | SDRAM Bank 1 | SDRAM |
| 0xD000'0000 – 0xDFFF'FFFF | SDRAM Bank 2 | SDRAM |

Within Bank 1, address bits A[27:26] select the device (NE1–NE4), each covering 64 MB.

---

### FMC Address Decoding

Internal address bits [31:28] determine the memory type; bits [27:26] select one of four devices within a bank. The remaining bits become the external address lines.

The shift in external address lines depends on the data bus width:
- **8-bit bus**: External A[25:0] ← Internal A[25:0]
- **16-bit bus**: External A[24:0] ← Internal A[25:1] ; A[0] → NBL[1:0]
- **32-bit bus**: External A[23:0] ← Internal A[25:2] ; A[1:0] → NBL[3:0]

#### Example: Address 0x64028F21 on a 16-bit External Bus

- **Memory type**: External SRAM (bits 31:28 = 0110)
- **Device**: NE2 (bits 27:26 = 01)
- **External address**: 0x001'4790
- **NBL**: NBL[0]=1, NBL[1]=0 → selects high byte

---

### Transfer Times

A mismatch between the internal 32-bit bus and a narrower external bus causes extra cycles:

| External bus width | Write (1 word) | Read (1 word) |
|--------------------|----------------|---------------|
| 32-bit | 1 external cycle | 1 external cycle |
| 16-bit | 2 external cycles (hword × 2) | 2 external cycles (blocks system bus) |
| 8-bit | 4 external cycles (byte × 4) | 4 external cycles (blocks system bus) |

For **writes**, the word is stored in the FMC FIFO first, freeing the system bus immediately. For **reads**, the system bus must wait until all data is available.

---

### FMC Configuration

FMC control registers are located at **0xA000'0000 – 0xA000'0FFF**.

Key configuration parameters:

| Register | Field | Description |
|----------|-------|-------------|
| FMC_BCRx | MWID [1:0] | Data bus width: 00=8-bit, 01=16-bit, 10=32-bit |
| FMC_BTRx | ADDSET [3:0] | Address setup time (1–15 HCLK cycles) |
| FMC_BTRx | DATAST [7:0] | Data phase duration (1–255 HCLK cycles) |

- **ADDSET** and **DATAST** adapt the STM32F4 to the speed of the external memory device
- The CT-Board HCLK is set to **84 MHz** at startup

---

## Conclusions

| Memory | Key Characteristics |
|--------|-------------------|
| **PROM** | Programmed via fuses/masks; factory or one-time user programmable; irreversible |
| **EEPROM** | Floating gate; random read & write; low density → expensive |
| **Flash (NOR)** | Random read → direct code execution; medium density; block erase |
| **Flash (NAND)** | High density; block-wise access; SD cards, SSDs |
| **SRAM** | Flip-flop based; no refresh; uniform access time; volatile |
| **SDRAM** | Capacitor based; periodic refresh; high density; synchronous interface; latency + burst |

The **FMC** on the STM32F429ZI is a configurable bridge that connects external memories (asynchronous SRAM, NOR flash, SDRAM, NAND flash) to the internal 32-bit system bus.
