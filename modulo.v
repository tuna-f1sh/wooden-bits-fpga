module modulo(clk, rst, digit);
  input clk, rst;
  output [3:0] digit;

  reg [3:0] nyble = 4'b0;
  assign digit = nyble;

  always @ (posedge clk) begin
    nyble <= (rst & 1'b1) ? 4'b0 : nyble + 1;
  end

endmodule
