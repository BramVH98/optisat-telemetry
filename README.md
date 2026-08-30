# OPTISAT Telemetry Decoder

Reverse-engineered telemetry decoder for **OPTISAT (2026-067C)**, developed from publicly available SatNOGS observations.

## Overview

This project documents the reverse engineering of OPTISAT's AX.25 telemetry beacon and provides a [Kaitai Struct](https://kaitai.io/) definition for parsing the recovered telemetry format.

The decoder was developed by analysing captured telemetry frames, identifying recurring byte structures, correlating fields across observations, and validating candidate fields against multiple real frames.

## Current Results

The decoder has been validated against **116 real telemetry frames**:

* **116 frames decoded**
* **0 parse errors**
* **0 out-of-range validation flags**

Confirmed or strongly supported fields currently include:

* Battery/bus voltage
* Bus/subsystem current
* Three temperature sensor values
* Sun sensor value
* Frame type

Several additional fields and byte blocks are intentionally documented as unknown or unconfirmed rather than being assigned speculative meanings.

## Telemetry Structure

The telemetry is represented using Kaitai Struct:

```text
optisat.ksy
```

The current definition is little-endian and describes the recovered byte-level structure of the telemetry beacon.

Some fields are named according to observed behaviour rather than confirmed spacecraft documentation. These are explicitly marked as unknown, reserved, padding, or hypotheses where appropriate.

## Validation

`test_decoder.py` is used to decode a collection of recovered frames and perform basic sanity checks on the resulting values.

Example decoded telemetry:

```text
volt=4420mV  curr=1281mA  t1=66  t2=185  t3=112  sun=0
volt=4477mV  curr=1429mA  t1=73  t2=201  t3=129  sun=140
volt=4457mV  curr=1331mA  t1=69  t2=182  t3=112  sun=236
```

The temperature and sun-sensor fields show consistent behaviour across observations, while voltage and current remain within plausible spacecraft operating ranges.

## Repository Contents

| File                   | Description                              |
| ---------------------- | ---------------------------------------- |
| `optisat.ksy`          | Kaitai Struct telemetry definition       |
| `optisat_telemetry.py` | Generated Python Kaitai parser           |
| `test_decoder.py`      | Decoder validation script                |
| `frames.csv`           | Recovered/decoded telemetry observations |
| `analysis/main.go`     | Supporting telemetry analysis            |
| `README.md`            | Project documentation                    |

## Reverse Engineering Notes

The goal of this project is to distinguish **observed facts from hypotheses**.

For example, several constant byte sequences appear to function as channel/type markers, but their exact meaning has not been established. These remain documented as unconfirmed rather than being presented as known protocol information.

Similarly, the `sun_sensor_raw` field shows repeated periods of zero followed by values reaching above 200. Its behaviour is consistent with a light/sun-related sensor, but this interpretation remains a hypothesis until independently confirmed.

## Status

**Working decoder: further protocol reverse engineering ongoing.**

The decoder is intended to eventually be contributed to the SatNOGS decoder collection once the format and documentation have been reviewed.

## Tools

* Kaitai Struct
* Python
* Go
* SatNOGS observations
* AX.25 telemetry analysis