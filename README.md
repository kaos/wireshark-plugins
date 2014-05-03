wireshark-plugins
=================

My custom wireshark plugins.


INSTALL
=======

Make sure wireshark finds the plugins, i.e. by symlinking your
wireshark plugin dir to this repo:

```$ ln -s .../path/to/repo/wireshark-plugins ~/.wireshark/plugins```


Plugins
=======


Cap'n Proto RPC protocol dissector
----------------------------------

Currently it simply dissects any Cap'n Proto message, as no RPC
schema information has been implemented yet.


### Capture some data

Example command to capture the data from the capnp calculator sample
(assuming the server is already running, and listening on
`localhost:55000`):

```
    { wireshark -i lo -k -a duration:2 & }; \
    sleep 2 && ./calculator-client localhost:55000
```


It can look something like this (output from `tshark -i lo -V -O capnp`):

```
Frame 111: 210 bytes on wire (1680 bits), 210 bytes captured (1680 bits) on interface 0
Ethernet II, Src: 00:00:00_00:00:00 (00:00:00:00:00:00), Dst: 00:00:00_00:00:00 (00:00:00:00:00:00)
Internet Protocol Version 4, Src: 127.0.0.1 (127.0.0.1), Dst: 127.0.0.1 (127.0.0.1)
Transmission Control Protocol, Src Port: 55000 (55000), Dst Port: 55790 (55790), Seq: 2289, Ack: 6713, Len: 144
Cap'n Proto RPC Protocol
    Segment count: 1
        Segment size: 17
            Data (136 bytes)

0000  00 00 00 00 01 00 01 00 02 00 00 00 00 00 00 00   ................
0010  00 00 00 00 03 00 03 00 00 00 00 00 00 00 00 00   ................
0020  94 03 84 96 3d 3a e8 ed 00 00 00 00 00 00 00 00   ....=:..........
0030  1c 00 00 00 01 00 01 00 04 00 00 00 00 00 02 00   ................
0040  00 00 00 00 00 00 00 00 04 00 00 00 00 00 01 00   ................
0050  15 00 00 00 07 00 00 00 01 00 00 00 15 00 00 00   ................
0060  00 00 00 00 00 00 00 40 00 00 00 00 00 00 22 40   .......@......"@
0070  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0080  00 00 00 00 01 00 01 00                           ........
                Data: 000000000100010002000000000000000000000003000300...
                [Length: 136]
    Struct: 0000000001000100
        Offset: 0
        Data size: 1
            Data section: 0200000000000000
        Pointers: 1
            Struct: 0000000003000300
                Offset: 0
                Data size: 3
                    Data section: 0000000000000000940384963d3ae8ed0000000000000000
                Pointers: 3
                    Struct: 1c00000001000100
                        Offset: 7
                        Data size: 1
                            Data section: 0000000000000000
                        Pointers: 1
                            Struct: 0000000000000000
                                Offset: 0
                                Data size: 0
                                Pointers: 0
                    Struct: 0400000000000200
                        Offset: 1
                        Data size: 0
                        Pointers: 2
                            Struct: 0400000000000100
                                Offset: 1
                                Data size: 0
                                Pointers: 1
                                    Data (8 bytes)

0000  01 00 00 00 15 00 00 00                           ........
                                        Data: 0100000015000000
                                        [Length: 8]
                            Data (8 bytes)

0000  15 00 00 00 07 00 00 00                           ........
                                Data: 1500000007000000
                                [Length: 8]
                    Struct: 0000000000000000
                        Offset: 0
                        Data size: 0
                        Pointers: 0
Data (144 bytes)

```
