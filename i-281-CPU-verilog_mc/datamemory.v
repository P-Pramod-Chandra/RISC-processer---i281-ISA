module datamemory(c17,readselect,writeselect,inp,outp,clk,reset);
	input wire c17,clk,reset;input wire[3:0]readselect,writeselect;
	input wire [7:0]inp;
	output wire [7:0]outp;
	//output wire [127:0] display_output;
	reg [7:0] c_o [0:15];
	
	
	always @(posedge clk , posedge reset) begin
		if (reset) begin
			integer i;
			for(i=0 ; i<16 ; i=i+1) begin
				c_o[i] <= 8'd0;
			end
		end
		else begin
			if (c17==1'b1)
				c_o[writeselect] <= inp;
		end
	end
	
	assign outp = c_o[readselect];
	
endmodule 