module CPU (
    input wire clk,
    input wire [15:0] switches,
    input wire reset,
	 output wire [7:0] datamem_outp
);

  wire c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18;
  wire [15:0] instruction;
  wire [ 5:0] cm_writeselect;
  wire [ 5:0] pc;
  codememory_sort cm (
      .c1(c1),
      .readselect(pc),
      .writeselect(cm_writeselect),
      .inp(switches),
      .outp(instruction),
      .clk(clk),
      .reset(reset)
  );
  wire [26:0] control_in;
  opCodeDecoder op (
      .Y (control_in),
      .Inp (instruction[15:8]),
      .En(1'b1)
  );
  wire [3:0] ALU_flags;
  control ctrl (
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
      .c11(c11),
      .c12(c12),
      .c13(c13),
      .c14(c14),
      .c15(c15),
      .c16(c16),
      .c17(c17),
      .c18(c18)
  );
  wire [7:0] regfile_inp;
  wire [7:0] regfile_outp1, regfile_outp2;
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
  wire [7:0] ALU_outp;
  wire [3:0] ALU_f;
  ALU alu (
      .X(regfile_outp1),
      .Y((c11) ? instruction[7:0] : regfile_outp2),
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
  defparam fr.n=4;
  wire [7:0] ALU_res_MUX;
  assign ALU_res_MUX = (c15) ? instruction[7:0] : ALU_outp;
  assign cm_writeselect = ALU_res_MUX[5:0];
  
  assign regfile_inp = (c18) ? datamem_outp : ALU_res_MUX;
  datamemory_sort dm (
      .c17(c17),
      .readselect(ALU_res_MUX[3:0]),
      .writeselect(ALU_res_MUX[3:0]),
      .inp((c16) ? switches[7:0] : regfile_outp2),
      .outp(datamem_outp),
      .clk(clk),
      .reset(reset)
  );
  wire [5:0] pc_out1, pc_out2;
  PC_updatelogic pcu (
      .currentaddress(pc),
      .offset(instruction[5:0]),
      .outp0(pc_out1),
      .outp1(pc_out2)
  );
  register pcr (
      .a((c2) ? pc_out2 : pc_out1),
      .b(pc),
      .clk(clk),
      .en(c3),
      .reset(reset)
  );
  defparam pcr.n=6;

endmodule
