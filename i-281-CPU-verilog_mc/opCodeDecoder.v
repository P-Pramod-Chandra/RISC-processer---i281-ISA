module opCodeDecoder(
   Y,
   
   Inp,
   En
);
   
	output wire [26:0]Y;
   input wire [7:0] Inp;
   wire [15:0]I;
   input wire En;
   reg [26:0]reg_Y;
	
	assign I[15:0] = {Inp,8'b00000000} ;

   
   assign Y = reg_Y;
   
   always @(I or En)
	begin
	
      
      reg_Y = 23'b0; // setting everything to 0 by default
      
      if (En == 1'b1)
		begin
			
			reg_Y[23] = I[11];
			reg_Y[24] = I[10];
			reg_Y[25] = I[9];
			reg_Y[26] = I[8];
			
         case (I[15:12])
            4'b0000: reg_Y[0] = 1'b1;
            
				// 4'b0001 used to set reg_Y13, 14, 15, 16
				4'b0001: begin
               case (I[9:8])
						2'b00: reg_Y[1] = 1'b1;
                  2'b01: reg_Y[2] = 1'b1;
                  2'b10: reg_Y[3] = 1'b1;
                  2'b11: reg_Y[4] = 1'b1;
               endcase
            end
				
            4'b0010: reg_Y[5] = 1'b1;
            4'b0011: reg_Y[6] = 1'b1;
            4'b0100: reg_Y[7] = 1'b1;
            4'b0101: reg_Y[8] = 1'b1;
            4'b0110: reg_Y[9] = 1'b1;
            4'b0111: reg_Y[10] = 1'b1;
            4'b1000: reg_Y[11] = 1'b1;
            4'b1001: reg_Y[12] = 1'b1;
            4'b1010: reg_Y[13] = 1'b1;
            4'b1011: reg_Y[14] = 1'b1;
            
				// 4'b1100 used to set reg_Y17, 18
				4'b1100: begin
               case (I[9:8])
                  2'b00: reg_Y[15] = 1'b1;
                  2'b01: reg_Y[16] = 1'b1;
                  default: ;
               endcase
            end
				
            4'b1101: reg_Y[17] = 1'b1;
            4'b1110: reg_Y[18] = 1'b1;
            
				//4'b1111 used to set reg_Y19, 20, 21, 22
            4'b1111: begin
               case (I[9:8])
                  2'b00: reg_Y[19] = 1'b1;
                  2'b01: reg_Y[20] = 1'b1;
                  2'b10: reg_Y[21] = 1'b1;
                  2'b11: reg_Y[22] = 1'b1;
               endcase
            end
            
            default: ;
         endcase
      end
   end
endmodule
