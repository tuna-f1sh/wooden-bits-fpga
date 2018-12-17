# FPGA Binary Clock

In attempt to get started with FPGAs and Verilog, I decided to port [Wooden
Bits](https://github.com/tuna-f1sh/wooden-bits) to a Lattice IceStick.
Counters and flip-flops are the first thing one learns when staring with FPGA
design so the project lends itself naturally. I learnt things FPGAs are good
at and things they are not so good at - best done on a microcontroller. As the
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
to cement what is actually going on when accessing registers when developing
embedded software.

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

* Falstad image

It's good to start with a logic diagram of what one is trying to acheive so I
drew one up in [Falstad](http://www.falstad.com/circuit/circuitjs.html)
([import this
file](https://raw.githubusercontent.com/tuna-f1sh/wooden-bits-fpga/master/falstad.txt)).
To implement this, I designed a counter module for each digit that is
asynchronous (reset on reset edge), so that the reset line can directly feed
the next digit module. Initially, my approach was synchronous (read reset on
clk edge) but this meant having to have a 'carry' output on reset to clock the
other digits at the correct time (otherwise they would clock one digit ahead
of the desired value).

* Changing from syncronous to async means reset signal cannot be seen in test
  bench due to it being directly wired via an OR gate to each flip-flop clk
  input and the bits clearing on the same instant (like the Falstad model).

* Images of test bench for carry version, rst async and rst sync

Interestingly, one could use a single counter register rather than individual
modules. I [developed an
alternative](https://github.com/tuna-f1sh/wooden-bits-fpga/blob/master/binary_clock.v)
based on this idea, using bit logic to clear/increment bit addresses. The
advantage is that it only uses 13 bits rather than 16 bits. Other than this,
the modular system should generate down to the same thing (something that
looks like the Falstad simulation), since the reset inputs driving each module are just
_wire_ bit logic as in the massive `if, else`. I think having modules for each
digit helps with readability.

* Code variants

For development, the clock input to the first Flip-Flop is taken from a
divided down master clock (12 MHz) to form a 1 Hz clock. For actual deployment
on the bench, I added an additional clock input pin for driving from an external
1 Hz clock generator such as can be found on RTCs.

* gif of clock generator

## WS2812 LED Matrix

My original design uses sixteen one-wire WS2812 LEDs chained through the
laser-cut wood to form an addressable LED matrix. WS2812 LEDs simplify wiring
and hardware complexity over standard LEDs, at the cost of CPU cycles: The
one-wire interface sends 24 bit colour data for each LED by modulating the
period of high/low in a serial data stream. Each LED takes the first 24 bits,
then sends forwards the rest of the data to the next in line. Since
microcontrollers don't have a peripheral designed to do this, it is normally
done using Timers and match/overflow interrupt routines.

An FPGA can make light work of this however and my real interest peaked with
the idea that one can make a WS2812 _peripheral_ with no processor overhead.

The binary clock face only needs to set LEDs on or off. I created [a
fork](https://github.com/tuna-f1sh/ws2812-core) of
Matt Venn's WS2812 module that can access the LED colour register directly so that the
code then does a mask operation using the digit registers on each update of
the digits (1 Hz in standard operation). The main real overhead driving the
LEDs is the size of the colour register that is 24 * N bits, where N is the
number of LEDs. This is because the FPGA must latch this data because it change
change on different clock sources.

## Clock Features

### Set Button

The set button was easy to port: I added an input to the top module connected
to a IO pin for button. If the button is pressed, the clock source to the
first counter flip-flop changes to one that is running at 1000 Hz and
the display colour changes red. Releasing the button returns the clock to the
normal state. This allows a user to quickly advance the clock to the
correct time.

Whilst it was an easy port, the user interraction is much less refined then on
the software version. My embedded design features a delay before advancing at
accelerated time so one can button press through minutes when near the correct time, or
hold the button to advance quickly. It will also wait in set mode for a few
seconds on release before setting the new time. Additionally, the set button
can be used to set the main display colour.

These advanced interaction would all be possible on the FPGA but the design
would become somewhat messy and it would need to be carefully thoughtout as to
avoid FPGA bad practices (there are some big pitfalls I have found!). My take
away was that these kind of user interaction features are better done in
software - there is minimal overhead compared to driving the LEDs and it is
very quick to implement.

### Rainbow Colour Cycle

My original clock also fills the display with a rainbow colour
routine at midday and midnight. Implementing this on the IceStick became quite
challenging as I quickly overran the 1280 LUTS (basically combinational logic). I think this was due to
setting a RGB colour for each LED in the colour register, where as before it
was just an option between two colours based on whether a bit was high or low.
Without the rainbow effect, the sythesis was a simple logic mask but with the
addition of full 24 bit colour at run time, it would require much more
complicated logic. In addition, the routine works using a pseudo colour wheel
that also adds complexity to the logic synthesis.

Encounting these sorts of problems are useful when learning a new topic.
Whilst the base project itself is quite simple, adding in these sorts of
features brings up challenges that require further reading. I _just_ managed
to squeeze the rainbow effect, after finding areas of optimisation in logic
statements and [transparent
latches](https://www.doulos.com/knowhow/verilog_designers_guide/synthesizing_latches/).
