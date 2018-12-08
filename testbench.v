// Test bench
`default_nettype none
`timescale 1ns/1ns //Adjust to suit

module test;
  reg  clk;
  reg  btn;
  wire [4:0] leds;
  wire ws_data;
  top TOP(clk, btn, leds, ws_data);

  parameter PERIOD = 2;

  always
    #(PERIOD/2) clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, TOP);

    // init vars
    clk = 1'b0;
    btn = 1'b1;
    #(PERIOD*100) btn = ~btn;
  end

  initial begin
    $display("Binary Clock");
    $monitor("time: %4d: clk: %0d, btn: %0d, h1:%0d, h0:%0d, m1:%0d, m0:%0d",
      $time, clk, btn, leds[0], leds[1], leds[2], leds[3]);
  end

  initial begin
    #(PERIOD*10000) $finish;
  end

  /* always @ (posedge clk) begin */
  /*   display; */
  /* end */

endmodule
