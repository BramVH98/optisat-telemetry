# OPTISAT Telemetry Decoder — Reverse Engineering Analysis

## Target

**OPTISAT** (NORAD/COSPAR ID 2026-067C), a Greek CubeSat launched on a March 2026 rideshare mission. At the time of analysis, no public telemetry decoder was listed for it in SatNOGS DB. SatNOGS DB listed it as "No Decoders Found" despite over 114,000 raw demodulated frames already logged by the amateur ground station network.

## Starting point

Raw frames were pulled via SatNOGS's Data Export feature (`db.satnogs.org`), which provides hex-encoded frames already demodulated at the RF layer by SatNOGS's own receiver pipeline. This meant no SDR/demodulation work was required — the task was purely to determine the structure of the bytes SatNOGS had already captured.

## Framing discovery

Every frame shares a constant 16-byte prefix:

```text
8A A6 8E A6 60 62 E0 82 84 86 88 8A 8C E1 03 F0
```

AX.25 addresses encode ASCII characters shifted **left by one bit**. Shifting this prefix's first 14 bytes **right by one bit** and reading as ASCII produces:

* Destination (bytes 0–6): `45 53 47 53 30 31 70` → `ESGS01` + SSID
* Source (bytes 7–13): `41 42 43 44 45 46 70` → `ABCDEF` + SSID

Byte 14 (`0x03`) and byte 15 (`0xF0`) are the standard AX.25 UI-frame control and PID bytes. Producing readable (if generic/placeholder) text from a raw bit-shift, rather than noise, confirms this is genuine AX.25 framing, not a coincidental match.

## Frame types

A byte immediately after the AX.25 header distinguishes three payload types:

| Value  |   Length | Content                                                                                                                 |
| ------ | -------: | ----------------------------------------------------------------------------------------------------------------------- |
| `0x80` | 13 bytes | Identity beacon — payload spells `Endurosat`, confirming the satellite's UHF transceiver is a standard EnduroSat module |
| `0x83` | 48 bytes | Sparse/mostly-zero frame — likely a status or ping beacon                                                               |
| `0x33` | 63 bytes | Full telemetry frame — the primary subject of this analysis                                                             |

The `0x33` frame is the only one carrying meaningful, varying telemetry data.

## Methodology

For the `0x33` telemetry frames, every byte position was analyzed across the full dataset for:

* min/max range and number of distinct values
* monotonicity (does it drift smoothly over time, as real sensor data should?)
* Pearson correlation against fields already confirmed by physical plausibility (voltage, current, first temperature reading)
* whether the byte was constant across all samples (headers, padding, reserved fields)

Fields were only assigned a descriptive name (e.g. `temp_1_raw`) when they met **both** of two bars: a physically plausible value range, and either a direct definitional match (voltage/current, which the frame explicitly carries) or strong correlation (>0.9) with an already-confirmed field.

Fields meeting only one criterion, or supported by indirect/behavioral reasoning alone, are left named `unknown_*` with the hypothesis documented in a comment — see the confidence table below.

## Validation

Two independent checks were used, deliberately without relying on any official specification (none exists publicly for this satellite):

1. **Twin-beacon consistency.** Multiple frames were captured only seconds apart (the satellite beacons more than once per pass). Decoded values for these near-duplicate timestamps are consistently near-identical — the fingerprint of genuine telemetry, not noise, which would not reproduce consistently at that timescale.

2. **Full-dataset parse validation.** The finished decoder was run against **3,228 real telemetry frames spanning roughly four months** (mid-April to late August 2026), collected by dozens of independent ground stations. **All 3,228 frames parsed without error**, and every confirmed field (voltage, current, three temperature channels) stayed within physically plausible bounds across the entire run — including real seasonal temperature range shifts between the earlier and later parts of the dataset.

## Field confidence table

| Field                                | Confidence          | Basis                                                                                                                                                |
| ------------------------------------ | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `battery_voltage_mv`                 | High                | Stable 4.35–4.60 V range with consistent scaling across observations; likely battery/bus voltage                                                     |
| `frame_type`                         | High                | Distinct, consistently observed values gating distinct frame structures                                                                              |
| `current_ma`                         | High                | Stable scaling and physically plausible current range across the dataset                                                                             |
| `reserved_block_1–4`                 | Medium (structural) | Constant byte sequences confirmed; semantic meaning ("channel/tag ID") is a hypothesis                                                               |
| `sentinel_1`                         | Medium (structural) | Constant `FE FF FF FF`; possible int32 -2 sentinel, unconfirmed                                                                                      |
| `tag_marker_1/2`                     | Medium (structural) | Constant `0x3E` at both occurrences; meaning unknown                                                                                                 |
| `temp_1_raw`                         | Medium–high         | Physically plausible range; anchors the correlation analysis for temp_2/3                                                                            |
| `temp_2_raw`                         | Medium–high         | corr = 0.97 with temp_1                                                                                                                              |
| `temp_3_raw`                         | Medium–high         | corr = 0.94 with temp_1                                                                                                                              |
| `unknown_g1` (sun sensor hypothesis) | Low–medium          | Mostly zero with intermittent spikes, consistent with an eclipse/sunlight pattern — but this is behavioral inference, not a direct measurement match |
| `unknown_a1, a2, f1`                 | Low                 | Weak correlation with temp_1 only — not sufficient to name                                                                                           |
| `unknown_h1, i1`                     | None                | Two-valued bytes with no behavioral evidence for what they represent                                                                                 |
| `padding_1–3, padding_end`           | High (structural)   | Constant zero across all samples                                                                                                                     |
| All other `unknown_*` fields         | None                | No pattern identified beyond position                                                                                                                |

## Open questions

* What do `reserved_block_1–4` actually encode? Their spacing (`0x59`, `0x5B`, `0x5D` — each 2 apart) suggests a channel/parameter ID scheme, but this is unconfirmed.
* Why does the second `0x3E`-tagged sub-block contain one extra byte (`unknown_e2`) relative to the first? Structural asymmetry with no known cause.
* Is `unknown_g1` genuinely a sun sensor? The eclipse/sunlight-consistent pattern is suggestive but not verified against any independent light or attitude data.
* What do the two-valued `unknown_h1` / `unknown_i1` bytes represent?

Contributions, corrections, or access to official EnduroSat/OPTISAT telemetry documentation are welcome — see the repository's issues.