module control(
	output reg c1,   // IMEM_WRITE_ENABLE
	output reg c2,   // PROGRAM_COUNTER_MUX
	output reg c3,   // PROGRAM_COUNTER_WRITE_ENABLE
	output reg c4,   // REGISTER_FOUR_SELECT
	output reg c5,   // REGISTER_LXCTY_SELECT (bit 0)
	output reg c6,   // REGISTER_LXCTY_SELECT (bit 1)
	output reg c7,   // REGISTER_LXCTY_SELECT (bit 2)
	output reg c8,  // REGISTER_WRITE_SELECT (bit 0)
	output reg c9,   // REGISTER_WRITE_SELECT (bit 1)
	output reg c10,  // REGISTER_WRITE_ENABLE
	output reg c11,  // ALU_EXECUTE_MUX
	output reg c12,  // ALU_SELECT (bit 0)
	output reg c13,  // ALU_SELECT (bit 1)
	output reg c14,  // FLAGS_WRITE_ENABLE
	output reg c15,  // ALU_RESULT_MUX
	output reg c16,  // DMEM_INPUT_MUX
	output reg c17,  // DMEM_WRITE_ENABLE
	output reg c18,  // DEC_WRITE_MUX

	
	input wire [26:0]inp, // X1 -> inp[23] X0 -> inp[24] Y1 -> inp[25] Y0 -> inp[26]
	input wire [3:0]flags // 3 carry CF, 2 overflow OF, 1 negative flag NF, 0 zero flag ZF
);
	
	localparam NOOP = 23'b00000000000000000000001;
	localparam INPUTC = 23'b00000000000000000000010;
	localparam INPUTCF = 23'b00000000000000000000100;
	localparam INPUTD = 23'b00000000000000000001000;
	localparam INPUTDF = 23'b00000000000000000010000;
	localparam MOVE = 23'b00000000000000000100000;
	localparam LOADI_LOADP = 23'b00000000000000001000000;
	localparam ADD = 23'b00000000000000010000000;
	localparam ADDI = 23'b00000000000000100000000;
	localparam SUB = 23'b00000000000001000000000;
	localparam SUBI = 23'b00000000000010000000000;
	localparam LOAD = 23'b00000000000100000000000;
	localparam LOADF = 23'b00000000001000000000000;
	localparam STORE = 23'b00000000010000000000000;
	localparam STOREF = 23'b00000000100000000000000;
	localparam SHIFTL = 23'b00000001000000000000000;
	localparam SHIFTR = 23'b00000010000000000000000;
	localparam CMP = 23'b00000100000000000000000;
	localparam JUMP = 23'b00001000000000000000000;
	localparam BRE_BRZ = 23'b00010000000000000000000;
	localparam BRNE_BRNZ = 23'b00100000000000000000000;
	localparam BRG = 23'b01000000000000000000000;
	localparam BRGE = 23'b10000000000000000000000;
	
	reg B1, B2, B3, B4;
	
	always@(inp, flags)
	begin
	
		{c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18} = 18'b0;
		
		B1 = flags[0];
		B2 = ~flags[0];
		B3 = (~flags[0])&(flags[1] ~^ flags[2]);
		B4 = flags[1] ~^ flags[2];
		
		case(inp[22:0])
		
			NOOP : c3 = 1'b1;
			
			INPUTC : begin
				c1 = 1'b1;
				c3 = 1'b1;
				c15 = 1'b1;
			end
			
			INPUTCF : begin
				c1 = 1'b1;
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c11 = 1'b1;
				c12 = 1'b1;
			end
			
			INPUTD : begin
				c3 = 1'b1;
				c15 = 1'b1;
				c16 = 1'b1;
				c17 = 1'b1;
			end
			
			INPUTDF : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c11 = 1'b1;
				c12 = 1'b1;
				c16 = 1'b1;
				c17 = 1'b1;
			end
			
			MOVE : begin
				c3 = 1'b1;
				c4 = inp[25];
				c5 = inp[26];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c11 = 1'b1;
				c12 = 1'b1;
			end
			
			LOADI_LOADP : begin
				c3 = 1'b1;
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c15 = 1'b1;
			end
			
			ADD : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c6 = inp[25];
				c7 = inp[26];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c12 = 1'b1;
				c14 = 1'b1;
			end
			
			ADDI : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c11 = 1'b1;
				c12 = 1'b1;
				c14 = 1'b1;
			end
			
			SUB : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c6 = inp[25];
				c7 = inp[26];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c12 = 1'b1;
				c13 = 1'b1;
				c14 = 1'b1;
			end
			
			SUBI : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c11 = 1'b1;
				c12 = 1'b1;
				c13 = 1'b1;
				c14 = 1'b1;
			end
			
			LOAD : begin
				c3 = 1'b1;
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c15 = 1'b1;
				c18 = 1'b1;
			end
			
			LOADF : begin
				c3 = 1'b1;
				c4 = inp[25];
				c5 = inp[26];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c11 = 1'b1;
				c12 = 1'b1;
				c18 = 1'b1;
			end
			
			STORE : begin
				c3 = 1'b1;
				c6 = inp[23];
				c7 = inp[24];
				c15 = 1'b1;
				c17 = 1'b1;
			end
			
			STOREF : begin
				c3 = 1'b1;
				c4 = inp[25];
				c5 = inp[26];
				c6 = inp[23];
				c7 = inp[24];
				c11 = 1'b1;
				c12 = 1'b1;
				c17 = 1'b1;
			end
			
			SHIFTL : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c14 = 1'b1;
			end
			
			SHIFTR : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c8 = inp[23];
				c9 = inp[24];
				c10 = 1'b1;
				c13 = 1'b1;
				c14 = 1'b1;
			end
			
			CMP : begin
				c3 = 1'b1;
				c4 = inp[23];
				c5 = inp[24];
				c6 = inp[25];
				c7 = inp[26];
				c12 = 1'b1;
				c13 = 1'b1;
				c14 = 1'b1;
			end
			
			JUMP : begin
				c2 = 1'b1;
				c3 = 1'b1;
			end
			
			BRE_BRZ : begin
				c2 = B1;
				c3 = 1'b1;
			end
			
			BRNE_BRNZ : begin
				c2 = B2;
				c3 = 1'b1;
			end
			
			BRG : begin
				c2 = B3;
				c3 = 1'b1;
			end
			
			BRGE : begin
				c2 = B4;
				c3 = 1'b1;
			end
			
			default : begin
				c1 = 1'b0;
				c2 = 1'b0;
				c3 = 1'b0;
				c4 = 1'b0;
				c5 = 1'b0;
				c6 = 1'b0;
				c7 = 1'b0;
				c8 = 1'b0;
				c9 = 1'b0;
				c10 = 1'b0;
				c11 = 1'b0;
				c12 = 1'b0;
				c13 = 1'b0;
				c14 = 1'b0;
				c15 = 1'b0;
				c16 = 1'b0;
				c17 = 1'b0;
				c18 = 1'b0;
			end
		endcase
	end
endmodule
				
				
				
				
				
				