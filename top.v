`include "modulo.v"

module top(hwclk, led1, led2, led3, led4);
  /* I/O */
  input hwclk;
  output led1;
  output led2;
  output led3;
  output led4;

  /* 1 Hz clock generation (from 12 MHz) */
  reg clk_1 = 1'b0;
  reg [31:0] cntr_1 = 32'b0;
  /* parameter period_1 = 6000000; */
  parameter period_1 = 1;

  wire [3:0] dm0;
  wire rst_m0 = ((dm0 & 9) == 9);
  modulo m0(clk_1, rst_m0, dm0);

  /* LED drivers */
  assign led1 = dm0[0];
  assign led2 = dm0[1];
  assign led3 = dm0[2];
  assign led4 = dm0[3];

  /* main clock divides down for utility clocks */
  always @ (posedge hwclk) begin
    /* generate 1 Hz clock */
    cntr_1 <= cntr_1 + 1;
    if (cntr_1 == period_1) begin
      clk_1 <= ~clk_1;
      cntr_1 <= 32'b0;
    end
  end

  /* always @ (posedge clk_1) begin */
  /*   if (dm0 == 9) begin */
  /*     rst_m0 <= 1'b1; */
  /*   end else begin */
  /*     rst_m0 <= 1'b0; */
  /*   end */
  /* end */

endmodule
