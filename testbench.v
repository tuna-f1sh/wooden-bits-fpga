// Test bench
`default_nettype none
module test;
  reg  clk;
  wire led1, led2, led3, led4;
  top TOP(clk,led1,led2,led3,led4);


  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, TOP);

    $display("Clock");

  end

  always
    #10 clk = ~clk;

  always @ (posedge clk) begin
    display;
  end

  task display;
    #1 $display("led1:%0h, led2:%0h, led3:%0h, led4:%0h",
      led1, led2, led3, led4);
  endtask

endmodule
