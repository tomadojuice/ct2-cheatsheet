# CT2 Zwischentests – Aufgaben und Lösungen

---

## Dokument 1: Zwischenprüfung (Moodle, April 2022)

**Kurs:** Computer Technik 2 (ZHAW)  
**Datum:** Mittwoch, 27. April 2022  
**Dauer:** 45 Minuten  
**Bewertung:** 75,00 von 82,00 (91,46%)

### Prüfungsbedingungen
- Dauer: 1 Lektion (45 Minuten)
- Geprüft wird der in Theorie und Praktika behandelte Stoff
- Open Book
- Die Prüfung ist alleine und persönlich durchzuführen
- Hilfe von Anderen oder Kommunikation mit Anderen ist nicht erlaubt
- Unredliches Verhalten hat die Note 1 zur Folge

---

### Frage 1 – I2C Adressierung (3/3 Punkte)

**Aufgabe:** Der Master sendet zur Initialisierung der Kommunikation mit einem Slave folgende 8 Bit: `1010'0011` (MSB first). Interpretieren Sie diese.

| Feld | Antwort |
|---|---|
| Slave-Adresse | `0x40 <= Adresse < 0x60` |
| Read/Write | read |

---

### Frage 2 – Buszugriff (6/6 Punkte)

**Aufgabe:** Tragen Sie alle Bytes des Read-Zugriffs in die Tabelle ein. Der Prozessor ist little endian.

| Adresse (aufsteigend) | Daten-Byte |
|---|---|
| 0xE000A200 | 0x80 |
| 0xE000A201 | 0xBE |
| 0xE000A202 | 0x01 |
| 0xE000A203 | 0x20 |

---

### Frage 3 – Memory (2/2 Punkte)

**Aufgabe:** Weisen Sie die Speicherzellen der entsprechenden Speichertechnologie zu.

- FLASH
- SRAM

---

### Frage 4 – Timer/Counter (6/6 Punkte)

**Aufgabe:** Ein 32-bit Timer soll periodisch Interrupts im Abstand von 47 ms auslösen. Frequenz der Quelle: 84 MHz. Der Prescaler teilt durch 21. Welchen Wert muss man in das Auto-Reload-Register (ARR) schreiben?

**Antwort:** `187999`

**Rechenweg:**
- 84 MHz / 21 = 4 MHz
- 4 MHz × 0,047 s = 188000 Ticks → ARR = 188000 − 1 = **187999**

---

### Frage 5 – Memory (2/2 Punkte)

**Aufgabe:** Wie groß ist der Speicherbereich in kBytes, der mit 20 Adressleitungen maximal angesprochen werden kann (jede Adresse = 1 Byte)?

**Antwort:** `1024` kBytes

**Rechenweg:** 2²⁰ = 1 048 576 Bytes = 1024 kBytes

---

### Frage 6 – I2C Start (2/2 Punkte)

**Aufgabe:** Der Master signalisiert den Start einer I2C-Kommunikation durch folgende Bedingung:

**Antwort:** Fallende Flanke auf **SDA** während **SCL high** ist.

---

### Frage 7 – Kurzfragen Microcontroller Basics (6/6 Punkte)

| Aussage | Antwort |
|---|---|
| Die Harvard-Architektur zeichnet sich durch einen gemeinsamen Bus für Instruktionen und Daten aus. | Falsch |
| Bei einem asynchronen Bus verwenden Master und Slave einen gemeinsamen Taktgeber. | Falsch |
| Wenn ein Slave unter mehreren Adressen erreichbar ist, spricht man von partieller Adressdekodierung. | Wahr |
| Eine CPU kann langsame Peripherien ansprechen, indem die Busfrequenz gesenkt wird. | Falsch |
| Bei einer asynchronen Datenübertragung generiert ein Slave sein eigenes Clock-Signal. | Wahr |
| Anhand der Signale NOE und NWE erkennt die CPU, ob ein Bus-Slave lesen oder schreiben will. | Falsch |

---

### Frage 8 – Timer/Counter PWM (6/6 Punkte)

