# Makefile adapted from https://github.com/cliffordwolf/icestorm/blob/master/examples/icestick/Makefile
# Adapted for my needs J.Whittingotn 2018
#
# The following license is from the icestorm project and specifically applies to this file only:
#
#  Permission to use, copy, modify, and/or distribute this software for any
#  purpose with or without fee is hereby granted, provided that the above
#  copyright notice and this permission notice appear in all copies.
#
#  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
#  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
#  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
#  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
#  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
#  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

PROJ = top
# PROJ = binary_clock

# Remember to change WS2812 main clock expected speed if switching devices!
HARDWARE = icestick
# HARDWARE = tinyfpga-bx

BUILD = ./build

ifeq ($(HARDWARE),icestick)
  PIN_DEF = icestick.pcf
  ICE_DEVICE    = lp1k
  ARA_DEVICE    = 1k
  FOOTPRINT = tq144
  PROG_CMD = iceprog
endif

ifeq ($(HARDWARE),tinyfpga-bx)
  PIN_DEF = tinyfpga.pcf
  ICE_DEVICE = lp8k
  ARA_DEVICE = 8k
  FOOTPRINT = cm81
  PROG_CMD = tinyprog -p
endif

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
	yosys -p 'synth_ice40 -top $(PROJ) -blif $(BUILD)/$@' $<

%.asc: %.blif
	arachne-pnr -d $(ARA_DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$@ -p $(PIN_DEF) $(BUILD)/$^

%.bin: %.asc
	icepack $(BUILD)/$< $(BUILD)/$@

%.rpt: %.asc
	icetime -d $(ICE_DEVICE) -mtr $(BUILD)/$@ $(BUILD)/$<

%_tb: %_tb.v %.v
	iverilog -o $(BUILD)/$@ $^

%_tb.vcd: %_tb
	vvp -N $(BUILD)/$< +vcd=$@

%_syn.v: $(BUILD)/%.blif
	yosys -p 'read_blif -wideports $^; write_verilog $@'

%_syntb: %_tb.v %_syn.v
	iverilog -o $(BUILD)/$@ $^ `yosys-config --datdir/ice40/cells_sim.v`

%_syntb.vcd: %_syntb
	vvp -N $(BUILD)/$< +vcd=$@

prog: $(PROJ).bin
	$(PROG_CMD) $(BUILD)/$<

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(PROG_CMD) $<

test: $(PROJ)_tb.vcd

clean:
	rm -f $(BUILD)/*

.PHONY: all prog clean test
