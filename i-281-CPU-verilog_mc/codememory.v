module codememory(c1,readselect,writeselect,inp,outp,clk,reset);
	input wire c1,clk,reset;input wire[5:0]readselect,writeselect;
	input wire [15:0]inp;
	output wire [15:0]outp;
	reg [15:0] c_o [0:63];
	
	
	always @(posedge clk , posedge reset) begin
		if (reset) begin
			integer i;
			for(i=0 ; i<64 ; i=i+1) begin
				c_o[i] <= 16'd0;
			end
		end
		else begin
			if(c1==1'b1)
				c_o[writeselect] <= inp;
		end
	end
	
	assign outp = c_o[readselect];
	
endmodule 