module flag_calculator (
    output wire negative,
    output wire zero,
    input wire [7:0] ALU_RESULT
);

  assign negative = ALU_RESULT[7];
  assign zero = ~|ALU_RESULT;

endmodule

module full_adder (
    output wire s,
    output wire cout,
    input  wire a,
    input  wire b,
    input  wire c
);

  assign s = a ^ b ^ c;
  assign cout = (a & b) | (b & c) | (a & c);

endmodule

module adder_sub (
    output wire [7:0] result,
    output wire carry,
    output wire overflow,
    input wire [7:0] X,
    input wire [7:0] Y,
    input wire sub
);

  wire [8:0] carrys;
  assign carrys[0] = sub;
  full_adder FA0 (
      .s(result[0]),
      .cout(carrys[1]),
      .a(X[0]),
      .b(Y[0] ^ sub),
      .c(carrys[0])
  );
  full_adder FA1 (
      .s(result[1]),
      .cout(carrys[2]),
      .a(X[1]),
      .b(Y[1] ^ sub),
      .c(carrys[1])
  );
  full_adder FA2 (
      .s(result[2]),
      .cout(carrys[3]),
      .a(X[2]),
      .b(Y[2] ^ sub),
      .c(carrys[2])
  );
  full_adder FA3 (
      .s(result[3]),
      .cout(carrys[4]),
      .a(X[3]),
      .b(Y[3] ^ sub),
      .c(carrys[3])
  );
  full_adder FA4 (
      .s(result[4]),
      .cout(carrys[5]),
      .a(X[4]),
      .b(Y[4] ^ sub),
      .c(carrys[4])
  );
  full_adder FA5 (
      .s(result[5]),
      .cout(carrys[6]),
      .a(X[5]),
      .b(Y[5] ^ sub),
      .c(carrys[5])
  );
  full_adder FA6 (
      .s(result[6]),
      .cout(carrys[7]),
      .a(X[6]),
      .b(Y[6] ^ sub),
      .c(carrys[6])
  );
  full_adder FA7 (
      .s(result[7]),
      .cout(carrys[8]),
      .a(X[7]),
      .b(Y[7] ^ sub),
      .c(carrys[7])
  );

  assign carry = carrys[8];
  assign overflow = carrys[7] ^ carrys[8];

endmodule

module shifter (
    output reg [7:0] result,
    output reg shiftout,
    input wire [7:0] X,
    input wire R
);

  always @(*) begin
    if (R == 1'b0) begin
      result   <= X << 1;
      shiftout <= X[7];
    end else begin
      result   <= X >> 1;
      shiftout <= X[0];
    end
  end

endmodule

module ALU (
    output reg [7:0] ALU_RESULT,
    output reg [3:0] ALU_FLAGS,
    input wire [7:0] X,
    input wire [7:0] Y,
    input wire ALU_SELECT1,
    input wire ALU_SELECT0
);

  wire [7:0] s1, s2;
  wire s3, s4, s5;

  shifter SH (
      .result(s1),
      .shiftout(s3),
      .X(X),
      .R(ALU_SELECT0)
  );
  adder_sub AS (
      .result(s2),
      .carry(s4),
      .overflow(s5),
      .X(X),
      .Y(Y),
      .sub(ALU_SELECT0)
  );

  wire flag_negative, flag_zero;
  flag_calculator FC (
      .negative(flag_negative),
      .zero(flag_zero),
      .ALU_RESULT(ALU_RESULT)
  );

  always @(*) begin
    // default values to avoid latches
    ALU_RESULT = 8'b0;
    ALU_FLAGS  = 4'b0000;

    case (ALU_SELECT1)
      1'b0: begin
        ALU_RESULT   = s1;  // Shift operation
        ALU_FLAGS[3] = s3;  // Shift out flag
        ALU_FLAGS[2] = 1'b0;  // No overflow for shift
      end
      1'b1: begin
        ALU_RESULT   = s2;  // Add/Subtract operation
        ALU_FLAGS[3] = s4;  // Carry flag
        ALU_FLAGS[2] = s5;  // Overflow flag
      end
    endcase

    ALU_FLAGS[1] = flag_negative;
    ALU_FLAGS[0] = flag_zero;
  end

endmodule
