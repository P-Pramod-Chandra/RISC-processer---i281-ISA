module datamemory(c17,readselect,writeselect,inp,outp,clk,reset);
	input wire c17,clk,reset;input wire[3:0]readselect,writeselect;
	input wire [7:0]inp;
	output wire [7:0]outp;
	//output wire [127:0] display_output;
	reg [7:0] c_o [0:15];
	
	initial begin
        $readmemh("data.hex", c_o);   // load on simulation start
    end
	
	always @(posedge clk) begin
			if (c17==1'b1)
				c_o[writeselect] <= inp;
	end
	
	assign outp = c_o[readselect];
	
endmodule 