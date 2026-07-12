module CPU (
    input wire clk,
    input wire [15:0] switches,
    input wire reset,
    output wire [7:0] datamem_outp
);

  wire [19:1] c, ID_EX_c, EX_MEM_c, MEM_WB_c;
  wire [15:0] instruction,IF_ID_instruction,ID_EX_instruction;
  wire [ 5:0] cm_writeselect;
  wire [ 5:0] pc;
  wire [7:0] EX_result;
  
  // Branch signals from EX stage routed back to IF stage mux
  wire [5:0] pc_branch;
  
  // =========================================================================
  // IF STAGE
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
  
  // PC sequential increment
  wire [5:0] pc_seq = pc + 1'b1;
  reg data_stall; //for stall cycle
  always@(*) begin
		data_stall=0;
		if(ID_EX_c[17]) begin
			if(ID_EX_instruction[11:10]==IF_ID_instruction[11:10] || ID_EX_instruction[11:10]==IF_ID_instruction[9:8]) begin
				data_stall =1;
			end
		end
		if ( (IF_ID_instruction[15:13]==4'b111) && ID_EX_c[14]) begin
          data_stall = 1;
      end
  end
  register pcr (
      .a((ID_EX_c[2]) ? pc_branch : pc_seq), // c[2] controls branch target selection
      .b(pc),
      .clk(clk),
      .en(!data_stall),
      .reset(reset)
  );
  defparam pcr.n=6;

  // IF/ID Pipeline Registers
  wire [5:0] IF_ID_pc;
  register IF_ID_pcr (.a(pc), .b(IF_ID_pc), .clk(clk), .en(1'b1), .reset(reset));
  defparam IF_ID_pcr.n=6;
   
  register IF_ID_instruction_reg (.a(ID_EX_c[2] ? 16'b0 : instruction), .b(IF_ID_instruction), .clk(clk), .en(!data_stall), .reset(reset));
  defparam IF_ID_instruction_reg.n=16;
  
  // =========================================================================
  // ID STAGE
  // =========================================================================
  wire [26:0] control_in;
  opCodeDecoder op (
      .Y (control_in),
      .Inp (IF_ID_instruction[15:8]),
      .En(1'b1)
  );
  
  wire [3:0] ALU_flags;
  control ctrl ( 
      .inp(control_in), .flags(ALU_flags), 
      .c1(c[1]),   .c2(c[2]),   .c3(c[3]),   .c4(c[4]),   .c5(c[5]),   .c6(c[6]), 
      .c7(c[7]),   .c8(c[8]),   .c9(c[9]),   .c10(c[10]), .c11(c[11]), .c12(c[12]), 
      .c13(c[13]), .c14(c[14]), .c15(c[15]), .c16(c[16]), .c17(c[17]), .c18(c[18]), .swap_reg(c[19])
  );
  
  wire [7:0] regfile_inp;
  wire [7:0] regfile_outp1, regfile_outp2;
  registerfile rf (
      .c10(MEM_WB_c[10]), // Reg write-enable comes back from WB stage
      .readselect1({IF_ID_instruction[11], IF_ID_instruction[10]}), // RX
      .readselect2({IF_ID_instruction[9],  IF_ID_instruction[8]}),  // RY
      .writeselect({MEM_WB_c[8], MEM_WB_c[9]}),                     // From WB stage
      .inp(regfile_inp),
      .outp1(regfile_outp1),
      .outp2(regfile_outp2),
      .clk(clk),
      .reset(reset)
  );
  
  // ID/EX Pipeline Registers
  wire [5:0] ID_EX_pc;
  register ID_EX_pcr_inst (.a(IF_ID_pc), .b(ID_EX_pc), .clk(clk), .en(1'b1), .reset(reset));
  defparam ID_EX_pcr_inst.n = 6;

  register ID_EX_cr (.a((data_stall||ID_EX_c[2])? 19'b0 :c), .b(ID_EX_c), .clk(clk), .en(1'b1), .reset(reset));
  defparam ID_EX_cr.n = 19;
  
  register ID_EX_inst_reg (.a((data_stall||ID_EX_c[2])? 16'b0 : IF_ID_instruction), .b(ID_EX_instruction), .clk(clk), .en(1'b1), .reset(reset));
  defparam ID_EX_inst_reg.n = 16;
  
  wire [7:0] ID_EX_reg1_out, ID_EX_reg2_out;
  register ID_EX_reg1_reg (.a(regfile_outp1), .b(ID_EX_reg1_out), .clk(clk), .en(1'b1), .reset(reset)); defparam ID_EX_reg1_reg.n=8;
  register ID_EX_reg2_reg (.a(regfile_outp2), .b(ID_EX_reg2_out), .clk(clk), .en(1'b1), .reset(reset)); defparam ID_EX_reg2_reg.n=8;

  // =========================================================================
  // EX STAGE
  // =========================================================================
  reg [7:0] ID_EX_reg1_forw, ID_EX_reg2_forw; //after compensating for data forwarding
  always@(*) begin
    ID_EX_reg1_forw = ID_EX_reg1_out;
	 ID_EX_reg2_forw = ID_EX_reg2_out;
    if(EX_MEM_c[10]) begin //checking if reg write enable is active
		if({EX_MEM_c[8], EX_MEM_c[9]}==ID_EX_instruction[11:10])
			ID_EX_reg1_forw = EX_result;
		if({EX_MEM_c[8], EX_MEM_c[9]}==ID_EX_instruction[9:8])
			ID_EX_reg2_forw = EX_result;
	 end
	 
	 if(MEM_WB_c[10]) begin
		if({MEM_WB_c[8], MEM_WB_c[9]}==ID_EX_instruction[11:10] && {EX_MEM_c[8], EX_MEM_c[9]}!=ID_EX_instruction[11:10])
			ID_EX_reg1_forw = regfile_inp;
		if({MEM_WB_c[8], MEM_WB_c[9]}==ID_EX_instruction[9:8] && {EX_MEM_c[8], EX_MEM_c[9]}!=ID_EX_instruction[9:8])
			ID_EX_reg2_forw = regfile_inp;
	 end
	 
	 
	 
  end
  
  assign pc_branch = ID_EX_pc + 5'b00000 + ID_EX_instruction[5:0]; 
  
  wire [7:0] ALU_outp,swap_reg1,swap_reg2;
  wire [3:0] ALU_f;
  assign swap_reg1 = ID_EX_c[19] ? ID_EX_reg2_forw : ID_EX_reg1_forw;
  assign swap_reg2 = ID_EX_c[19] ? ID_EX_reg1_forw : ID_EX_reg2_forw;
  ALU alu (
      .X(swap_reg1),
      .Y((ID_EX_c[11]) ? ID_EX_instruction[7:0] : swap_reg2), // Fixed control vector & naming
      .ALU_SELECT1(ID_EX_c[12]),
      .ALU_SELECT0(ID_EX_c[13]),
      .ALU_RESULT(ALU_outp),
      .ALU_FLAGS(ALU_f)
  );
  
  register fr (
      .a(ALU_f),
      .b(ALU_flags),
      .clk(clk),
      .en(ID_EX_c[14]),
      .reset(reset)
  );
  defparam fr.n=4;
  
  wire [7:0] ALU_res_MUX;
  assign ALU_res_MUX = (ID_EX_c[15]) ? ID_EX_instruction[7:0] : ALU_outp; // Fixed stage leak
  
  // EX/MEM Pipeline Registers
  register EX_MEM_cr (.a(ID_EX_c), .b(EX_MEM_c), .clk(clk), .en(1'b1), .reset(reset));
  defparam EX_MEM_cr.n = 19;
  
  
  register EX_MEM_alur (.a(ALU_res_MUX), .b(EX_result), .clk(clk), .en(1'b1), .reset(reset));
  defparam EX_MEM_alur.n = 8;
  
  wire [7:0] EX_MEM_reg2_out;
  register EX_MEM_rf2_reg (.a(swap_reg2), .b(EX_MEM_reg2_out), .clk(clk), .en(1'b1), .reset(reset));
  defparam EX_MEM_rf2_reg.n = 8;
  
  // =========================================================================
  // MEM STAGE
  // =========================================================================
  assign cm_writeselect = EX_result[5:0]; // Connected to current stage variable
  
  datamemory_sort dm (
      .c17(EX_MEM_c[17]),
      .readselect(EX_result[3:0]),
      .writeselect(EX_result[3:0]),
      .inp((EX_MEM_c[16]) ? switches[7:0] : EX_MEM_reg2_out), // Fixed stage leakage
      .outp(datamem_outp),
      .clk(clk),
		.reset(reset)
  );
  
  // MEM/WB Pipeline Registers
  wire [7:0] MEM_WB_alu;
  register MEM_WB_alur (.a(EX_result), .b(MEM_WB_alu), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_alur.n = 8;
  
  wire [7:0] MEM_WB_datamem_outp;
  register MEM_WB_datar (.a(datamem_outp), .b(MEM_WB_datamem_outp), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_datar.n = 8; 
  
  register MEM_WB_cr (.a(EX_MEM_c), .b(MEM_WB_c), .clk(clk), .en(1'b1), .reset(reset));
  defparam MEM_WB_cr.n = 19;
  
  // =========================================================================
  // WB STAGE
  // =========================================================================
  assign regfile_inp = (MEM_WB_c[18]) ? MEM_WB_datamem_outp : MEM_WB_alu;

endmodule