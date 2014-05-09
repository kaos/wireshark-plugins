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


### Capture some data

Example command to capture the data from the capnp calculator sample
(assuming the server is already running, and listening on
`localhost:55000`):

```
    { wireshark -i lo -k -a duration:2 & }; \
    sleep 2 && ./calculator-client localhost:55000
```

It can look something like this (output from `tshark -r <capture-file.pcapng> -O capnp`):

```
...
Frame 4: 130 bytes on wire (1040 bits), 130 bytes captured (1040 bits) on interface 0
Ethernet II, Src: 00:00:00_00:00:00 (00:00:00:00:00:00), Dst: 00:00:00_00:00:00 (00:00:00:00:00:00)
Internet Protocol Version 4, Src: 127.0.0.1 (127.0.0.1), Dst: 127.0.0.1 (127.0.0.1)
Transmission Control Protocol, Src Port: 51771 (51771), Dst Port: 55000 (55000), Seq: 1, Ack: 1, Len: 64
Cap'n Proto RPC Protocol: restore(0) objectId="calculator\0"
    Segments: 1
        Segment: 0 ( 7 words )
            Data ( 56 bytes )
    Root: Message, union: restore
        (raw struct)
            Data offset: 0
            Data ( 1 words )
                Data ( 8 bytes )
                Union, tag: 8 ( restore )
            Pointers: 1
                Data ( 8 bytes )
        Fields
            restore: Restore
                (raw struct)
                    Data offset: 0
                    Data ( 1 words )
                        Data ( 8 bytes )
                    Pointers: 1
                        Data ( 8 bytes )
                Fields
                    questionId: 0
                    objectId: AnyPointer = "calculator\0"
                        Offset: 0
                        Element size: 8
                        Count: 11
                        Text: "calculator\0"

...
```

The text description of the RPC message is close to that of the capnp stringify ones, some excerpt from the calculator sample:

```
Cap'n Proto RPC Protocol: restore(0) objectId="calculator\0"
Cap'n Proto RPC Protocol: call(1) (promisedAnswer=(0, []))::10923537602090224694->method(0) (capTable=[], content=()) return to: caller, tail call: false
Cap'n Proto RPC Protocol: call(2) (promisedAnswer=(1, [getPointerField=0]))::14116142932258867410->method(0) (capTable=[], content=()) return to: caller, tail call: false
Cap'n Proto RPC Protocol: return(0) releaseParamCaps=true results(capTable=[(senderHosted=0)], content=cap(0))
Cap'n Proto RPC Protocol: return(1) releaseParamCaps=false results(capTable=[(senderHosted=1)], content=())
Cap'n Proto RPC Protocol: finish(0) releaseResultCaps=false
Cap'n Proto RPC Protocol: return(2) releaseParamCaps=false results(capTable=[], content=())
Cap'n Proto RPC Protocol: finish(2) releaseResultCaps=false
Cap'n Proto RPC Protocol: finish(1) releaseResultCaps=false
Cap'n Proto RPC Protocol: release(1) referenceCount=1

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
which requires an in-sequence approach. I'm considering looking at
packet numbers to help out here, but it as of yet not implemented.

So, if you look at a result, and the contents are not dissected
properly, even though there is a schema for the data, try locating the
corresponding call and visit that first. On a similar note, if the
result contents are of the wrong type, re-visit the correct call, as
the request id may have been re-used.
