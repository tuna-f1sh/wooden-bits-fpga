module counter(
  input clk,
  input rst,
  output cry,
  output [BITS-1:0] digit);

  parameter BITS = 4;

  reg [BITS-1:0] nyble = 0;
  reg carry = 1'b0;
  assign digit = nyble;
  assign cry = carry;

  always @ (posedge clk) begin
    nyble <= (rst & 1'b1) ? 0 : nyble + 1;
    carry <= (rst & 1'b1);
  end

endmodule
