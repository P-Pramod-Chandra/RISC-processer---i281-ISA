module codememory(c1,readselect,writeselect,inp,outp,clk,reset);
	input wire c1,clk,reset;input wire[5:0]readselect,writeselect;
	input wire [15:0]inp;
	output wire [15:0]outp;
	reg [15:0] c_o [0:63];
	
	initial begin
        $readmemh("code.hex", c_o);   // load on simulation start
    end
	
	always @(posedge clk) begin
			if(c1==1'b1)
				c_o[writeselect] <= inp;
	end
	
	assign outp = c_o[readselect];
	
endmodule 