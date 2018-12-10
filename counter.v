module counter(
  input clk,
  input rst,
  output [BITS-1:0] digit);

  parameter BITS = 4;

  reg [BITS-1:0] digit = 0;

  /* always @ (posedge rst) begin */
  /*   nyble <= 0; */
  /* end */

  always @ (posedge clk or posedge rst) begin
    if (rst)
      digit <= 0;
    else
      digit <= digit + 1;
  end

endmodule
