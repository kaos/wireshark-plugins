CAPNP = capnp
CAT = /bin/cat
SCHEMA = /usr/local/include/capnp/schema.capnp
TARGET = $(basename $(notdir $(input)))

define MSG =
The purpose of this Makefile is to generate new schemas for the capnp dissector.

Usage:
  make schema input=/path/to/schema-file.capnp

This will produce a plugins/schema-file_capnp.lua source file.
Any types in that schema is then loaded and used automagically
by the capnp protocol dissector.
endef
export MSG

define HEAD =
if not capnp_schema then
   capnp_schema = {}
end

-- fake atoms
local void = "void"
local empty = "empty"
local bit = "bit"
local byte = 1
local twoBytes = 2
local fourBytes = 4
local eightBytes = 8
local pointer = "pointer"
local inlineComposite = "inlineComposite"
local opaquePointer = "opaquePointer"

capnp_schema["$(TARGET)"] =
endef
export HEAD

all:
	@echo "$$MSG"

schema: $(input) plugins/$(TARGET)_capnp.lua

%.lua: Makefile $(input)
	echo "$$HEAD" > $@
	$(CAPNP) compile -o$(CAT) $(input) -I/ |\
	$(CAPNP) decode $(SCHEMA) CodeGeneratorRequest |\
	sed -e 's/[[(]/{/g' -e 's/[])]/}/g' \
		-e 's/<opaque pointer>/opaquePointer/g' \
		-e 's/\([Ii]d = \)\([0-9][0-9]*\)/\1"\2"/g' >> $@
