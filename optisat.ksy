meta:
  id: optisat_telemetry
  title: OPTISAT (2026-067C) AX.25 telemetry beacon
  endian: le

types: {}

seq:
  - id: battery_voltage_mv
    type: u2
    doc: Battery or bus voltage in millivolts.

  - id: unknown_const_a
    type: u1
    doc: Constant value observed in the available telemetry frames.

  - id: frame_type
    type: u1
    doc: "Telemetry frame type. 0x33 identifies the full telemetry frame analyzed here."

  - id: current_ma
    type: u2
    doc: Bus or subsystem current in milliamps.

  - id: unknown_const_b
    type: u1
    doc: Constant value observed in the available telemetry frames.

  - id: unknown_const_c
    type: u1
    doc: Constant value observed in the available telemetry frames.

  - id: reserved_block_1
    size: 3
    doc: "Constant byte sequence 00 03 0D in the analyzed frames; purpose unknown."

  - id: padding_1
    size: 13
    doc: "Constant zero-filled region in the analyzed frames."

  - id: reserved_block_2
    size: 4
    doc: "Constant byte sequence 59 00 01 0D in the analyzed frames; purpose unknown."

  - id: sentinel_1
    size: 4
    doc: "Constant byte sequence FE FF FF FF in the analyzed frames; purpose unknown."

  - id: unknown_a1
    type: u1
    doc: Unknown value; observed range 7-219 in the analyzed frames.

  - id: tag_marker_1
    type: u1
    doc: Constant value 0x3E in the analyzed frames.

  - id: unknown_b1
    type: u1
    doc: Unknown value.

  - id: unknown_c1
    type: u1
    doc: Unknown value.

  - id: unknown_d1
    type: u1
    doc: Unknown value.

  - id: temp_1_raw
    type: u1
    doc: Raw value from temperature sensor 1; observed range 58-73.

  - id: padding_2
    size: 2
    doc: Constant zero-filled region in the analyzed frames.

  - id: reserved_block_3
    size: 5
    doc: "Constant byte sequence 03 5B 00 01 08 in the analyzed frames; purpose unknown."

  - id: unknown_a2
    type: u1
    doc: Unknown value; structurally paired with unknown_a1.

  - id: tag_marker_2
    type: u1
    doc: Constant value 0x3E in the analyzed frames.

  - id: unknown_b2
    type: u1
    doc: Unknown value.

  - id: unknown_c2
    type: u1
    doc: Unknown value.

  - id: unknown_d2
    type: u1
    doc: Unknown value.

  - id: unknown_e2
    type: u1
    doc: Unknown value; present in the second structurally similar sub-block.

  - id: temp_2_raw
    type: u1
    doc: Raw value from temperature sensor 2; observed range 160-201.

  - id: padding_3
    size: 1
    doc: Constant zero-filled byte in the analyzed frames.

  - id: reserved_block_4
    size: 4
    doc: "Constant byte sequence 5D 00 01 06 in the analyzed frames; purpose unknown."

  - id: unknown_f1
    type: u1
    doc: Unknown value; observed range 11-239 in the analyzed frames.

  - id: status_flag_1
    type: u1
    doc: Unknown status value; observed values 0x3C and 0x3D.

  - id: sun_sensor_raw
    type: u1
    doc: Unknown illumination-related value; observed range 0-236, with zero commonly observed.

  - id: status_flag_2
    type: u1
    doc: Unknown status flag; observed values 0 and 1.

  - id: temp_3_raw
    type: u1
    doc: Raw value from temperature sensor 3; observed range 86-129.

  - id: padding_end
    size: 1
    doc: Constant zero-filled byte in the analyzed frames.