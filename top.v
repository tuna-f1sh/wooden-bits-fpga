`include "counter.v"
`include "ws2812-core/ws2812.v"

module top(
  input CLK,
  input BTN,
  output [4:0] LED, 
  output WS2812_DATA);

  localparam NUM_LEDS = 16;

  /* reset WS2812s on first clock */
  reg reset = 1;

  /* 1 Hz clock generation (from 12 MHz) */
  reg clk_1 = 1'b0;
  reg [31:0] cntr_1 = 32'b0;
  reg clk_2 = 1'b0;
  reg [15:0] cntr_2 = 16'b0;
  parameter period_1 = 6000000;
  parameter period_2 = 6000;
  reg binary_clk;
  
  /* seconds (4 and 3 bits but leave all) */
  wire [3:0] ds0;
  wire rst_ds0 = (ds0[0] & ds0[3]); // 9
  wire mod_ds0;
  counter s0(binary_clk, rst_ds0, mod_ds0, ds0);
  wire [3:0] ds1;
  wire rst_ds1 = (ds1[0] & ds1[2]); // 5(0) minutes
  wire mod_ds1;
  counter s1(mod_ds0, rst_ds1, mod_ds1,  ds1);

  /* minutes (4 and 3 bits but leave all) */
  wire [3:0] dm0;
  wire rst_dm0 = (dm0[0] & dm0[3]); // 9
  wire mod_dm0;
  counter m0(mod_ds1, rst_dm0, mod_dm0, dm0);
  wire [3:0] dm1;
  wire rst_dm1 = (dm1[0] & dm1[2]); // 5(0) minutes
  wire mod_dm1;
  counter m1(mod_dm0, rst_dm1, mod_dm1,  dm1);

  /* hours (4 and 2 bits but leave all) */
  wire [3:0] dh0;
  wire rst_dh0 = ((dh0[0] & dh0[3]) | rst_dh1); // 9 or tens of hour reset
  wire mod_dh0;
  counter h0(mod_dm1, rst_dh0, mod_dh0, dh0);
  wire [3:0] dh1;
  wire rst_dh1 = (dh1[1] & dh0[0] & dh0[1]); // 2(0) & 3 hours
  wire mod_dh1;
  counter h1(mod_dh0, rst_dh1, mod_dh1, dh1);

  /* LED drivers */
  assign LED = ds0;

  /* main clock divides down for utility clocks (will use RTC square wave
  * 1 Hz) */
  always @ (posedge CLK) begin
    /* generate 1 Hz clock */
    cntr_1 <= cntr_1 + 1;
    cntr_2 <= cntr_2 + 1;
    if (cntr_1 == period_1) begin
      clk_1 <= ~clk_1;
      cntr_1 <= 32'b0;
    end
    if (cntr_2 == period_2) begin
      clk_2 <= ~clk_2;
      cntr_2 <= 16'b0;
    end

    if (~BTN) begin
      binary_clk <= clk_2;
      red <= 8'h10; green <= 8'h00; blue <= 8'h00;
    end else begin
      binary_clk <= clk_1;
      red <= 8'h10; green <= 8'h10; blue <= 8'h10;
    end
  end

  reg [24 * NUM_LEDS - 1:0] led_rgb_data = 0;
  reg [7:0] green = 8'h10;
  reg [7:0] blue = 8'h10;
  reg [7:0] red = 8'h10;
  wire [23:0] display_rgb = {green, red, blue};
  
  wire [NUM_LEDS - 1:0] led_matrix;
  integer i;

  assign led_matrix = {dh1, dh0, dm1, dm0};

  always @ (posedge clk_2) begin
    reset <= 0;
    for (i=0; i<NUM_LEDS; i=i+1) begin
      led_rgb_data[24 * i +: 24] <= (led_matrix[i]) ? display_rgb : 24'h00_00_00;
    end
  end

  ws2812 #(.NUM_LEDS(NUM_LEDS), .CLK_MHZ(12)) ws2812_inst(.data(WS2812_DATA), .clk(CLK), .reset(reset), .packed_rgb_data(led_rgb_data));
endmodule
