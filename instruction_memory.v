`timescale 1ns / 1ps

module instruction_memory          // a synthesisable rom implementation  
 (  
      input [15:0] pc,  
      output wire [15:0] instruction
 );  
      wire[7 : 0] instruction_index = pc[8 : 1];  
      reg[15:0] instructions[127:0]; 
		integer i;  

      initial 
		begin  
			for(i=0;i<128;i=i+1) 
			begin
				instructions[i] = 16'b1111100000000000; 
			end
			
			// general test 1
			/*
			slti $r1, $r3, 8
			muli $r3, $r1, 8
			jal label
			or $r2, $r1, $r3
			muli $r1, $r2, -16
			muli $r3, $r1, -16
			slti $r1, $r1, 0
			j exit
			label: and $r1, $r1, 0
			jr $ra
			exit: sw $r3, -2($sp)*/
			instructions[0] = 16'b1110101100101000;
			instructions[1] = 16'b1000100101101000;
			instructions[2] = 16'b0001000000001000;
			instructions[3] = 16'b0110000101101000;
			instructions[4] = 16'b1000101000110000;
			instructions[5] = 16'b1000100101110000;
			instructions[6] = 16'b1110100100100000;
			instructions[7] = 16'b0011000000001010;
			instructions[8] = 16'b0100000100000100;
			instructions[9] = 16'b0101011100000000;
			instructions[10] = 16'b0000111001111110;
		
      end  
		
      assign instruction = (pc[15:0] < 256 ) ? instructions[instruction_index] : 16'd0;  
 endmodule
 