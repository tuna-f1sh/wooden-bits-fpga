// Test bench
`default_nettype none
`timescale 1ns/1ns //Adjust to suit

module test;
  reg  clk;
  reg  btn;
  wire [4:0] leds;
  wire ws_data;
  top #(.MAIN_CLK(2)) TOP(.CLK(clk), .BTN(btn), .LED(leds), .WS2812_DATA(ws_data));

  always #1 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, TOP);

    // init vars
    clk = 1'b0;
    btn = 1'b1;
  end

  initial begin
    $display("Binary Clock Demo Crunching...");
    /* $monitor("time: %4d: clk: %0d, btn: %0d, h1:%0d, h0:%0d, m1:%0d, m0:%0d", */
      /* $time, clk, btn, leds[0], leds[1], leds[2], leds[3]); */
  end

  initial begin
    wait(TOP.dh1 == 2 & TOP.dh0 == 3)
    wait(TOP.dh1 == 0 & TOP.dh0 == 0)
    btn = 1'b0; // test set button advance clock
    $display("testing set button...");
    wait(TOP.dh1 == 2 & TOP.dh0 == 3)
    wait(TOP.dh1 == 0 & TOP.dh0 == 0)
    $finish;
  end

endmodule
