# This is a generated file! Please edit source .ksy file and use kaitai-struct-compiler to rebuild
# type: ignore

import kaitaistruct
from kaitaistruct import KaitaiStruct, KaitaiStream, BytesIO


if getattr(kaitaistruct, 'API_VERSION', (0, 9)) < (0, 11):
    raise Exception("Incompatible Kaitai Struct Python API: 0.11 or later is required, but you have %s" % (kaitaistruct.__version__))

class OptisatTelemetry(KaitaiStruct):
    def __init__(self, _io, _parent=None, _root=None):
        super(OptisatTelemetry, self).__init__(_io)
        self._parent = _parent
        self._root = _root or self
        self._read()

    def _read(self):
        self.battery_voltage_mv = self._io.read_u2le()
        self.unknown_const_a = self._io.read_u1()
        self.frame_type = self._io.read_u1()
        self.current_ma = self._io.read_u2le()
        self.unknown_const_b = self._io.read_u1()
        self.unknown_const_c = self._io.read_u1()
        self.reserved_block_1 = self._io.read_bytes(3)
        self.padding_1 = self._io.read_bytes(13)
        self.reserved_block_2 = self._io.read_bytes(4)
        self.sentinel_1 = self._io.read_bytes(4)
        self.unknown_a1 = self._io.read_u1()
        self.tag_marker_1 = self._io.read_u1()
        self.unknown_b1 = self._io.read_u1()
        self.unknown_c1 = self._io.read_u1()
        self.unknown_d1 = self._io.read_u1()
        self.temp_1_raw = self._io.read_u1()
        self.padding_2 = self._io.read_bytes(2)
        self.reserved_block_3 = self._io.read_bytes(5)
        self.unknown_a2 = self._io.read_u1()
        self.tag_marker_2 = self._io.read_u1()
        self.unknown_b2 = self._io.read_u1()
        self.unknown_c2 = self._io.read_u1()
        self.unknown_d2 = self._io.read_u1()
        self.unknown_e2 = self._io.read_u1()
        self.temp_2_raw = self._io.read_u1()
        self.padding_3 = self._io.read_bytes(1)
        self.reserved_block_4 = self._io.read_bytes(4)
        self.unknown_f1 = self._io.read_u1()
        self.status_flag_1 = self._io.read_u1()
        self.sun_sensor_raw = self._io.read_u1()
        self.status_flag_2 = self._io.read_u1()
        self.temp_3_raw = self._io.read_u1()
        self.padding_end = self._io.read_bytes(1)


    def _fetch_instances(self):
        pass


