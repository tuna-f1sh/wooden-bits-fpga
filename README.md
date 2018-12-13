# 'Wooden Bits' Binary Clock FPGA Port

A port of my binary clock project [Wooden
Bits](https://github.com/tuna-f1sh/wooden-bits) to Verilog, synthesised for
the Lattice IceSitck and TinyFPGA BX.

## Binary Clock Counter Design

A binary clock is essentially a frequency divider, which can be formed using
D-Type Flip-Flops, each data line clocking the next. In order to reset the 4
bit counter at 9 (or the other digits for time), a modulo 9 counter is created
by using an AND gate driving reset on bits 1 and 3 (as it clocks 10). This is
assuming the D-Type is asyncronous (will reset on reset edge). If it were
syncronous, the AND gate must be connected to bits 0 and 3 (9), such that the
reset will be clocked as it would be counting 10. The difference becomes quite
important in Verilog, particulary when driving the next digits with the reset
signal.

Open 'falstad.txt' in [Falstad](http://www.falstad.com/circuit/circuitjs.html)
for a simulation of the design. To implement this, I designed the counter
module to be asyncronous (reset on reset edge), so that the reset line
can directly feed the next digit block. Initially, my approach was syncronous
(read reset on clk edge) but this meant having to have a 'carry' output on reset
to clock the other digits at the correct time (otherwise they would clock one
digit ahead of the desired value).

## WS2812 LED Matrix

The additional challenge of this design (particulary fitting it all in the
1200 LTs of the IceStick), was to drive a WS2812 matrix like _Wooden Bits_.
For this I developed a fork of Matt Venn's [WS2812
module](https://github.com/tuna-f1sh/ws2812-core). My fork allows direct
access to the pseudo RGB register of each LED so that the data can be edged
synronously, ready for the next data cycle.

# Build

* Install icetools, arachne-pnr, yosys, etc.
* Change the device name in the Makefile for the device you want to use.
  **NOTE** one must change the `MAIN_CLK` speed in 'top.v' in addition to
  this.
* `make && make prog`

# Test

```
make test
gtkwave dump.vcd
```
