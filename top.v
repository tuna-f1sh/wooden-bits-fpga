module top(hwclk, led1, led2, led3, led4);
  /* I/O */
  input hwclk;
  output led1;
  output led2;
  output led3;
  output led4;

  /* 1 Hz clock generation (from 12 MHz) */
  reg clk_1 = 0;
  reg [31:0] cntr_1 = 32'b0;
  /* parameter period_1 = 6000000; */
  parameter period_1 = 60;

  /* LED drivers */
  reg [3:0] d0 = 4'b0;
  assign led1 = d0[0];
  assign led2 = d0[1];
  assign led3 = d0[2];
  assign led4 = d0[3];

  /* main clock divides down for utility clocks */
  always @ (posedge hwclk) begin
    /* generate 1 Hz clock */
    cntr_1 <= cntr_1 + 1;
    if (cntr_1 == period_1) begin
      clk_1 <= ~clk_1;
      cntr_1 <= 32'b0;
    end
  end

  always @ (posedge clk_1) begin
    d0 <= ((d0 & 9) == 9) ? 4'b0 : d0 + 1;
  end

endmodule
