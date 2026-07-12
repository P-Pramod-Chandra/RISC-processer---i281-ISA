module registerfile(c10,readselect1,readselect2,writeselect,inp,outp1,outp2,clk,reset);
	input wire c10,clk,reset;input wire[1:0]readselect1,readselect2,writeselect;
	input wire [7:0]inp;
	output wire [7:0]outp1,outp2;
	reg [7:0] c [0:3];
	
	always @(posedge clk , posedge reset) begin : arbitrary
		integer i;
		if (reset) begin
			for(i=0 ; i<4 ; i=i+1) begin
				c[i] <= 8'd0;
			end
		end
		else begin
			if (c10==1'b1)
				c[writeselect] <= inp;
		end
	end
	
	assign outp1 = c[readselect1];
	assign outp2 = c[readselect2];
	
endmodule 