**Konfiguration:** 16-Bit Timer, 35 MHz Quelle, Prescaler teilt durch 70, Downcounter.  
PWM-Signal: low bei Counter = 0, high bei Counter = Compare-Wert.  
Ziel: Periode 96 ms, Duty Cycle 6/8.

**CCR-Wert:** `36000`

**Rechenweg:**
- 35 MHz / 70 = 500 kHz → Tick = 2 µs
- ARR = 96 ms / 2 µs = 48000 Ticks
- CCR = 6/8 × 48000 = **36000**

---

### Frage 9 – ADC Offset (5/8 Punkte)

**Konfiguration:** ADC2, Vref = 3 V, Offsetfehler = +2 LSB, 10-Bit.

| Teilfrage | Antwort |
|---|---|
| Absolute Adresse des Datenregisters | `0x40012100` |
| Spannung des Offsetfehlers (mV) | `5.9` mV |

---

### Frage 10 – Externer Buszugriff (2/4 Punkte)

**Konfiguration:** FMC STM32F427, externer Bus 16-bit breit, Speicher 8-bit breit.

| Zugriff | Anzahl Buszugriffe | CPU wartet? |
|---|---|---|
| 8-bit Wert schreiben | 2 | Nein |
| 16-bit Wert lesen | 3 | Ja |
| 32-bit Wert schreiben | 5 | Nein |
| 32-bit Wert lesen | 5 | Ja |

---

### Frage 11 – Partielle Dekodierung (4/6 Punkte)

**Aufgabe:** 8-Bit-Adressbus. Peripherie selektiert auf: `0x4C`, `0x6D`, `0x4D`, `0x6C`.

| Teilfrage | Antwort |
|---|---|
| Anzahl ignorierter Adressleitungen | 6 (nur 2 dekodiert) |
| Nummern der ignorierten Leitungen | `0 5` (laut Lösung) |

---

### Frage 12 – GPIO Push-Pull (4/4 Punkte)

| Aussage | Wahr/Falsch |
|---|---|
| Push-pull ist wegen Kurzschlussgefahr nicht geeignet für den Betrieb an einem Bus mit mehreren Teilnehmern | Wahr |
| Mit einer Push-pull Treiberstufe kann eine LED (andere Seite GND) zum Leuchten gebracht werden | Wahr |
| Mit einer Push-pull Treiberstufe kann eine Leitung auf 'High', 'Low' oder 'Floating' getrieben werden | Falsch |
| Push-pull Treiberstufen benötigen einen Pull-up Widerstand, um die Leitung auf 'High' zu treiben | Falsch |

---

### Frage 13 – Timer/Counter Prescaler (6/6 Punkte)

**Aufgabe:** 16-Bit Counter, 40 MHz Clock, alle 20 ms ein Interrupt. Prescaler-Wert (ARR-Bereich möglichst gut ausgeschöpft)?

**Antwort:** `16`

**Rechenweg:**
- 2¹⁶ = 65536
- 50 Hz × 65536 = 3 276 800 Hz → 40 MHz / 3,277 MHz ≈ 12,2 → nächster verfügbarer Wert = **16**

---

### Frage 14 – GPIO Konfiguration STM32F429 Port F.14 (8/8 Punkte)

**Ziel:** Fast speed, digitaler Output, push-pull, kein Pull-Widerstand.

| Register | Adresse | Bits: Bitmaske | Position im Register |
|---|---|---|---|
| MODER | 0x40021400 | 01 | 29:28 |
| OTYPER | 0x40021404 | 0 | 14 |
| PUPDR | 0x4002140C | 00 | 29:28 |
| OSPEEDR | 0x40021408 | 10 | 29:28 |

---

### Frage 15 – SPI Timing Diagramm (4/4 Punkte)

**Konfiguration:** CPOL=1, CPHA=0, MSB first. Master sendet `0x95`.

**Antwort:** Diag 3

---

### Frage 16 – Flash Memory (4/4 Punkte)

| Ausgangswert | Operationen | Resultierender Wert |
|---|---|---|
| 0x6C | 1. kein Erase; 2. Program 0x6F | 0x6C |
| 0x6C | 1. Erase; 2. Program 0x6F | 0x6F |

