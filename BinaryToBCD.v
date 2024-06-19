/* BinaryToBCD
 * Short Description
 * -----------------
 * This module is to convert binary numbers into binary coded decimal from 0-9.
 * 
 */ 
//Reference code from Unit 3.1 FPGA Hardware

module BinaryToBCD(
    input [7:0]       bin,
    output reg [11:0] bcd
);
   
     integer i; //looping variable 
	  
     //Always block - implement the Double Dabble algorithm
     always @(bin) begin
            bcd = 0;                                  //initialize bcd to zero.
            for (i = 7; i >= 0; i = i - 1) begin      //run for 8 iterations 
                if (bcd[3:0]>4)
						  bcd[3:0] = bcd[3:0] + 3;
					 if (bcd[7:4]>4)
						  bcd[7:4] = bcd[7:4] + 3;
					 if (bcd[11:8]>4)
						  bcd[11:8] = bcd[11:8] + 3;
					 bcd = {bcd[10:0], bin[i]};            //shift left by one, append the next binary bit	  
						  
            end
        end     
                
endmodule