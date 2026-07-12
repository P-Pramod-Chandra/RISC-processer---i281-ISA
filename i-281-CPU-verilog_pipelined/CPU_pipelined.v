module CPU_bla (
    input wire clk,
    input wire [15:0] switches,
    input wire reset,
    output wire [7:0] datamem_outp
);

  // Pipeline Control Buses
  wire [18:1] c;          // ID Stage
  wire [18:1] ID_EXE_c;    // EXE Stage
  wire [18:1] EXE_MEM_c;   // MEM Stage
  wire [18:1] MEM_WB_c;    // WB Stage

  wire [15:0] instruction;
  wire [ 5:0] cm_writeselect;
  wire [ 5:0] pc;
  
  // Branch/Jump Resolution Signals from EXE Stage
  wire EXE_branch_taken;
  wire [5:0] EXE_pc_target;
  wire [5:0] pc_next;

  // Flush signal for pipeline stages when a branch is taken
  wire pipeline_flush = EXE_branch_taken;

  // =========================================================================
  // 1. INSTRUCTION FETCH (IF) STAGE
  // =========================================================================
  
  codememory_sort cm (
      .c1(c[1]),
      .readselect(pc),
      .writeselect(cm_writeselect),
      .inp(switches),
      .outp(instruction),
      .clk(clk),
		.reset(reset)
  );
  
  // Sequential next PC calculation
  wire [5:0] pc_seq = pc + 1'b1;
  assign pc_next = (EXE_branch_taken) ? EXE_pc_target : pc_seq;

  register pcr (
      .a(pc_next),
      .b(pc),
      .clk(clk),
      .en(c[3]), // PROGRAM_COUNTER_WRITE_ENABLE
      .reset(reset)
  );
  defparam pcr.n=6;

  // -------------------------------------------------------------------------
  // IF/ID Pipeline Registers (Flushed on Taken Branch)
  // -------------------------------------------------------------------------
  wire [5:0] IF_ID_pc;
  register_flushable IF_ID_pcr_inst (
      .a(pc),
      .b(IF_ID_pc),
      .clk(clk),
      .en(1'b1),
      .flush(pipeline_flush),
      .reset(reset)
  );
  defparam IF_ID_pcr_inst.n=6;
  
  wire [15:0] IF_ID_instruction;
  register_flushable IF_ID_instruction_inst (
      .a(instruction),
      .b(IF_ID_instruction),
      .clk(clk),
      .en(1'b1),
      .flush(pipeline_flush),
      .reset(reset)
  );
  defparam IF_ID_instruction_inst.n=16;
  
  // =========================================================================
  // 2. INSTRUCTION DECODE (ID) STAGE
  // =========================================================================
  
  wire [26:0] control_in;
  opCodeDecoder op (
      .Y (control_in),
      .Inp (IF_ID_instruction[15:8]),
      .En(1'b1)
  );

  wire [3:0] ALU_flags; // From the Flags Register
  control ctrl (
      .inp(control_in),
      .flags(ALU_flags),
      .c1(c[1]),   .c2(c[2]),   .c3(c[3]),   .c4(c[4]),   .c5(c[5]),   .c6(c[6]),
      .c7(c[7]),   .c8(c[8]),   .c9(c[9]),   .c10(c[10]), .c11(c[11]), .c12(c[12]),
      .c13(c[13]), .c14(c[14]), .c15(c[15]), .c16(c[16]), .c17(c[17]), .c18(c[18])
  );
  
  // Register Writeback signals looped back from WB Stage
  wire [7:0] regfile_inp; 
  wire [1:0] WB_writeselect;

  wire [7:0] regfile_outp1, regfile_outp2;
  registerfile rf (
      .c10(MEM_WB_c[10]), // REGISTERS_WRITE_ENABLE from WB Stage
      .readselect1({IF_ID_instruction[11], IF_ID_instruction[10]}), // RX
      .readselect2({IF_ID_instruction[9], IF_ID_instruction[8]}),   // RY
      .writeselect(WB_writeselect), 
      .inp(regfile_inp), 
      .outp1(regfile_outp1),
      .outp2(regfile_outp2),
      .clk(clk),
      .reset(reset)
  );
  
  // -------------------------------------------------------------------------
  // ID/EXE Pipeline Registers (Flushed on Taken Branch)
  // -------------------------------------------------------------------------
  wire [5:0] ID_EXE_pc;
  register_flushable ID_EXE_pcr_reg (
      .a(IF_ID_pc),
      .b(ID_EXE_pc),
      .clk(clk),
      .en(1'b1),
      .flush(pipeline_flush),
      .reset(reset)
  );
  defparam ID_EXE_pcr_reg.n=6;
  
  register_flushable ID_EXE_c_reg (
      .a(c),
      .b(ID_EXE_c),
      .clk(clk),
      .en(1'b1),
      .flush(pipeline_flush),
      .reset(reset)
  );
  defparam ID_EXE_c_reg.n=18;

  wire [15:0] ID_EXE_instruction;
  register_flushable ID_EXE_inst_reg (
      .a(IF_ID_instruction),
      .b(ID_EXE_instruction),
      .clk(clk),
      .en(1'b1),
      .flush(pipeline_flush),
      .reset(reset)
  );
  defparam ID_EXE_inst_reg.n=16;

  wire [7:0] ID_EXE_regfile_outp1, ID_EXE_regfile_outp2;
  register_flushable ID_EXE_rf1 (
      .a(regfile_outp1), .b(ID_EXE_regfile_outp1),
      .clk(clk), .en(1'b1), .flush(pipeline_flush), .reset(reset)
  );
  defparam ID_EXE_rf1.n=8;

  register_flushable ID_EXE_rf2 (
      .a(regfile_outp2), .b(ID_EXE_regfile_outp2),
      .clk(clk), .en(1'b1), .flush(pipeline_flush), .reset(reset)
  );
  defparam ID_EXE_rf2.n=8;

  // =========================================================================
  // 3. EXECUTE (EXE) STAGE
  // =========================================================================
  
  wire [5:0] pc_out1, pc_out2;
  PC_updatelogic pcu (
      .currentaddress(ID_EXE_pc),
      .offset(ID_EXE_instruction[5:0]),
      .outp0(pc_out1),
      .outp1(pc_out2)
  );
  
  // Resolve Branch Target and Decision Condition
  assign EXE_pc_target = (ID_EXE_c[2]) ? pc_out2 : pc_out1;
  
  // Evaluates condition based on your Control Mux configuration
  // Assert branch_taken if instruction is a JUMP or valid conditional branch match
  assign EXE_branch_taken = (ID_EXE_instruction[15:12] == 4'b1101) || // JUMP opcode example
                            (ID_EXE_c[2] && (ID_EXE_instruction[15:12] >= 4'b1110)); 

  wire [7:0] ALU_outp;
  wire [3:0] ALU_f;
  ALU alu (
      .X(ID_EXE_regfile_outp1),
      .Y((ID_EXE_c[11]) ? ID_EXE_instruction[7:0] : ID_EXE_regfile_outp2), // ALU_SOURCE_MUX
      .ALU_SELECT1(ID_EXE_c[12]),
      .ALU_SELECT0(ID_EXE_c[13]),
      .ALU_RESULT(ALU_outp),
      .ALU_FLAGS(ALU_f)
  );
  
  register fr (
      .a(ALU_f),
      .b(ALU_flags),
      .clk(clk),
      .en(ID_EXE_c[14]), // FLAGS_WRITE_ENABLE
      .reset(reset)
  );
  defparam fr.n=4;

  wire [7:0] ALU_res_MUX;
  assign ALU_res_MUX = (ID_EXE_c[15]) ? ID_EXE_instruction[7:0] : ALU_outp; // ALU_RESULT_MUX
  
  // -------------------------------------------------------------------------
  // EXE/MEM Pipeline Registers
  // -------------------------------------------------------------------------
  wire [7:0] EXE_MEM_ALU_res_MUX;
  wire [7:0] EXE_MEM_regfile_outp2;
  wire [15:0] EXE_MEM_instruction;

  register EXE_MEM_c_reg (.a(ID_EXE_c), .b(EXE_MEM_c), .clk(clk), .en(1'b1), .reset(reset));
  defparam EXE_MEM_c_reg.n=18;

  register EXE_MEM_res_reg (.a(ALU_res_MUX), .b(EXE_MEM_ALU_res_MUX), .clk(clk), .en(1'b1), .reset(reset));
  defparam EXE_MEM_res_reg.n=8;

  register EXE_MEM_rf2_reg (.a(ID_EXE_regfile_outp2), .b(EXE_MEM_regfile_outp2), .clk(clk), .en(1'b1), .reset(reset));
  defparam EXE_MEM_rf2_reg.n=8;

  register EXE_MEM_inst_reg (.a(ID_EXE_instruction), .b(EXE_MEM_instruction), .clk(clk), .en(1'b1), .reset(reset));
  defparam EXE_MEM_inst_reg.n=16;

  // =========================================================================
  // 4. MEMORY ACCESS (MEM) STAGE
  // =========================================================================
  
  assign cm_writeselect = EXE_MEM_ALU_res_MUX[5:0];
  wire [7:0] MEM_datamem_outp;

  datamemory_sort dm (
      .c17(EXE_MEM_c[17]), // DMEM_WRITE_ENABLE
      .readselect(EXE_MEM_ALU_res_MUX[3:0]),
      .writeselect(EXE_MEM_ALU_res_MUX[3:0]),
      .inp((EXE_MEM_c[16]) ? switches[7:0] : EXE_MEM_regfile_outp2), // DMEM_INPUT_MUX
      .outp(MEM_datamem_outp),
      .clk(clk),
		.reset(reset)
  );

  // -------------------------------------------------------------------------
  // MEM/WB Pipeline Registers
  // -------------------------------------------------------------------------
  wire [7:0] MEM_WB_ALU_res_MUX;
  wire [15:0] MEM_WB_instruction;

  register MEM_WB_c_reg (.a(EXE_MEM_c), .b(MEM_WB_c), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_c_reg.n=18;

  register MEM_WB_res_reg (.a(EXE_MEM_ALU_res_MUX), .b(MEM_WB_ALU_res_MUX), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_res_reg.n=8;

  register MEM_WB_dm_reg (.a(MEM_datamem_outp), .b(datamem_outp), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_dm_reg.n=8;

  register MEM_WB_inst_reg (.a(EXE_MEM_instruction), .b(MEM_WB_instruction), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_inst_reg.n=16;

  // =========================================================================
  // 5. WRITEBACK (WB) STAGE
  // =========================================================================
  
  // Choose source data and route back to Register File ports in ID stage
  assign regfile_inp = (MEM_WB_c[18]) ? datamem_outp : MEM_WB_ALU_res_MUX; // REG_WRITEBACK_MUX
  assign WB_writeselect = {MEM_WB_c[8], MEM_WB_c[9]}; // REGISTERS_WRITE_SELECT1 & 0

endmodule

// =========================================================================
// Helper Module: Flushable Pipeline Register
// =========================================================================
module register_flushable #(parameter n = 8) (
    input wire [n-1:0] a,
    input wire clk,
    input wire en,
    input wire flush,
    input wire reset,
    output reg [n-1:0] b
);
    always @(posedge clk) begin
        if (reset || flush) begin
            b <= {n{1'b0}};
        end else if (en) begin
            b <= a;
        end
    end
endmodule