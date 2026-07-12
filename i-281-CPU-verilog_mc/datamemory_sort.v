module datamemory_sort(c17,readselect,writeselect,inp,outp,clk,reset);
	input wire c17,clk,reset;input wire[3:0]readselect,writeselect;
	input wire [7:0]inp;
	output wire [7:0]outp;
	//output wire [127:0] display_output;
	reg [7:0] c_o [0:15];
	
	
	always @(posedge clk , posedge reset) begin
		if (reset) begin
			c_o[0]  = 8'b00000111; // array[0]
			c_o[1]  = 8'b00000011; // array[1]
			c_o[2]  = 8'b00000010; // array[2]
			c_o[3]  = 8'b00000001; // array[3]
			c_o[4]  = 8'b00000110; // array[4]
			c_o[5]  = 8'b00000100; // array[5]
			c_o[6]  = 8'b00000101; // array[6]
			c_o[7]  = 8'b00001000; // array[7]
			c_o[8]  = 8'b00000111; // last
			c_o[9]  = 8'b00000000; // temp
			c_o[10] = 8'b00000000;
			c_o[11] = 8'b00000000;
			c_o[12] = 8'b00000000;
			c_o[13] = 8'b00000000;
			c_o[14] = 8'b00000000;
			c_o[15] = 8'b00000000;
		end
		else begin
			if (c17==1'b1)
				c_o[writeselect] <= inp;
		end
	end
	
	assign outp = c_o[readselect];
	
endmodule 