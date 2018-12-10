`include "counter.v"
`include "ws2812-core/ws2812.v"

module top(
  input CLK,
  input BTN,
  output [4:0] LED, 
  output WS2812_DATA);

  localparam NUM_LEDS = 16;
  parameter MAIN_CLK = 12000000;

  /* reset WS2812s on first clock */
  reg reset = 1;

  /* 1 Hz clock generation (from 12 MHz) */
  reg clk_1 = 1'b0;
  reg [31:0] cntr_1 = 32'b0;
  reg clk_2 = 1'b0;
  reg [15:0] cntr_2 = 16'b0;
  parameter period_1 = MAIN_CLK / 2;
  parameter period_2 = MAIN_CLK / 2000000;
  
  /* seconds (4 and 3 bits but leave all) */
  wire [3:0] ds0;
  wire rst_ds0 = (ds0[1] & ds0[3] | reset); // 10
  counter s0(clk_1, rst_ds0, ds0);
  wire [3:0] ds1;
  wire rst_ds1 = (ds1[1] & ds1[2] | reset); // 6(0) minutes
  counter s1(rst_ds0, rst_ds1, ds1);

  /* minutes (4 and 3 bits but leave all) */
  wire [3:0] dm0;
  wire rst_dm0 = (dm0[1] & dm0[3] | reset); // 10
  counter m0(rst_ds1, rst_dm0, dm0);
  wire [3:0] dm1;
  wire rst_dm1 = (dm1[1] & dm1[2] | reset); // 6(0) minutes
  counter m1(rst_dm0, rst_dm1,  dm1);

  /* hours (4 and 2 bits but leave all) */
  wire [3:0] dh0;
  wire rst_dh0 = ((dh0[1] & dh0[3]) | rst_dh1 | reset); // 10 or tens of hour reset
  counter h0(rst_dm1, rst_dh0, dh0);
  wire [3:0] dh1;
  wire rst_dh1 = (dh1[1] & dh0[2] | reset); // 2(0) & 4 hours
  counter h1(rst_dh0, rst_dh1, dh1);

  /* LED drivers */
  assign LED = ds0;

  /* main clock divides down for utility clocks (will use RTC square wave
  * 1 Hz) */
  always @ (posedge CLK) begin
    /* generate 1 Hz clock */
    cntr_1 <= cntr_1 + 1;
    cntr_2 <= cntr_2 + 1;

    if (~BTN) begin
      if (cntr_1 == period_2) begin
        clk_1 <= ~clk_1;
        cntr_1 <= 32'b0;
      end
    end else begin
      if (cntr_1 == period_1) begin
        clk_1 <= ~clk_1;
        cntr_1 <= 32'b0;
      end
    end

    if (cntr_2 == period_2) begin
      clk_2 <= ~clk_2;
      cntr_2 <= 16'b0;
    end

  end

  // ws2812 driver bits
  reg [24 * NUM_LEDS - 1:0] led_rgb_data = 0;
  reg [7:0] green = 8'h00;
  reg [7:0] blue = 8'h00;
  reg [7:0] red = 8'h00;
  // write rgb into 24 bit colour
  wire [23:0] display_rgb = {green, red, blue};
  reg [7:0] wheel = 0;
  reg rainbow = 0;
  reg [3:0] led_num = 0;
  
  // wire of digits, arranged for display
  wire [NUM_LEDS - 1:0] led_matrix;
  assign led_matrix = {dh1, dh0, dm1, dm0};

  integer i;

  always @ (posedge clk_2) begin
    // clear WS2812 reset
    reset <= 0;

    // set these evene when not using so they don't transparent latch
    led_num <= led_num + 1;
    rainbow <= 0;

    // set first flip-flop clock based on button state
    if (~BTN) begin
      red <= 8'h10; green <= 8'h00; blue <= 8'h00;
    // rainbow display if midday or midnight
    end else if (~|{dh1, dh0, dm1, dm0} || (dh1[0] && dh0[1] && ~|{dm1, dm0})) begin
      rainbow <= 1;
      red <= 8'h10; green <= 8'h10; blue <= 8'h00;
    // or just show clock
    end else begin
      red <= 8'h10; green <= 8'h10; blue <= 8'h10;
    end

    if (led_num == NUM_LEDS - 1) begin
      wheel <= wheel + 1;
    end

    for (i=0; i<NUM_LEDS; i=i+1) begin
      led_rgb_data[24 * i +: 24] <= (led_matrix[i] | rainbow) ? display_rgb : 24'h00_00_00;
    end
  end

  task colour_wheel; begin
    if (wheel < 85) begin
      red <= (255 - wheel * 3);
      green <= 0;
      blue <= wheel * 3;
    end else if (wheel < 170)  begin
      red <= 0;
      green <= (wheel - 85) * 3;
      blue <= (255 - (wheel - 85) * 3);
    end else begin
      red <= (wheel - 170) * 3;
      green <= (255 - (wheel - 170)* 3);
      blue <= 0;
    end
  end endtask

  ws2812 #(.NUM_LEDS(NUM_LEDS), .CLK_MHZ(MAIN_CLK / 1000000)) ws2812_inst(.data(WS2812_DATA), .clk(CLK), .reset(reset), .packed_rgb_data(led_rgb_data));

endmodule
