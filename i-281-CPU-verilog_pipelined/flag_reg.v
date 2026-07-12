module flag_reg (
    a,
    b,
    clk,
    en,
    reset
);

  parameter n = 3;
  output reg [n:0] b;

  input wire [n:0] a;
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
