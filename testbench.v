// Test bench
`default_nettype none
`timescale 1ns/1ns //Adjust to suit

module test;
  reg  clk;
  wire led1, led2, led3, led4;
  top TOP(clk,led1,led2,led3,led4);

  parameter PERIOD = 2;

  always
    #(PERIOD/2) clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, TOP);

    // init vars
    clk = 1'b0;
  end

  initial begin
    $display("Binary Clock");
    $monitor("time: %d: clk: %0h, led1:%0h, led2:%0h, led3:%0h, led4:%0h",
      $time, clk, led1, led2, led3, led4);
  end

  initial begin
    #(PERIOD*1000) $finish;
  end

  /* always @ (posedge clk) begin */
  /*   display; */
  /* end */

  task display;
    $display("clk: %0h, led1:%0h, led2:%0h, led3:%0h, led4:%0h",
      clk, led1, led2, led3, led4);
  endtask

endmodule