---

### Frage 17 – Kurzfragen SPI (5/5 Punkte)

| Aussage | Antwort |
|---|---|
| Über die SPI-MOSI-Leitung sendet der Master Daten an den Slave. | Wahr |
| Über die SPI-MISO-Leitung sendet der Slave Daten an den Master. | Wahr |
| Bei SPI sind die Slaves über eine 7-Bit Adresse adressierbar. | Falsch |
| SPI ist für Onboard-Verbindungen geeignet. | Wahr |
| Bei der SPI-Schnittstelle wird der Clock über eine separate Leitung geführt. | Wahr |

---
---

## Dokument 2: Zwischentest FS23

---

### Frage 1 – Kurzfragen Microcontroller Basics

| Aussage | Antwort |
|---|---|
| Bei einem Half-Word Schreibzugriff auf dem 32bit-Systembus sind genau zwei NBL[x]-Signale aktiv. | Wahr |
| Bei einer synchronen Datenübertragung verwendet ein Slave das Clock-Signal vom Master. | Wahr |
| Die CPU kann Slaves am Systembus mittels Control-Bits konfigurieren. | Wahr |
| Der Systembus besteht aus den zwei Bestandteilen Datenbus und Kontrollsignale. | Falsch |
| Die CPU kann Slaves am Systembus mittels Status-Bits konfigurieren. | Falsch |
| Der Systembus übermittelt unter anderem die Kontrollsignale. | Wahr |

---

### Frage 2 – Partielle Dekodierung

**Aufgabe:** 8-Bit-Adressbus. Peripherie selektiert auf: `0x6D`, `0x7F`, `0x6F`, `0x7D`.

| Teilfrage | Antwort |
|---|---|
| Anzahl ignorierter Adressleitungen | 2 |
| Nummern der ignorierten Leitungen | `1 4` |

---

### Frage 3 – Buszugriff (Write-Zugriff)

**Aufgabe:** Write-Zugriff, Adresse `0xE0000040`, Datenwort `0x08003A99`, little endian.

| Adresse (aufsteigend) | Daten-Byte |
|---|---|
| 0xE0000040 | 0x99 |
| 0xE0000041 | 0x3A |
| 0xE0000042 | 0x00 |
| 0xE0000043 | 0x08 |

---

### Frage 4 – GPIO Treiberstufen

**Aufgabe:** Output-Pin als push-pull ohne pull-Widerstand. Welcher Wert wird am Input-Pin erkannt?

| Pull-Widerstand am Input-Pin | Output '0': Gelesener Input-Wert | Output 'floating': Gelesener Input-Wert |
|---|---|---|
| kein | 0 | undefiniert |
| pull-up | 0 | 1 |
| pull-down | 0 | 0 |

---

### Frage 5 – GPIO Konfiguration STM32F429 Port A.5

**Ziel:** Low speed, digitaler Output, open-drain, pull-up.

**Basisadresse GPIO Port A:** `0x40020000`

| Register | Offset | Bits: Bitmaske | Shift um |
|---|---|---|---|
| MODER | 0x00 | 01 | << 10 |
| OTYPER | 0x04 | 1 | << 5 |
| PUPDR | 0x0C | 01 | << 10 |
| OSPEEDR | 0x08 | 00 | << 10 |

---

### Frage 6 – SPI Timing Diagramm

**Konfiguration:** CPOL=1, CPHA=0, MSB first. Master sendet `0x59`.

**Antwort:** Keines (Diag 1 ist LSB, nicht MSB first)

---

### Frage 7 – Kurzfragen SPI

| Aussage | Antwort |
|---|---|
| SPI wird auch 2-wire bus genannt. | Falsch |
| SPI ist für Onboard-Verbindungen geeignet. | Wahr |
| Bei SPI müssen neben den Datenbits sogenannte Synchronisationsbits übertragen werden. | Falsch |
| SPI ist eine synchrone Verbindung. | Wahr |
| Bei SPI braucht es zu jedem Slave eine separate Slave-Select-Leitung. | Wahr |

