// Test bench
`default_nettype none
`timescale 1ns/1ns //Adjust to suit

module test;
  reg  clk;
  reg  btn;
  wire [4:0] leds;
  wire ws_data;
  /* ws2812 module won't work with main clock at 2 but allows testing of other
  * bits */
  top #(.MAIN_CLK(2)) TOP(.CLK(clk), .CLK_1HZ(clk), .BTN(btn), .LED(leds), .WS2812_DATA(ws_data));

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
  end

  initial begin
    wait(TOP.dh1 == 2 & TOP.dh0 == 3)
    wait(TOP.dh1 == 0 & TOP.dh0 == 0)
    $display("testing set button...");
    btn = 1'b0; // test set button advance clock
    wait(TOP.dh1 == 0 & TOP.dh0 == 5)
    $finish;
  end

endmodule
