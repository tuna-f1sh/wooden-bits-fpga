`include "modulo.v"
`include "ws2812-core/ws2812.v"

module top(
  input hwclk, 
  output [4:0] LED, 
  output ws_data);

  localparam NUM_LEDS = 16;

  /* reset WS2812s on first clock */
  reg reset = 1;

  /* 1 Hz clock generation (from 12 MHz) */
  reg clk_1 = 1'b0;
  reg [31:0] cntr_1 = 32'b0;
  parameter period_1 = 6000000;
  parameter period_2 = 3000;
  
  /* seconds (4 and 3 bits but leave all) */
  wire [3:0] ds0;
  wire rst_ds0 = (ds0[0] & ds0[3]); // 9
  wire mod_ds0;
  modulo s0(clk_1, rst_ds0, mod_ds0, ds0);
  wire [3:0] ds1;
  wire rst_ds1 = (ds1[0] & ds1[2]); // 5(0) minutes
  wire mod_ds1;
  modulo s1(mod_ds0, rst_ds1, mod_ds1,  ds1);

  /* minutes (4 and 3 bits but leave all) */
  wire [3:0] dm0;
  wire rst_dm0 = (dm0[0] & dm0[3]); // 9
  wire mod_dm0;
  modulo m0(mod_ds1, rst_dm0, mod_dm0, dm0);
  wire [3:0] dm1;
  wire rst_dm1 = (dm1[0] & dm1[2]); // 5(0) minutes
  wire mod_dm1;
  modulo m1(mod_dm0, rst_dm1, mod_dm1,  dm1);

  /* hours (only needs 2 bits) */
  wire [3:0] dh0;
  wire rst_dh0 = ((dh0[0] & dh0[3]) | rst_dh1); // 9 or tens of hour reset
  wire mod_dh0;
  modulo h0(mod_dm1, rst_dh0, mod_dh0, dh0);
  wire [3:0] dh1;
  wire rst_dh1 = (dh1[1] & dh0[0] & dh0[1]); // 2(0) & 3 hours
  wire mod_dh1;
  modulo h1(mod_dh0, rst_dh1, mod_dh1, dh1);

  /* LED drivers */
  assign LED = ds0;

  /* main clock divides down for utility clocks (will use RTC square wave
  * 1 Hz) */
  always @ (posedge hwclk) begin
    /* generate 1 Hz clock */
    cntr_1 <= cntr_1 + 1;
    if (cntr_1 == period_1) begin
      clk_1 <= ~clk_1;
      cntr_1 <= 32'b0;
    end
  end

  reg [23:0] display_rgb = 24'h10_10_10;
  wire [6 * 4 - 1:0] digits;
  reg [NUM_LEDS - 1:0] led_mask;
  integer i;

  assign digits = {dh1, dh0, dm1, dm0, ds1, ds0};
  assign led_mask = {dm1, dm0, ds1, ds0}; // need to turn off too

  always @ (posedge clk_1) begin
    reset <= 0;
  end

  ws2812 #(.NUM_LEDS(NUM_LEDS)) ws2812_inst(.data(ws_data), .clk(hwclk), .reset(reset), .rgb_colour(display_rgb), .led_mask(led_mask), .write(clk_1));
endmodule
