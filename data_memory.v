`timescale 1ns / 1ps

module data_memory  
 (  
      input clk,  
		input[15:0] address,
      input[15:0] write_data,
      input write_enable,
      input read_enable,
      output[15:0] read_data
 );  
      integer i;  
      reg [15:0] data[127:0];  // -> data
      wire [6 : 0] data_index = address[7 : 1];  
		
      initial 
		begin  
			for(i=0;i<128;i=i+1)  
				data[i] <= 16'd0;  
		end  
			
      always @(posedge clk) 
		begin  
			if (write_enable)  
				data[data_index] <= write_data;  
		end  
			
      assign read_data = (read_enable==1'b1) ? data[data_index]: 16'd0;   
 endmodule     