---

### Frage 8 – I2C Adressierung

**Aufgabe:** 8 Bit: `0100'0110` (MSB first).

| Feld | Antwort |
|---|---|
| Slave-Adresse | `0100011b = 0x23` |
| Read/Write | Write (=0) |

---

### Frage 9 – I2C Ende

**Antwort:** Steigende Flanke auf **SDA** während **SCL High** ist.

---

### Frage 10 – Timer/Counter Prescaler

**Aufgabe:** 16-Bit Counter, 40 MHz, Interrupt alle 20 ms. ARR-Bereich möglichst gut ausschöpfen.

**Lösung:**
- 1/40 MHz = 0,000000025 s/Cycle
- 2¹⁶ × 25 ns = 1,6384 ms → für 20 ms muss mindestens durch ~13 geteilt werden

---

### Frage 11 – PWM Periode und Duty Cycle

**Konfiguration:** Up-counter, fcount = 100 kHz, Alle Register 16-bit. PWM: 600 ms Periode, 80% Duty Cycle.

**Rechenweg:**
- Tick-Dauer = 1/100 kHz = 10 µs
- 600 ms / 10 µs = 60 000 Ticks → ARR = 60 000 − 1 = **59999**
- 80% von 60 000 = 48 000 → CCR = 48 000 − 1 = **47999**

---

### Frage 12 – Timer/Counter PWM (Downcounter)

**Konfiguration:** 16-Bit Timer, 35 MHz, Prescaler 1/70, Downcounter. Periode 96 ms, Duty Cycle 6/8.

**Antwort:** CCR = `36000 − 1`

**Rechenweg:**
- 35 MHz / 70 = 500 kHz → Tick = 2 µs
- ARR = 48 000 − 1 (96 ms / 2 µs = 48 000)
- CCR = 6/8 × 48 000 − 1 = **35999**

---

### Frage 13 – ADC Offset (ADC1)

**Konfiguration:** ADC1, Vref = 3 V, Offsetfehler = +2 LSB, 8-Bit.

| Teilfrage | Antwort |
|---|---|
| Absolute Adresse des Datenregisters | `0x4001'204C` |
| Spannung des Offsetfehlers | 23.4 mV |

**Rechenweg:** 1 LSB = 3 V / 2⁸ = 0,01171875 V → 2 × 0,01171875 V = 23,4 mV

---

### Frage 14 – Memory

**Aufgabe:** Speicherbereich mit 22 Adressleitungen in kBytes.

**Antwort:** `4096` kBytes

**Rechenweg:** 2²² = 4 194 304 Bytes / 1024 = **4096 kBytes**

---

### Frage 15 – Flash Memory

| Ausgangswert | Operationen | Resultierender Wert |
|---|---|---|
| 0xC3 | 1. kein Erase; 2. Program 0xF3 | 0xC3 |
| 0xC3 | 1. Erase; 2. Program 0xF3 | 0xF3 |

**Erklärung:**
- Ohne Erase: Flash kann nur Bits von 1→0 setzen (AND-Verknüpfung): 0xC3 AND 0xF3 = 0xC3
- Mit Erase: alle Bits auf 1 → dann Program 0xF3 → **0xF3**

---

### Frage 16 – Memory (Speicherzellen)

| Schaltung | Speichertechnologie |
|---|---|
| Zelle mit zwei invertierten Gattern (b und !b, word line) | SRAM |
| Zelle mit Transistor und Kondensator (bit line, word line) | SDRAM |

---
---

## Dokument 3: Zwischentest FS24

---

### Frage 1 – Kurzfragen Microcontroller Basics

