module binary_clock(clk, reset, ce, count);
   input clk, reset;
   input ce;  // count enable 
   output [13:0] count; // two digit bcd counter

   reg [13:0] count;
   wire [3:0] d0 = count[3:0];
   wire [2:0] d1 = count[6:4];
   wire [3:0] d2 = count[10:7];
   wire [1:0] d3 = count[12:11];

   always @(posedge clk or posedge reset) begin
      if (reset) begin
         count <= 0;
      end else begin
        if (ce) begin
           if (count[3] & count[0]) begin // 9
              count[3:0] <= 0;
              if (count[6] & count[4]) begin // 5
                count[6:4] <= 0;
                if (count[10] & count[7]) begin // 9
                  count[10:7] <= 0;
                  if (count[12] & count[8] * count[7]) begin // 2 & last 3
                    count[12:11] = 0;
                  end else begin
                    count[12:11] <= count[12:11] + 1;
                  end
                end else begin
                  count[10:7] <= count[10:7] + 1;
                end
              end else begin
                count[6:4] <= count[6:4] + 1;
              end
           end else begin
              count[3:0] <= count[3:0] + 1;
           end
         end
      end
   end
endmodule
