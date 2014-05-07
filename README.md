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

The full RPC schema is available, giving pretty good insight into what
is going on, at the RPC level.


### Capture some data

Example command to capture the data from the capnp calculator sample
(assuming the server is already running, and listening on
`localhost:55000`):

```
    { wireshark -i lo -k -a duration:2 & }; \
    sleep 2 && ./calculator-client localhost:55000
```

It can look something like this (output from `tshark -r <capture-file.pcapng> -V -O capnp`):

```
...
Frame 90: 170 bytes on wire (1360 bits), 170 bytes captured (1360 bits) on interface 0
Ethernet II, Src: 00:00:00_00:00:00 (00:00:00:00:00:00), Dst: 00:00:00_00:00:00 (00:00:00:00:00:00)
Internet Protocol Version 4, Src: 127.0.0.1 (127.0.0.1), Dst: 127.0.0.1 (127.0.0.1)
Transmission Control Protocol, Src Port: 55000 (55000), Dst Port: 51771 (51771), Seq: 1993, Ack: 5721, Len: 104
Cap'n Proto RPC Protocol: Message, return
    Segments: 1
        Segment: 0 ( 12 words )
            Data ( 96 bytes )
    Root: Message, union: return
        (raw struct)
            Data offset: 0
            Data ( 1 words )
                Data ( 8 bytes )
            Pointers: 1
                Data ( 8 bytes )
        Fields
            return: Return, union: results
                (raw struct)
                    Data offset: 0
                    Data ( 2 words )
                        Data ( 16 bytes )
                    Pointers: 1
                        Data ( 8 bytes )
                Fields
                    answerId: 6
                    releaseParamCaps: false
                    results: Payload
                        (raw struct)
                            Data offset: 0
                            Data ( 0 words )
                            Pointers: 2
                                Data ( 16 bytes )
                        Fields
                            content: AnyPointer
                                (raw struct)
                                    Data offset: 1
                                    Data ( 0 words )
                                    Pointers: 1
                                        Data ( 8 bytes )
                                        Pointer 0: <opaque pointer> = cap 0
                                            Capability: 0
                            capTable: 1 item
                                Offset: 1
                                Count/Words: 2
                                Element size: composite
                                Items ( 24 bytes )
                                    0: CapDescriptor, union: senderHosted
                                        (raw struct)
                                            Data offset: 0
                                            Data ( 1 words )
                                                Data ( 8 bytes )
                                            Pointers: 1
                                                Data ( 8 bytes )
                                        Fields
                                            senderHosted: 6
...
```
