module CPU_mc (
    input wire clk,
    input wire [15:0] switches,
    input wire reset,
	 output wire [7:0] datamem_outp
);

  wire c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11_1, c11_2, c12, c13, c14, c15, c16, c17, c18,c19,cmove,c21;
  wire [15:0] instruction_i,instruction;
  wire [ 5:0] cm_writeselect;
  wire [ 5:0] pc;
  codememory_sort cm (
      .c1(c1),
      .readselect(pc),
      .writeselect(cm_writeselect),
      .inp(switches),
      .outp(instruction_i),
      .clk(clk),
      .reset(reset)
  );
  register cmemr (
      .a(instruction_i),
      .b(instruction),
      .clk(clk),
		.en(c19),
      .reset(reset)
  ); defparam cmemr.n=16;
//----------------------------------------------------------------------------
  wire [26:0] control_in;
  opCodeDecoder op (
      .Y (control_in),
      .Inp (instruction[15:8]),
      .En(1'b1)
  );
  wire [3:0] ALU_flags;
  control_mc ctrl (
      .inp(control_in),
      .flags(ALU_flags),
      .c1(c1),
      .c2(c2),
      .c3(c3),
      .c4(c4),
      .c5(c5),
      .c6(c6),
      .c7(c7),
      .c8(c8),
      .c9(c9),
      .c10(c10),
      .c11_1(c11_1),
		.c11_2(c11_2),
      .c12(c12),
      .c13(c13),
      .c14(c14),
      .c15(c15),
      .c16(c16),
      .c17(c17),
      .c18(c18),
		.c19(c19),
		.c21(c21),
		.cmove(cmove),
		.reset(reset),
		.clk(clk)
  );
//-----------------------------------------------------------------------------
  wire [7:0] regfile_inp;
  wire [7:0] regfile_outp1, regfile_outp2 , regfile_r1_outp,regfile_r2_outp;
  registerfile rf (
      .c10(c10),
      .readselect1({c4, c5}),
      .readselect2({c6, c7}),
      .writeselect({c8, c9}),
      .inp(regfile_inp),
      .outp1(regfile_outp1),
      .outp2(regfile_outp2),
      .clk(clk),
      .reset(reset)
  );
  register A (
      .a(regfile_outp1),
      .b(regfile_r1_outp),
      .clk(clk),
      .en(1'b1),
      .reset(reset)
  ); defparam A.n=8;
  register B (
      .a(regfile_outp2),
      .b(regfile_r2_outp),
      .clk(clk),
      .en(1'b1),
      .reset(reset)
  ); defparam B.n=8;
  
//  assign c2MUX = (c2) ? {2'b00, pc} : regfile_r1_outp;
  
  wire [7:0] ALU_outp,ALUr_outp;
  wire [3:0] ALU_f;
  ALU alu (
		.X((c2) ? {2'b00, pc} : ((cmove)? instruction[7:0] : regfile_r1_outp)),
      .Y((c11_2) ? 8'b00000001 :((c11_1) ? instruction[7:0] : regfile_r2_outp)),
      .ALU_SELECT1(c12),
      .ALU_SELECT0(c13),
      .ALU_RESULT(ALU_outp),
      .ALU_FLAGS(ALU_f)
  );
  register fr (
      .a(ALU_f),
      .b(ALU_flags),
      .clk(clk),
      .en(c14),
      .reset(reset)
  );
  register aluout (
      .a(ALU_outp),
      .b(ALUr_outp),
      .clk(clk),
      .en(1'b1),
      .reset(reset)
  );
  defparam aluout.n=8;
  defparam fr.n=4;

  wire [7:0] ALU_res_MUX;
  assign ALU_res_MUX = (c15) ? instruction[7:0] : ALUr_outp;
  assign cm_writeselect = ALU_res_MUX[5:0];
  wire [7:0] dmemr_outp;
  assign regfile_inp = (c18) ? dmemr_outp : ALU_res_MUX;

  datamemory_sort dm (
      .c17(c17),
      .readselect(ALU_res_MUX[3:0]),
      .writeselect(ALU_res_MUX[3:0]),
      .inp((c16) ? switches[7:0] : regfile_r1_outp),
      .outp(datamem_outp),
      .clk(clk),
      .reset(reset)
  );
  register dmemr(
      .a(datamem_outp),
      .b(dmemr_outp),
      .clk(clk),
      .en(1'b1),
      .reset(reset)
  );
  defparam dmemr.n = 8;

  register pcr (
      .a( (c21) ? ALUr_outp[5:0] : ALU_outp[5:0] ),
      .b(pc),
      .clk(clk),
      .en(c3),
      .reset(reset)
  );
  defparam pcr.n=6;

endmodule