| Aussage | Antwort |
|---|---|
| Die Anzahl der Datenleitungen bestimmt die Grösse des adressierbaren Speichers. | Falsch |
| Für Zugriffe auf langsame Peripherien kann die CPU sogenannte 'Wait-States' einfügen. | Wahr |
| Eine Deklaration als "volatile" in C teilt dem Compiler mit, dass eine Variable möglicherweise extern geändert wird. | Wahr |
| Der Systembus besteht aus den zwei Bestandteilen Datenbus und Kontrollsignale. | Falsch |
| Auf einem Systembus besitzt jeder Slave eine eigene Select-Leitung. | Falsch |
| Auf Adressleitungen eines Systembusses mit einem Master und mehreren Slaves wird unidirektional kommuniziert. | Wahr |
| Ein Register kann gleichzeitig Control- und Status-Bits enthalten. | Wahr |
| Es ist technisch nicht möglich, dass ein Register sowohl Control- als auch Status-Bits enthält. | Falsch |
| Die Anzahl der Adressleitungen bestimmt die Grösse des Adressraums. | Wahr |
| Eine CPU kann langsame Peripherien ansprechen, indem die Busfrequenz gesenkt wird. | Wahr |
| Die CPU kann Slaves am Systembus mittels Status-Bits konfigurieren. | Falsch |

---

### Frage 2 – Buszugriff (Read-Zugriff, zwei Varianten)

**Variante A:** Adresse `0x70001234`, Datenwort `0x01020304`, little endian.

| Adresse (aufsteigend) | Daten-Byte |
|---|---|
| 0x70001234 | 0x04 |
| 0x70001235 | 0x03 |
| 0x70001236 | 0x02 |
| 0x70001237 | 0x01 |

**Variante B:** Adresse `0x80012020`, Datenwort `0x60708090`, little endian.

| Adresse (aufsteigend) | Daten-Byte |
|---|---|
| 0x80012020 | 0x90 |
| 0x80012021 | 0x80 |
| 0x80012022 | 0x70 |
| 0x80012023 | 0x60 |

---

### Frage 3 – Partielle Dekodierung (zwei Varianten)

**Variante A:** Adressen `0x98`, `0xBC`, `0x9C`, `0xB8`.

| Teilfrage | Antwort |
|---|---|
| Anzahl ignorierter Adressleitungen | 2 |
| Nummern der ignorierten Leitungen | `2 5` |

**Variante B:** Adressen `0x61`, `0xE9`, `0x69`, `0xE1`.

| Teilfrage | Antwort |
|---|---|
| Anzahl ignorierter Adressleitungen | 2 |
| Nummern der ignorierten Leitungen | `3 7` |

---

### Frage 4 – GPIO Digital Input & Output

**Digitaler Input (GPIO mit pull-down, 40 kΩ):**

| Input-Signal | IDR.x |
|---|---|
| High | 1 |
| Floating (Z) | 0 |
| Low | 0 |

**Digitaler Output (open-drain mit pull-up 40 kΩ zu VDD):**

| ODR.x | Output-Signal |
|---|---|
| 0 | Low |
| 1 | High |

**Treiberstufe:** open-drain

---

### Frage 5 – GPIO Konfiguration STM32F429 Port F.14

**Ziel:** High speed, digitaler Output, push-pull, kein Pull-Widerstand.

**Basisadresse GPIO Port F:** `0x40021400`

| Register | Offset | Bits: Bitmaske | Shift um |
|---|---|---|---|
| MODER | 0x00 | 01 | << 28 |
| OTYPER | 0x04 | 0 | << 14 |
| PUPDR | 0x0C | 00 | << 28 |
| OSPEEDR | 0x08 | 10 | << 28 |

---

### Frage 6 – Control Register Zugriff (C-Code)

**Variante A:** 8-bit Control Register an Adresse `0x4F00'C000`, warten bis Bit 4 = '1'.

```c
#define CONTROL_REG (*((volatile uint8_t*)(0x4F00C000)))
#define BITMASK (1 << 4)

while ((CONTROL_REG & BITMASK) == 0) {
    // wait
}
```

**Variante B:** 16-bit Control Register an Adresse `0x6300'8000`, warten bis Bit 5 = '1'.

```c
#include <stdint.h>

#define CONTROL_REG_ADDRESS 0x63008000
#define CONTROL_REG (*(volatile uint16_t*) CONTROL_REG_ADDRESS)

while ((CONTROL_REG & (1 << 5)) == 0) {
    // bis Bit 5 den Wert 1
}
```

