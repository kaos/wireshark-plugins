if not capnp_schema then
   capnp_schema = {}
end

-- fake atoms
local void = "void"
local inlineComposite = "inlineComposite"
local fourBytes = 4
local eightBytes = 8
local opaquePointer = "opaquePointer"

-- Notice: Lua doesn't support 64 bit values, but they are still
-- comparable to each other, which will be good enough.

capnp_schema["rpc"] = { nodes = {
    { id = 15376050949367520589,
      displayName = "/usr/local/include/capnp/rpc.capnp:Disembargo.context",
      displayNamePrefixLength = 46,
      scopeId = 17970548384007534353,
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = true,
        discriminantCount = 4,
        discriminantOffset = 2,
        fields = {
          { name = "senderLoopback",
            codeOrder = 0,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "receiverLoopback",
            codeOrder = 1,
            discriminantValue = 1,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 2} },
          { name = "accept",
            codeOrder = 2,
            discriminantValue = 2,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 3} },
          { name = "provide",
            codeOrder = 3,
            discriminantValue = 3,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 4} } } } },
    { id = 15235686326393111165,
      displayName = "/usr/local/include/capnp/rpc.capnp:ThirdPartyCapDescriptor",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "id",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "vineId",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 9593755465305995440,
      displayName = "/usr/local/include/capnp/rpc.capnp:CapDescriptor",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 6,
        discriminantOffset = 0,
        fields = {
          { name = "none",
            codeOrder = 0,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "senderHosted",
            codeOrder = 1,
            discriminantValue = 1,
            slot = {
              offset = 1,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "senderPromise",
            codeOrder = 2,
            discriminantValue = 2,
            slot = {
              offset = 1,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 2} },
          { name = "receiverHosted",
            codeOrder = 3,
            discriminantValue = 3,
            slot = {
              offset = 1,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 3} },
          { name = "receiverAnswer",
            codeOrder = 4,
            discriminantValue = 4,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15564635848320162976 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 4} },
          { name = "thirdPartyHosted",
            codeOrder = 5,
            discriminantValue = 5,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15235686326393111165 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 5} } } } },
    { id = 17516350820840804481,
      displayName = "/usr/local/include/capnp/rpc.capnp:PromisedAnswer.Op",
      displayNamePrefixLength = 50,
      scopeId = 15564635848320162976,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 0,
        preferredListEncoding = fourBytes,
        isGroup = false,
        discriminantCount = 2,
        discriminantOffset = 0,
        fields = {
          { name = "noop",
            codeOrder = 0,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "getPointerField",
            codeOrder = 1,
            discriminantValue = 1,
            slot = {
              offset = 1,
              type = {uint16 = void},
              defaultValue = {uint16 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 12473400923157197975,
      displayName = "/usr/local/include/capnp/rpc.capnp:Release",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 0,
        preferredListEncoding = eightBytes,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "id",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "referenceCount",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 18149955118657700271,
      displayName = "/usr/local/include/capnp/rpc.capnp:Join",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 2,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "target",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 10789521159760378817 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "keyPart",
            codeOrder = 2,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 2} } } } },
    { id = 15239388059401719395,
      displayName = "/usr/local/include/capnp/rpc.capnp:Finish",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 0,
        preferredListEncoding = eightBytes,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "releaseResultCaps",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 32,
              type = {bool = void},
              defaultValue = {bool = true},
              hadExplicitDefault = true },
            ordinal = {explicit = 1} } } } },
    { id = 9469473312751832276,
      displayName = "/usr/local/include/capnp/rpc.capnp:Call",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 3,
        pointerCount = 3,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "target",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 10789521159760378817 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "interfaceId",
            codeOrder = 2,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {uint64 = void},
              defaultValue = {uint64 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 2} },
          { name = "methodId",
            codeOrder = 3,
            discriminantValue = 65535,
            slot = {
              offset = 2,
              type = {uint16 = void},
              defaultValue = {uint16 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 3} },
          { name = "params",
            codeOrder = 5,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {
                struct = {
                  typeId = 11100916931204903995 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 4} },
          { name = "sendResultsTo",
            codeOrder = 6,
            discriminantValue = 65535,
            group = {
              typeId = 15774052265921044377 },
            ordinal = {implicit = void} },
          { name = "allowThirdPartyTailCall",
            codeOrder = 4,
            discriminantValue = 65535,
            slot = {
              offset = 128,
              type = {bool = void},
              defaultValue = {bool = false},
              hadExplicitDefault = true },
            ordinal = {explicit = 8} } } } },
    { id = 17009130564474155176,
      displayName = "/usr/local/include/capnp/rpc.capnp:Restore",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "objectId",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 11392333052105676602,
      displayName = "/usr/local/include/capnp/rpc.capnp:Return",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 2,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 6,
        discriminantOffset = 3,
        fields = {
          { name = "answerId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "releaseParamCaps",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 32,
              type = {bool = void},
              defaultValue = {bool = true},
              hadExplicitDefault = true },
            ordinal = {explicit = 1} },
          { name = "results",
            codeOrder = 2,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 11100916931204903995 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 2} },
          { name = "exception",
            codeOrder = 3,
            discriminantValue = 1,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15430940935639230746 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 3} },
          { name = "canceled",
            codeOrder = 4,
            discriminantValue = 2,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 4} },
          { name = "resultsSentElsewhere",
            codeOrder = 5,
            discriminantValue = 3,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 5} },
          { name = "takeFromOtherQuestion",
            codeOrder = 6,
            discriminantValue = 4,
            slot = {
              offset = 2,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 6} },
          { name = "acceptFromThirdParty",
            codeOrder = 7,
            discriminantValue = 5,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 7} } } } },
    { id = 13386661402618388268,
      displayName = "/usr/local/include/capnp/c++.capnp:namespace",
      displayNamePrefixLength = 35,
      scopeId = 13688829037717245569,
      nestedNodes = {},
      annotation = {
        type = {text = void},
        targetsFile = true,
        targetsConst = false,
        targetsEnum = false,
        targetsEnumerant = false,
        targetsStruct = false,
        targetsField = false,
        targetsUnion = false,
        targetsGroup = false,
        targetsInterface = false,
        targetsMethod = false,
        targetsParam = false,
        targetsAnnotation = false } },
    { id = 13529541526594062446,
      displayName = "/usr/local/include/capnp/rpc.capnp:Resolve",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 2,
        discriminantOffset = 2,
        fields = {
          { name = "promiseId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "cap",
            codeOrder = 1,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 9593755465305995440 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "exception",
            codeOrder = 2,
            discriminantValue = 1,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15430940935639230746 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 2} } } } },
    { id = 15430940935639230746,
      displayName = "/usr/local/include/capnp/rpc.capnp:Exception",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {
        { name = "Durability",
          id = 13523986587913222488 } },
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "reason",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {text = void},
              defaultValue = {text = ""},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "isCallersFault",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {bool = void},
              defaultValue = {bool = false},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "durability",
            codeOrder = 2,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {
                enum = {
                  typeId = 13523986587913222488 } },
              defaultValue = {enum = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 2} } } } },
    { id = 13688829037717245569,
      displayName = "/usr/local/include/capnp/c++.capnp",
      displayNamePrefixLength = 29,
      scopeId = 0,
      nestedNodes = {
        { name = "namespace",
          id = 13386661402618388268 } },
      annotations = {
        { id = 13386661402618388268,
          value = {
            text = "capnp::annotations" } } },
      file = void },
    { id = 10500036013887172658,
      displayName = "/usr/local/include/capnp/rpc.capnp:Message",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 14,
        discriminantOffset = 0,
        fields = {
          { name = "unimplemented",
            codeOrder = 0,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 10500036013887172658 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "abort",
            codeOrder = 1,
            discriminantValue = 1,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15430940935639230746 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "call",
            codeOrder = 2,
            discriminantValue = 2,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 9469473312751832276 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 2} },
          { name = "return",
            codeOrder = 3,
            discriminantValue = 3,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 11392333052105676602 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 3} },
          { name = "finish",
            codeOrder = 4,
            discriminantValue = 4,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15239388059401719395 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 4} },
          { name = "resolve",
            codeOrder = 5,
            discriminantValue = 5,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 13529541526594062446 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 5} },
          { name = "release",
            codeOrder = 6,
            discriminantValue = 6,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 12473400923157197975 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 6} },
          { name = "save",
            codeOrder = 8,
            discriminantValue = 7,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 16433336749162137644 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 7} },
          { name = "restore",
            codeOrder = 9,
            discriminantValue = 8,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 17009130564474155176 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 8} },
          { name = "delete",
            codeOrder = 10,
            discriminantValue = 9,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 9666541409743531671 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 9} },
          { name = "provide",
            codeOrder = 11,
            discriminantValue = 10,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 11270825879279873114 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 10} },
          { name = "accept",
            codeOrder = 12,
            discriminantValue = 11,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15332985841292492822 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 11} },
          { name = "join",
            codeOrder = 13,
            discriminantValue = 12,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 18149955118657700271 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 12} },
          { name = "disembargo",
            codeOrder = 7,
            discriminantValue = 13,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 17970548384007534353 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 13} } } } },
    { id = 16433336749162137644,
      displayName = "/usr/local/include/capnp/rpc.capnp:Save",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "target",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 10789521159760378817 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 13523986587913222488,
      displayName = "/usr/local/include/capnp/rpc.capnp:Exception.Durability",
      displayNamePrefixLength = 45,
      scopeId = 15430940935639230746,
      nestedNodes = {},
      enum = {
        enumerants = {
          {name = "permanent", codeOrder = 0},
          {name = "temporary", codeOrder = 1},
          {name = "overloaded", codeOrder = 2} } } },
    { id = 9666541409743531671,
      displayName = "/usr/local/include/capnp/rpc.capnp:Delete",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "objectId",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 11100916931204903995,
      displayName = "/usr/local/include/capnp/rpc.capnp:Payload",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 0,
        pointerCount = 2,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "content",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "capTable",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {
                list = {
                  elementType = {
                    struct = {
                      typeId = 9593755465305995440 } } } },
              defaultValue = {list = opaquePointer},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 11270825879279873114,
      displayName = "/usr/local/include/capnp/rpc.capnp:Provide",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 2,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "target",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 10789521159760378817 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "recipient",
            codeOrder = 2,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 2} } } } },
    { id = 12903543124727603792,
      displayName = "/usr/local/include/capnp/rpc.capnp",
      displayNamePrefixLength = 29,
      scopeId = 0,
      nestedNodes = {
        { name = "Message",
          id = 10500036013887172658 },
        {name = "Call", id = 9469473312751832276},
        { name = "Return",
          id = 11392333052105676602 },
        { name = "Finish",
          id = 15239388059401719395 },
        { name = "Resolve",
          id = 13529541526594062446 },
        { name = "Release",
          id = 12473400923157197975 },
        { name = "Disembargo",
          id = 17970548384007534353 },
        { name = "Save",
          id = 16433336749162137644 },
        { name = "Restore",
          id = 17009130564474155176 },
        {name = "Delete", id = 9666541409743531671},
        { name = "Provide",
          id = 11270825879279873114 },
        { name = "Accept",
          id = 15332985841292492822 },
        { name = "Join",
          id = 18149955118657700271 },
        { name = "MessageTarget",
          id = 10789521159760378817 },
        { name = "Payload",
          id = 11100916931204903995 },
        {name = "CapDescriptor", id = 9593755465305995440},
        { name = "PromisedAnswer",
          id = 15564635848320162976 },
        { name = "SturdyRef",
          id = 14883405629196290303 },
        { name = "ThirdPartyCapDescriptor",
          id = 15235686326393111165 },
        { name = "Exception",
          id = 15430940935639230746 } },
      annotations = {
        { id = 13386661402618388268,
          value = {text = "capnp::rpc"} } },
      file = void },
    { id = 17970548384007534353,
      displayName = "/usr/local/include/capnp/rpc.capnp:Disembargo",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "target",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 10789521159760378817 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "context",
            codeOrder = 1,
            discriminantValue = 65535,
            group = {
              typeId = 15376050949367520589 },
            ordinal = {implicit = void} } } } },
    { id = 14883405629196290303,
      displayName = "/usr/local/include/capnp/rpc.capnp:SturdyRef",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 0,
        pointerCount = 2,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "hostId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "objectId",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 1,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 15332985841292492822,
      displayName = "/usr/local/include/capnp/rpc.capnp:Accept",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "provision",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} },
          { name = "embargo",
            codeOrder = 2,
            discriminantValue = 65535,
            slot = {
              offset = 32,
              type = {bool = void},
              defaultValue = {bool = false},
              hadExplicitDefault = false },
            ordinal = {explicit = 2} } } } },
    { id = 10789521159760378817,
      displayName = "/usr/local/include/capnp/rpc.capnp:MessageTarget",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {},
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 2,
        discriminantOffset = 2,
        fields = {
          { name = "importedCap",
            codeOrder = 0,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "promisedAnswer",
            codeOrder = 1,
            discriminantValue = 1,
            slot = {
              offset = 0,
              type = {
                struct = {
                  typeId = 15564635848320162976 } },
              defaultValue = {
                struct = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } },
    { id = 15774052265921044377,
      displayName = "/usr/local/include/capnp/rpc.capnp:Call.sendResultsTo",
      displayNamePrefixLength = 40,
      scopeId = 9469473312751832276,
      struct = {
        dataWordCount = 3,
        pointerCount = 3,
        preferredListEncoding = inlineComposite,
        isGroup = true,
        discriminantCount = 3,
        discriminantOffset = 3,
        fields = {
          { name = "caller",
            codeOrder = 0,
            discriminantValue = 0,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 5} },
          { name = "yourself",
            codeOrder = 1,
            discriminantValue = 1,
            slot = {
              offset = 0,
              type = {void = void},
              defaultValue = {void = void},
              hadExplicitDefault = false },
            ordinal = {explicit = 6} },
          { name = "thirdParty",
            codeOrder = 2,
            discriminantValue = 2,
            slot = {
              offset = 2,
              type = {anyPointer = void},
              defaultValue = {
                anyPointer = opaquePointer },
              hadExplicitDefault = false },
            ordinal = {explicit = 7} } } } },
    { id = 15564635848320162976,
      displayName = "/usr/local/include/capnp/rpc.capnp:PromisedAnswer",
      displayNamePrefixLength = 35,
      scopeId = 12903543124727603792,
      nestedNodes = {
        { name = "Op",
          id = 17516350820840804481 } },
      struct = {
        dataWordCount = 1,
        pointerCount = 1,
        preferredListEncoding = inlineComposite,
        isGroup = false,
        discriminantCount = 0,
        discriminantOffset = 0,
        fields = {
          { name = "questionId",
            codeOrder = 0,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {uint32 = void},
              defaultValue = {uint32 = 0},
              hadExplicitDefault = false },
            ordinal = {explicit = 0} },
          { name = "transform",
            codeOrder = 1,
            discriminantValue = 65535,
            slot = {
              offset = 0,
              type = {
                list = {
                  elementType = {
                    struct = {
                      typeId = 17516350820840804481 } } } },
              defaultValue = {list = opaquePointer},
              hadExplicitDefault = false },
            ordinal = {explicit = 1} } } } } },
  requestedFiles = {
    { id = 12903543124727603792,
      filename = "/usr/local/include/capnp/rpc.capnp",
      imports = {
        { id = 13688829037717245569,
          name = "c++.capnp" } } } } }
