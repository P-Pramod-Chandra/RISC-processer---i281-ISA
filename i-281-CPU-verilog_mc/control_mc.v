module control_mc(
	output reg c1,   // IMEM_WRITE_ENABLE
	output reg c2,   // PC_update_signal
	output reg c3,   // PROGRAM_COUNTER_WRITE_ENABLE
	output reg c4,   // REGISTER_FOUR_SELECT
	output reg c5,   // REGISTER_LXCTY_SELECT (bit 0)
	output reg c6,   // REGISTER_LXCTY_SELECT (bit 1)
	output reg c7,   // REGISTER_LXCTY_SELECT (bit 2)
	output reg c8,  // REGISTER_WRITE_SELECT (bit 0)
	output reg c9,   // REGISTER_WRITE_SELECT (bit 1)
	output reg c10,  // REGISTER_WRITE_ENABLE
	output reg c11_1,  // incresment by 1 for pc
	output reg c11_2,  // ALU_EXECUTE_MUX
	output reg c12,  // ALU_SELECT (bit 0)
	output reg c13,  // ALU_SELECT (bit 1)
	output reg c14,  // FLAGS_WRITE_ENABLE
	output reg c15,  // ALU_RESULT_MUX
	output reg c16,  // DMEM_INPUT_MUX
	output reg c17,  // DMEM_WRITE_ENABLE
	output reg c18,  // DEC_WRITE_MUX
	output reg cmove, 
	output reg c19,
	output reg c21,
	
	input wire [26:0]inp, // X1 -> inp[23] X0 -> inp[24] Y1 -> inp[25] Y0 -> inp[26]
	input wire [3:0]flags, // 3 carry CF, 2 overflow OF, 1 negative flag NF, 0 zero flag ZF
	input wire reset,
	input wire clk
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
	
	wire B1, B2, B3, B4;
	assign B1 = flags[0];
	assign B2 = ~flags[0];
	assign B3 = (~flags[0])&(flags[1] ~^ flags[2]);
	assign B4 = flags[1] ~^ flags[2];
	
	parameter fetch = 4'b0000, decode = 4'b0001, cycle1 = 4'b0010, cycle2 = 4'b0011, cycle3 = 4'b0100;
	reg [3:0]y,Y;
	
	always @(posedge clk , posedge reset) begin
		if(reset) y <= fetch;
		else y<=Y;
	end 
	
	always @(inp,flags,y,B1,B2,B3,B4) begin
		{c1, c2, c3, c8, c9, c10, c11_1 , c11_2 , c12, c13, c14, c15, c16, c17, c18, c19 , cmove,c21} = 18'b0;
		{c7,c6,c5,c4} = inp[26:23];
		Y=fetch;
		case (y)
			fetch : begin //fine
				{c12,c13}=2'b10;
				c19=1'b1;
				c2=1'b1;
				c11_2=1'b1;
				c3=1'b1;
				Y=decode;
			end
						
			decode : begin //fine
				{c12,c13}=2'b10;
				c2=1'b1;
				c11_1=1'b1;
				{c12,c13}=2'b10;
				Y=cycle1;
			end
			
			cycle1 : begin
				case(inp[22:0])
					NOOP : begin //fine
					end
					JUMP : begin //fine
						c21=1'b1;
						c3=1'b1;
					end
					BRE_BRZ : begin //fine
						c3=B1;
						c21=1'b1;
					end 
					BRNE_BRNZ : begin //fine
						c3=B2;
						c21=1'b1;
					end
					BRG : begin //fine
						c3=B3;
						c21=1'b1;
					end
					BRGE : begin //fine
						c3=B4;
						c21=1'b1;
					end
					CMP : begin //fine
						c14=1'b1;
						{c12,c13}=2'b11;
					end
					INPUTC : begin 
						c1=1'b1;
						c15=1'b1;
					end
					INPUTD : begin
						c15=1'b1;
						c17=1'b1;
						c16=1'b1;
					end
					LOADI_LOADP : begin //fine
						c15=1'b1;
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					STORE : begin //fine
						c15=1'b1;
						c17=1'b1;
					end
					LOAD : begin //fine now
						c15=1'b1;
						Y<=cycle2;
					end
					ADD :begin //fine
						{c12,c13}=2'b10;
						c14=1'b1;
						Y=cycle2;
					end
					ADDI :begin //fine
						{c12,c13}=2'b10;
						c11_1=1'b1;
						c14=1'b1;
						Y=cycle2;
					end
					SUB :begin //fine
						{c12,c13}=2'b11;
						c14=1'b1;
						Y=cycle2;
					end
					SUBI :begin //fine
						{c12,c13}=2'b11;
						c11_1=1'b1;
						c14=1'b1;
						Y=cycle2;
					end
					SHIFTL :begin //fine
						c14=1'b1;
						Y=cycle2;
					end
					SHIFTR :begin //fine
						{c12,c13}=2'b01;
						c14=1'b1;
						Y=cycle2;
					end
					STOREF : begin //fine now
						{c12,c13}=2'b10;
						cmove=1'b1;
						Y=cycle2;
					end
					INPUTCF:begin
						Y=cycle2;
						c11_1=1'b1;
						{c12,c13}=2'b10;
					end
					INPUTDF:begin
						Y=cycle2;
						c11_1=1'b1;
						{c12,c13}=2'b10;
					end
					MOVE:begin //fine
						cmove=1'b1;
						{c12,c13}=2'b10;
						Y=cycle2;
					end
					LOADF:begin //fine
						cmove=1'b1;
						Y=cycle2;
						{c12,c13}=2'b10;
					end
					default : begin
						{c1, c2, c3, c8, c9, c10, c11_1 , c11_2 , c12, c13, c14, c15, c16, c17, c18, c19 , cmove,c21} = 18'bx;
						{c7,c6,c5,c4} = 4'bx;
					end
				endcase
			end
			
			cycle2 : begin
				case (inp[22:0]) 
					LOAD : begin
						c18=1'b1;
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					ADD :begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					ADDI :begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					SUB :begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					SUBI :begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					SHIFTL :begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					SHIFTR :begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					STOREF : begin
						c17=1'b1;
					end
					INPUTCF:begin
						c1=1'b1;
					end
					INPUTDF:begin
						c16=1'b1;
						c17=1'b1;
					end
					MOVE:begin
						{c9,c8}=inp[24:23];
						c10=1'b1;
					end
					LOADF:begin 
						Y=cycle3;
					end
					default : begin
						{c1, c2, c3, c8, c9, c10, c11_1 , c11_2 , c12, c13, c14, c15, c16, c17, c18, c19 , cmove,c21} = 18'bx;
						{c7,c6,c5,c4} = 4'bx;
					end
				endcase
			end
			cycle3:begin
				c18=1'b1;
				{c9,c8}=inp[24:23];
				c10=1'b1;
			end
			
			default : begin
						{c1, c2, c3, c8, c9, c10, c11_1 , c11_2 , c12, c13, c14, c15, c16, c17, c18, c19 , cmove,c21} = 18'bx;
						{c7,c6,c5,c4} = 4'bx;
			end
		endcase	
	end
endmodule
				
				
				
				
				
				