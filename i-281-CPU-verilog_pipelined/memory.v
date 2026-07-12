module memory(write_en,readselect,writeselect,inp,outp,clk,reset);
	input wire write_en,clk,reset;input wire[3:0]readselect,writeselect;
	input wire [7:0]inp;
	output wire [7:0]outp;
	reg [7:0] c [0:15];
	
	
	always @(posedge clk , posedge reset) begin
		if (reset) begin
			integer i;
			for(i=0 ; i<16 ; i=i+1) begin
				c[i] <= 8'd0;
			end
		end
		else begin
			if (write_en==1'b1)
				c[writeselect] <= inp;
		end
	end
	
	assign outp = c[readselect];
	
endmodule 