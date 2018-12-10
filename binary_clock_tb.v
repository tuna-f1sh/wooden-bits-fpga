// Test bench
`default_nettype none
`timescale 1ns/1ns //Adjust to suit

module test;
  reg  clk;
  reg  reset;
  reg  ce;
  wire  [13:0] count;
  binary_clock BCLOCK(clk, reset, ce, count);

  always
    #1 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, BCLOCK);

    // init vars
    clk = 1'b0;
    ce = 1'b1;
    reset = 1'b1;

    #2 reset <= 1'b0;
  end

  initial begin
    wait(BCLOCK.d3 == 2 & BCLOCK.d2 == 3);
    wait(BCLOCK.d3 == 0 & BCLOCK.d2 == 0);
    wait(BCLOCK.d3 == 2 & BCLOCK.d2 == 3);
    $finish;
  end

  /* always @ (posedge clk) begin */
  /*   display; */
  /* end */

endmodule
