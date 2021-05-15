`timescale 1ns / 1ps

module control_unit
( 
      input[4:0] opcode,  
	   input reset,  
      output reg[2:0] alu_op,  
      output reg jump, branch, mem_read, mem_write, // control signals
					  alu_src, reg_write, reg_dst, 
					  call, shift_reg, jump_reg                      
 ); 
 
	 always @(*)  
	 begin  
		if(reset == 1'b1) 
		begin  
			reg_dst = 1'b0;  
			alu_op = 3'b000;  
			jump = 1'b0;  
			branch = 1'b0;  
			mem_read = 1'b0;  
			mem_write = 1'b0;  
			alu_src = 1'b0;  
			reg_write = 1'b0;  
			call = 1'b0;
			jump_reg = 1'b0;
			shift_reg = 1'b0;
		end  
			
		else 
		begin  
			reg_dst = 1'b0;  
			jump = 1'b0;  
			branch = 1'b0;  
			mem_read = 1'b0;  
			mem_write = 1'b0;  
			alu_src = 1'b0;  
			call = 1'b0;
			jump_reg = 1'b0;
			shift_reg = 1'b0;
			reg_write = 1'b1;
			alu_op = opcode[4:2];
			
		
			if(opcode[0] == 1'b0) // regdst
			begin 
				reg_dst = 1'b1;
			end
			else  // alu_src
			begin
				alu_src = 1'b1;
			end
		
			if(opcode[1] == 1'b1)  // jump
			begin
				jump = 1'b1;
			end

			case(opcode)   
				// R-Format
				5'b01010: begin // jr  
								 jump_reg = 1'b1;  
								 reg_write = 1'b0;
							 end
							 
				5'b10110: begin // syscall  
								 reg_dst = 1'b0;  
								 call = 1'b1;  
								 reg_write = 1'b0;
								 jump = 1'b0;
							 end
				
				
				// I-Format
				5'b10101: begin // lui 
								shift_reg = 1'b1; 
							 end
			
				5'b00101: begin // beq  
								 branch = 1'b1;  
								 alu_src = 1'b0;  
								 reg_write = 1'b0;  
							 end
							 
				5'b01101: begin // bne  
								 reg_dst = 1'b1;  
								 branch = 1'b1;  
								 alu_src = 1'b0;  
								 reg_write = 1'b0; 
								 alu_op = 3'b001;
							 end
							 
				5'b00001: begin // sw   
								 mem_write = 1'b1;
								 reg_write = 1'b0; 					 
							 end
							 
				5'b01001: begin // lw  
								 mem_read = 1'b1; 
								 alu_op = 3'b000;	
							 end
							 
							 
				// J-Format
				5'b00010: begin // jal   
								jump = 1'b1;					 
							 end
							 
				5'b00110: begin // j  
								 mem_read = 1'b1;  
								 reg_write = 1'b0; 
							 end
							 
				// exit:
				5'b11111: begin
								 reg_write = 1'b0;
								 alu_op = 3'bx;
								 alu_src = 1'b0;
								 jump = 1'b0;
							 end	
			endcase  	
		end  
	 end  
 endmodule
 