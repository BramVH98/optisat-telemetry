meta:
  id: optisat
  title: OPTISAT (2026-067C) AX.25 telemetry beacon
  endian: le
doc-ref: |
  https://github.com/BramVH98/optisat-telemetry
doc: |
  :field battery_voltage_mv: Battery/bus voltage in millivolts
  :field unknown_const_a: Unknown constant byte
  :field frame_type: Frame type identifier (0x33 = full telemetry)
  :field current_ma: Bus/subsystem current draw in milliamps
  :field unknown_const_b: Unknown constant byte
  :field unknown_const_c: Unknown constant byte
  :field reserved_block_1: Constant 3-byte block, possible tag/type marker (unconfirmed)
  :field padding_1: Always zero
  :field reserved_block_2: Constant 4-byte block, possible channel/tag ID (unconfirmed)
  :field sentinel_1: Constant 4-byte value 0xFE 0xFF 0xFF 0xFF, possibly int32 -2 (unconfirmed)
  :field unknown_a1: Unidentified byte, weak correlation with temp_1
  :field tag_marker_1: Constant 0x3E, structural marker of unknown meaning
  :field unknown_b1: Unidentified byte
  :field unknown_c1: Unidentified byte
  :field unknown_d1: Unidentified byte
  :field temp_1_raw: Temperature sensor 1, raw value (range 58-73, physically plausible)
  :field padding_2: Always zero
  :field reserved_block_3: Constant 5-byte block, possible channel/tag ID (unconfirmed)
  :field unknown_a2: Unidentified byte, structurally paired with unknown_a1
  :field tag_marker_2: Constant 0x3E, second occurrence of structural marker
  :field unknown_b2: Unidentified byte
  :field unknown_c2: Unidentified byte
  :field unknown_d2: Unidentified byte
  :field unknown_e2: Unidentified byte, structural asymmetry vs first sub-block
  :field temp_2_raw: Temperature sensor 2, raw value (corr=0.97 with temp_1)
  :field padding_3: Always zero
  :field reserved_block_4: Constant 4-byte block, possible channel/tag ID (unconfirmed)
  :field unknown_f1: Unidentified byte, weak correlation with temp_1
  :field unknown_h1: Two-valued byte (0x3C/0x3D), meaning unknown
  :field unknown_g1: Mostly zero, occasional spikes 0-236 - possible sun sensor (unconfirmed)
  :field unknown_i1: Two-valued byte (0/1), meaning unknown
  :field temp_3_raw: Temperature sensor 3, raw value (corr=0.94 with temp_1)
  :field padding_end: Always zero

seq:
  - id: battery_voltage_mv
    type: u2
    doc: Battery/bus voltage in millivolts

  - id: unknown_const_a
    type: u1

  - id: frame_type
    type: u1
    doc: "0x33 = full telemetry, 0x80 = identity beacon (spells 'Endurosat'), 0x83 = sparse/status frame"

  - id: current_ma
    type: u2
    doc: Bus/subsystem current draw in milliamps

  - id: unknown_const_b
    type: u1
  - id: unknown_const_c
    type: u1

  - id: reserved_block_1
    size: 3
    doc: "Constant 00 03 0D - possible tag/type marker, unconfirmed"

  - id: padding_1
    size: 13
    doc: Always zero

  - id: reserved_block_2
    size: 4
    doc: "Constant 59 00 01 0D - possible channel/tag ID, unconfirmed"

  - id: sentinel_1
    size: 4
    doc: "Constant FE FF FF FF - possibly int32 -2, unconfirmed"

  - id: unknown_a1
    type: u1
    doc: Varies 7-219, weak correlation with temp_1 - meaning unknown

  - id: tag_marker_1
    type: u1
    doc: Always 0x3E - structural marker, meaning unknown

  - id: unknown_b1
    type: u1
  - id: unknown_c1
    type: u1
  - id: unknown_d1
    type: u1

  - id: temp_1_raw
    type: u1
    doc: Temperature sensor 1, raw value (range 58-73)

  - id: padding_2
    size: 2

  - id: reserved_block_3
    size: 5
    doc: "Constant 03 5B 00 01 08 - possible channel/tag ID, unconfirmed"

  - id: unknown_a2
    type: u1
    doc: Structurally paired with unknown_a1

  - id: tag_marker_2
    type: u1
    doc: Always 0x3E, second occurrence

  - id: unknown_b2
    type: u1
  - id: unknown_c2
    type: u1
  - id: unknown_d2
    type: u1
  - id: unknown_e2
    type: u1
    doc: Extra byte present in this sub-block only - structural asymmetry, unexplained

  - id: temp_2_raw
    type: u1
    doc: Temperature sensor 2, raw value (range 160-201, corr=0.97 with temp_1)

  - id: padding_3
    size: 1

  - id: reserved_block_4
    size: 4
    doc: "Constant 5D 00 01 06 - possible channel/tag ID, unconfirmed"

  - id: unknown_f1
    type: u1
    doc: Range 11-239, weak correlation with temp_1 - meaning unknown

  - id: unknown_h1
    type: u1
    doc: "Two distinct values (0x3C/0x3D) - meaning unknown"

  - id: unknown_g1
    type: u1
    doc: "Range 0-236, mostly zero - unconfirmed hypothesis: sun sensor (near-zero in eclipse, higher in sunlight)"

  - id: unknown_i1
    type: u1
    doc: "Two distinct values (0/1) - meaning unknown"

  - id: temp_3_raw
    type: u1
    doc: Temperature sensor 3, raw value (range 86-129, corr=0.94 with temp_1)

  - id: padding_end
    size: 1