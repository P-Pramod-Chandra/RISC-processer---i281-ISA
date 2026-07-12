module register (
    a,
    b,
    clk,
    en,
    reset
);

  parameter n = 5;
  output reg [n-1:0] b;

  input wire [n-1:0] a;
  input wire clk;
  input wire en;
  input wire reset;

  always @(posedge clk, posedge reset) begin
    if (reset) b <= 0;
    else if (en == 1'b1) begin
      b <= a;
    end
  end
endmodule