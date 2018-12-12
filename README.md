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
for a simulation of the design.

## WS2812 LED Matrix