---

### Frage 7 – SPI Timing Diagramm (zwei Varianten)

**Variante A:** CPOL=1, CPHA=0, MSB first. Byte `0x95`. → **kein Diagramm korrekt**

**Variante B:** CPOL=1, CPHA=0, MSB first. Byte `0x59`. → **Diag 3**

---

### Frage 8 – I2C Adressierung (zwei Varianten)

**Variante A:** 8 Bit: `1110'0110` (MSB first).

| Feld | Antwort |
|---|---|
| Slave-Adresse | `0x60 <= Adresse < 0x80` |
| Read/Write | write |

**Variante B:** 8 Bit: `1010'0011` (MSB first).

| Feld | Antwort |
|---|---|
| Slave-Adresse | `0x40 <= Adresse < 0x60` |
| Read/Write | read |

---

### Frage 9 – I2C Start

**Antwort:** Fallende Flanke auf **SDA**, während **SCL high** ist.

---

### Frage 10 – UART Zeitverlauf (zwei Varianten)

**Variante A:** 1 Startbit, 1 Stoppbit, 8 Datenbits, Parity-bit, 38'400 baud, Even Parity.

| Teilfrage | Antwort |
|---|---|
| Welche Bitnummer hat das Paritybit? | 14 |
| Welcher Datenwert (Hex) wird übertragen? | 0x7D |
| Max. Daten-Bytes pro Sekunde (ohne Overhead) | 3490 |

**Variante B:** 1 Startbit, 1 Stoppbit, 8 Datenbits, Parity-bit, 9'600 baud, Even Parity.

| Teilfrage | Antwort |
|---|---|
| Welche Bitnummer hat das Stoppbit? | 15 |
| Welcher Datenwert (Hex) wird übertragen? | 0xA4 |
| Max. Daten-Bytes pro Sekunde (ohne Overhead) | 872 |

---

### Frage 11 – UART Overhead (zwei Varianten)

**Variante A:** 8 Data-Bits, 1 Stop-Bit, Even Parity, 9600 Baud.

| Teilfrage | Antwort |
|---|---|
| Synchronisations-Overhead in % | 37% |
| Byte-Rate [Bytes/s] | 872 |

**Rechenweg:** 1+8+1+1 = 11 Bits/Paket → 9600/11 = 872,7 → 3 Sync-Bits / 8 Daten-Bits = 37,5% ≈ **37%**

**Variante B:** 8 Data-Bits, 2 Stop-Bits, Odd Parity, 14400 Baud.

| Teilfrage | Antwort |
|---|---|
| Synchronisations-Overhead in % | 50% |
| Byte-Rate [Bytes/s] | 1200 |

---

### Frage 12 – PWM Periode und Duty Cycle

**Konfiguration:** Up-counter, 50 MHz Quelle, PRE = 100−1, ARR = 40000−1, CCR = 30000.

| Teilfrage | Antwort |
|---|---|
| Duty Cycle in Prozent | 75% |
| Periodendauer in ms | 80 ms |

**Rechenweg:**
- Timer-Frequenz = 50 MHz / 100 = 500 kHz → Tick = 2 µs
- Periode = 40000 × 2 µs = 80 ms
- Duty Cycle = 30000 / 40000 = 75%

---

### Frage 13 – ADC Resolution

**Aufgabe:** Referenzspannung 4 V, gewünschtes LSB ≈ 64 mV. Welche Resolution?

**Antwort:** `6 Bit`

**Rechenweg:** 4 V / 2⁶ = 4/64 = 62,5 mV ≈ 64 mV → **6 Bit**

---

### Frage 14 – ADC Offset (ADC3)

**Konfiguration:** ADC3, Vref = 3 V, Offsetfehler = +4 LSB, 10-Bit.

| Teilfrage | Antwort |
|---|---|
| Absolute Adresse des Datenregisters | `0x4001224C` |
| Spannung des Offsetfehlers | 11.7 mV |

**Rechenweg:** 1 LSB = 3 V / 2¹⁰ = 2,929 mV → 4 × 2,929 mV = **11,7 mV**
