import csv
from optisat_telemetry import OptisatTelemetry

HEADER_LEN = 16
count = 0
errors = 0

with open("frames.csv") as f:
    for line in f:
        parts = line.strip().split("|")
        if len(parts) < 2:
            continue
        ts, hexstr = parts[0], parts[1]
        try:
            raw = bytes.fromhex(hexstr)
        except ValueError:
            continue
        if len(raw) <= HEADER_LEN:
            continue
        payload = raw[HEADER_LEN:]
        if len(payload) != 63 or payload[3] != 0x33:
            continue

        try:
            obj = OptisatTelemetry.from_bytes(payload)
        except Exception as e:
            print(f"PARSE ERROR at {ts}: {e}")
            errors += 1
            continue

        count += 1
        # sanity flags
        flags = []
        if not (4000 <= obj.battery_voltage_mv <= 4700):
            flags.append("volt_out_of_range")
        if not (1000 <= obj.current_ma <= 1700):
            flags.append("curr_out_of_range")
        if not (30 <= obj.temp_1_raw <= 90):
            flags.append("t1_out_of_range")

        marker = "  ⚠ " + ",".join(flags) if flags else ""
        print(f"{ts}  volt={obj.battery_voltage_mv}mV  curr={obj.current_ma}mA  "
              f"t1={obj.temp_1_raw} t2={obj.temp_2_raw} t3={obj.temp_3_raw} "
              f"sun={obj.sun_sensor_raw}{marker}")

print(f"\n{count} frames decoded, {errors} parse errors")