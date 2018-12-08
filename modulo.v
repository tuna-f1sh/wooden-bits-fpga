module modulo(
  input clk,
  input rst,
  output mod,
  output [3:0] digit);

  reg [3:0] nyble = 4'b0;
  reg carry = 1'b0;
  assign digit = nyble;
  assign mod = carry;

  always @ (posedge clk) begin
    nyble <= (rst & 1'b1) ? 4'b0 : nyble + 1;
    carry <= (rst & 1'b1);
  end

endmodule
