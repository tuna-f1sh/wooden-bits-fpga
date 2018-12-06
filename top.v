`include "modulo.v"
`include "ws2812-core/ws2812.v"

module top(hwclk, led1, led2, led3, led4, ws_data);
  /* I/O */
  input hwclk;
  output led1;
  output led2;
  output led3;
  output led4;
  output ws_data;

  reg reset = 1;
  always @(posedge hwclk)
      reset <= 0;

  /* 1 Hz clock generation (from 12 MHz) */
  reg clk_1 = 1'b0;
  reg [31:0] cntr_1 = 32'b0;
  parameter period_1 = 6000000;
  /* parameter period_1 = 1; */
  
  /* seconds */
  wire [3:0] ds0;
  wire rst_ds0 = (ds0[0] & ds0[3]); // 9
  wire carry_ds0;
  modulo s0(clk_1, rst_ds0, carry_ds0, ds0);
  wire [3:0] ds1;
  wire rst_ds1 = (ds1[0] & ds1[2]); // 5(0) minutes
  wire carry_ds1;
  modulo s1(carry_ds0, rst_ds1, carry_ds1,  ds1);

  /* minutes */
  wire [3:0] dm0;
  wire rst_dm0 = (dm0[0] & dm0[3]); // 9
  wire carry_dm0;
  modulo m0(carry_ds1, rst_dm0, carry_dm0, dm0);
  wire [3:0] dm1;
  wire rst_dm1 = (dm1[0] & dm1[2]); // 5(0) minutes
  wire carry_dm1;
  modulo m1(carry_dm0, rst_dm1, carry_dm1,  dm1);

  /* hours */
  wire [3:0] dh0;
  wire rst_dh0 = ((dh0[0] & dh0[3]) | rst_dh1); // 9 or tens of hour reset
  wire carry_dh0;
  modulo h0(carry_dm1, rst_dh0, carry_dh0, dh0);
  wire [3:0] dh1;
  wire rst_dh1 = (dh1[1] & dh0[0] & dh0[1]); // 2(0) & 3 hours
  wire carry_dh1;
  modulo h1(carry_dh0, rst_dh1, carry_dh1, dh1);

  /* LED drivers */
  assign led1 = ds0[0];
  assign led2 = ds0[1];
  assign led3 = ds0[2];
  assign led4 = ds0[3];

  /* main clock divides down for utility clocks */
  always @ (posedge hwclk) begin
    /* generate 1 Hz clock */
    cntr_1 <= cntr_1 + 1;
    if (cntr_1 == period_1) begin
      clk_1 <= ~clk_1;
      cntr_1 <= 32'b0;
    end
  end

  reg [23:0] led_rgb_data = 24'h00_00_00;
  reg [7:0] led_num = 0;
  wire led_write = clk_1;

  always @ (posedge hwclk) begin
    if (~reset) begin
      if ((led_num & 4) == 4) begin
        led_rgb_data <= ds0[0] ? 24'h10_10_10 : 24'h00_00_00;
        led_num <= 0;
      end else
        led_rgb_data <= ds0[led_num+1] ? 24'h10_10_10 : 24'h00_00_00;
        led_num <= led_num + 1;
    end
  end



  ws2812 #(.NUM_LEDS(4)) ws2812_inst(.data(ws_data), .clk(hwclk), .reset(reset), .rgb_data(led_rgb_data), .led_num(led_num), .write(led_write));

endmodule
