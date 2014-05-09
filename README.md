wireshark-plugins
=================

My custom wireshark plugins.


INSTALL
=======

Make sure wireshark finds the plugins, i.e. by symlinking your
wireshark plugins dir to this repo's plugins dir:

```$ ln -s .../path/to/repo/wireshark-plugins/plugins ~/.wireshark/plugins```


Plugins
=======


Cap'n Proto RPC protocol dissector
----------------------------------

The full RPC schema is available, giving pretty good insight into what
is going on, at the RPC level.

![screenshot](https://raw.githubusercontent.com/kaos/wireshark-plugins/master/screenshot.png "Screenshot of Cap'n Proto RPC dissector")

### Capture some data

Example command to capture the data from the capnp calculator sample
(assuming the server is already running, and listening on
`localhost:55000`):

```
    { wireshark -i lo -k -a duration:2 & }; \
    sleep 2 && ./calculator-client localhost:55000
```

It can look something like this (output from `tshark -r <capture-file.pcapng> -Y capnp`):

```
  4 0.000337000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 130 > restore(0) "calculator\0"
  6 0.000383000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 242 > call(1) (promisedAnswer=(0, []))::Calculator->evaluate(capTable=[], content=(expression=(literal=123))) return to
: caller, tail call: false
  8 0.000419000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 210 > call(2) (promisedAnswer=(1, [getPointerField=0]))::Value->read(capTable=[], content=()) return to: caller, tail c
all: false
 10 0.000479000    127.0.0.1 55000 127.0.0.1    51771 CAPNP 162 <  return(0) results(capTable=[(senderHosted=0)], content=cap(0))
 12 0.000600000    127.0.0.1 55000 127.0.0.1    51771 CAPNP 170 <  return(1) results(capTable=[(senderHosted=1)], content=(value=cap(0)))
 14 0.000626000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 106 > finish(0)
 15 0.000684000    127.0.0.1 55000 127.0.0.1    51771 CAPNP 154 <  return(2) results(capTable=[], content=(value=123))
 16 0.001076000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 106 > finish(2)
 17 0.001200000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 106 > finish(1)
 18 0.001241000    127.0.0.1 51771 127.0.0.1    55000 CAPNP 106 > release(1)
```

And using `-O capnp` instead:
```
Frame 6: 242 bytes on wire (1936 bits), 242 bytes captured (1936 bits) on interface 0
Ethernet II, Src: 00:00:00_00:00:00 (00:00:00:00:00:00), Dst: 00:00:00_00:00:00 (00:00:00:00:00:00)
Internet Protocol Version 4, Src: 127.0.0.1 (127.0.0.1), Dst: 127.0.0.1 (127.0.0.1)
Transmission Control Protocol, Src Port: 51771 (51771), Dst Port: 55000 (55000), Seq: 65, Ack: 1, Len: 176
Cap'n Proto RPC Protocol: call(1) (promisedAnswer=(0, []))::Calculator->evaluate(content=(expression=(literal=123)), capTable=[]) return to: caller, tail call: false
    Segments: 1
        Segment: 0 ( 21 words )
            Data ( 168 bytes )
    Root: Message, union: call
        (raw struct)
            Data offset: 0
            Data ( 1 words )
                Data ( 8 bytes )
                Union, tag: 2 ( call )
            Pointers: 1
                Data ( 8 bytes )
        Fields
            call: Call
                (raw struct)
                    Data offset: 0
                    Data ( 3 words )
                        Data ( 24 bytes )
                    Pointers: 3
                        Data ( 24 bytes )
                Fields
                    questionId: 1
                    target: MessageTarget, union: promisedAnswer
                        (raw struct)
                            Data offset: 9
                            Data ( 1 words )
                                Data ( 8 bytes )
                                Union, tag: 1 ( promisedAnswer )
                            Pointers: 1
                                Data ( 8 bytes )
                        Fields
                            promisedAnswer: PromisedAnswer
                                (raw struct)
                                    Data offset: 0
                                    Data ( 1 words )
                                        Data ( 8 bytes )
                                    Pointers: 1
                                        Data ( 8 bytes )
                                Fields
                                    questionId: 0
                                    transform: 0 items
                                        Offset: 0
                                        Element size: 32
                                        Count: 0
                    interfaceId: 10923537602090224694
                    methodId: 0
                    params: Payload
                        (raw struct)
                            Data offset: 1
                            Data ( 0 words )
                            Pointers: 2
                                Data ( 16 bytes )
                        Fields
                            content: evaluate$Params
                                (raw struct)
                                    Data offset: 1
                                    Data ( 0 words )
                                    Pointers: 1
                                        Data ( 8 bytes )
                                Fields
                                    expression: Expression, union: literal
                                        (raw struct)
                                            Data offset: 0
                                            Data ( 2 words )
                                                Data ( 16 bytes )
                                                Union, tag: 0 ( literal )
                                            Pointers: 2
                                                Data ( 16 bytes )
                                        Fields
                                            literal: 123
                            capTable: 0 items
                                Offset: 9
                                Element size: composite
                                Words: 0
                                    Count: 0
                                Tag: CapDescriptor
                    sendResultsTo, tag: 0 ( caller )
                        caller: (void)
                    allowThirdPartyTailCall: false

...
```


### Custom schemas

Simply plugin additional capnp schemas to be used by the dissector by
compiling them to lua code using the provided `Makefile`:

```
make schema input=/path/to/my-schema.capnp
```

This will compile the schema to `plugins/my-schema_capnp.lua` and is
automatically picked up by the dissector.

*Notice* As wireshark re-dissects messages ad-hoc while browsing (why,
oh-why?! waily waily) it is hard to keep track of request/answer id's,
which requires an in-sequence approach. I've made an attempt at
keeping track of the packet number-range for each request id, so it
should work pretty well now, I think..
