`timescale 1ns / 1ps

module testbench;
  reg clk;
  reg reset;
  wire [7:0] bluff; 

  // Instantiate the top module
  CPU uut(clk, 16'b0000000000000000, reset, bluff);

  always #5 clk = ~clk;

  initial begin
    clk   = 0;
    reset = 1;

    #20;
    reset = 0;

    #6767;
    $finish;
  end

  // FIXED: Changed 'dmem_inst' to 'dm' to match your CPU instance name
  wire [7:0] m0 = uut.dm.c_o[0];
  wire [7:0] m1 = uut.dm.c_o[1];
  wire [7:0] m2 = uut.dm.c_o[2];
  wire [7:0] m3 = uut.dm.c_o[3];
  wire [7:0] m4 = uut.dm.c_o[4];
  wire [7:0] m5 = uut.dm.c_o[5];
  wire [7:0] m6 = uut.dm.c_o[6];
  wire [7:0] m7 = uut.dm.c_o[7];

  // Check if the array is sorted in ascending order
  wire is_sorted = (m0 <= m1) && (m1 <= m2) && (m2 <= m3) && (m3 <= m4) && (m4 <= m5) && (m5 <= m6) && (m6 <= m7);

  always @(posedge clk) begin
    if (!reset) begin
      if (is_sorted) begin
        $display("The array is sorted in ascending order.");
        $display("Final Execution Time: %0t", $time);

        #20;
        $finish;
      end
    end
  end

endmodule