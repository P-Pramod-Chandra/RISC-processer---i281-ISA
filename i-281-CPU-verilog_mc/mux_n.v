module sixBit2_1Mux(opt,a,b,sel);
	
	parameter n=8;
	output reg [n:0]opt;
	
	input wire [n:0]a;
	input wire [n:0]b;
	input wire sel;
	
	always@(*)
	begin
		case (sel)
			1'b0 : opt = a;
			1'b1 : opt = b;
		endcase
	end
endmodule
