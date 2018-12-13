# FPGA Binary Clock

In attempt to get started with FPGAs and Verilog, I decided to port [Wooden
Bits](https://github.com/tuna-f1sh/wooden-bits) to a Lattice IceStick.
Counters and flip-flops are the first thing one learns when staring with FPGA
design so the project lends itself naturally. I learnt things FPGAs are good at
and things they are not so good at, best done on a microcontroller. As the
project was educational, there were many learnings along the way and
invariably still to be learnt; it is not intended as a best use of FPGAs or
implementation.

The most enlightening part of the learning and what finally kicked me to do
the project, was the
[PicoSOC](https://github.com/cliffordwolf/picorv32/tree/master/picosoc)
project and in particular, Matt Venn's addition of a [WS2812 periheral to the
PicoSOC](https://www.youtube.com/watch?v=us2F8wAncw8&t=841s). The idea of
rolling one's own periheral for driving external hardware into a SoC or only
adding the required ones is new ground for me. The concept also really helps
to cement what is actually going on when accessing registers in a language
such as C.

## Binary Clock Counter Design

A binary clock is essentially a frequency divider, which can be formed using
D-Type Flip-Flops, each data line clocking the next. In order to reset the 4
bit counter at 9 (or the other digits for time), a modulo 9 counter is created
by using an AND gate driving reset with bits 1 & 3 (as it clocks 10). This is
assuming the D-Type is asynchronous (will reset on reset edge). If it were
synchronous, the AND gate must be connected to bits 0 & 3 (9), such that the
reset will be clocked as it would be counting 10. The difference becomes quite
important in Verilog, particularly when driving the next digit modules with
the reset signal.

It's good to start with a logic diagram of what one is trying to acheive so I drew one up in [Falstad](http://www.falstad.com/circuit/circuitjs.html) ([import this file](https://raw.githubusercontent.com/tuna-f1sh/wooden-bits-fpga/master/falstad.txt)). To implement this, I designed a counter
module for each digit that is asynchronous (reset on reset edge), so that the reset line can
directly feed the next digit module. Initially, my approach was synchronous
(read reset on clk edge) but this meant having to have a 'carry' output on
reset to clock the other digits at the correct time (otherwise they would
clock one digit ahead of the desired value).

* Changing from syncronous to async means reset signal cannot be seen in test
  bench due to it being directly wired via an OR gate to each flip-flop clk
  input and the bits clearing on the same instant (like the Falstad model).

Interestingly, one could use a single counter register rather than individual
modules. I [developed an
alternative](https://github.com/tuna-f1sh/wooden-bits-fpga/blob/master/binary_clock.v)
based on this idea, using bit logic to clear/increment bit addresses. The
advantage is that it only uses 13 bits rather than 16 bits. Other than this,
the modular system should synthesize down to the same thing, since the reset
inputs driving each module are just _wire_ bit logic as in the massive `if,
else`. I think having modules for each digit helps with readability.

For development, the clock input to the first Flip-Flop is taken from a
divided down master clock (12 MHz) to form a 1 Hz clock. If I were to deploy
it as an actual clock, I would use an external 1 Hz clock generator such as
one found on RTCs.
