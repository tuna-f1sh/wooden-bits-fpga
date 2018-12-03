# Project setup
PROJ      = binary
BUILD     = ./build
DEVICE    = 1k
FOOTPRINT = tq144

# Files
FILES = top.v
TESTBENCH = testbench.v

.PHONY: all clean burn test

all:
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(FILES)
	# Place and route using arachne
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p pinmap.pcf $(BUILD)/$(PROJ).blif
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

burn:
	iceprog $(BUILD)/$(PROJ).bin

test:
	iverilog -o demo $(TESTBENCH) $(FILES)
	vvp demo
	# gtkwave dump.vcd

clean:
	rm build/*
