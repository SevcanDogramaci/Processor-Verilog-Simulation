`timescale 1ns / 1ps

`include "LCD.v"

 module processor_tb; 
 
      // Inputs  
      reg clk, reset;  
		
      // Outputs  
      wire [15:0] pc_out, display, alu_result;  
		
		// Control signals 
		wire jump, branch, mem_read, mem_write, alu_src, 
			  reg_write, reg_dst, syscall, shift_reg, jump_reg;

      processor uut (.clk(clk),   
						   .reset(reset),   
						   .pc_out(pc_out),   
						   .alu_result(alu_result),
						   .display_data(display),
						   .jump(jump),
					 	   .branch(branch),
						   .mem_read(mem_read),
						   .mem_write(mem_write),
						   .alu_src(alu_src),
						   .reg_write(reg_write),
						   .reg_dst(reg_dst),
						   .syscall(syscall),
						   .shift_reg(shift_reg),
						   .jump_reg(jump_reg));  
		
		
		LCD lcd (.clk(clk), .reset(reset), .data(display), .call(syscall));
		
      initial 
		begin  
           clk = 0;  
           forever #10 clk = ~clk;  
      end 
		
      initial 
		begin  
           // Initialize Inputs  
           reset = 1;  
			  
           // Wait 20 ns for global reset to finish  
           #20;  
			  reset = 0;  
			  
           // Add stimulus here  
      end  
 endmodule
 

