`timescale 1ns / 1ps

 module register_file  
 (  
      input clk,  
      input rst,   
		
      input write_enable,  
      input[2:0] write_destination, 
      input[15:0] write_data,
		
      //read port 1  
      input[2:0] read_address_1, 
      output[15:0] read_data_1,  
		
      //read port 2  
      input[2:0] read_address_2, 
      output[15:0] read_data_2  
 );  
      reg[15:0] register_array [7:0];  

      always @ (posedge clk or posedge rst) 
		begin  
			if(rst) 
			begin  
				register_array[0] <= 16'b0;  
				register_array[1] <= 16'b0;  
				register_array[2] <= 16'b0;  
				register_array[3] <= 16'b0;  
				register_array[4] <= 16'b0;  
				register_array[5] <= 16'b0;  
				register_array[6] <= 16'd256;  
				register_array[7] <= 16'b0;       
			end  
			else 
			begin  
				if(write_enable) 
				begin  
					register_array[write_destination] <= write_data;  
				end  
			end  
		end  
		
		assign read_data_1 = register_array[read_address_1];  
      assign read_data_2 = register_array[read_address_2]; 
 endmodule  