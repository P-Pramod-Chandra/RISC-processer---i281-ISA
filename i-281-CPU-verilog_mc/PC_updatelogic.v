module PC_updatelogic(currentaddress,offset,outp0,outp1);

	input wire [5:0] currentaddress,offset;
	output wire [5:0] outp0,outp1;
	
	assign outp0 = currentaddress + 5'b00001 ;
	assign outp1 = currentaddress + 5'b00001 + offset;
	
endmodule
