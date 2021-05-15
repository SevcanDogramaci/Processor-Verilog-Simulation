`timescale 1ns / 1ps

`include "ALU.v"
`include "control_unit.v"
`include "data_memory.v"
`include "instruction_memory.v"
`include "register_file.v"
 
module processor
( 
      input clk, reset,  
	   output signed [15:0] pc_out, alu_result, display_data ,
      output wire jump, branch, mem_read, mem_write, alu_src, // control signals
						reg_write, reg_dst, syscall, shift_reg, jump_reg
 );  
 
	 wire[15:0] instruction;  
	 reg[15:0] pc_current;  
	 wire signed[15:0] pc_next, pc2; 
 
	 // register file reg address
	 wire[2:0] reg_write_dest, reg_write_dest_1;  
	 wire[2:0] reg_read_addr_1;  
	 wire[2:0] reg_read_addr_2; 
 
	 // register file data
	 wire signed [15:0] reg_write_data;  
	 wire signed [15:0] reg_read_data_1;
	 wire signed [15:0] reg_read_data_2; 
 
	 // memory data output
	 wire signed[15:0] mem_read_data;
	
	 // ALU inputs
	 wire signed[15:0] read_data1, read_data2;
	 wire[2:0] ALU_op; 
 
	 // ALU outputs
	 wire signed [15:0] ALU_out;
	 wire zero_flag;  
 
	 // helpers
	 wire signed[15:0] sign_ext_imm, branch_address, jump_address, 
							 im_shift_1, pc_branch, pc_jump, pc_jump_reg;
	 wire[11:0] jump_shift_1;
	 wire is_branch; 
	 
	 
	 // PC   
	 always @(posedge clk or posedge reset)  
	 begin   
		 if(reset) 
			pc_current <= 16'd0;    // PC = 0
		 else  
			pc_current <= pc_next;  // PC = PC_NEXT
	 end   
      
 
	 // fetch instruction from instruction memory  
	 instruction_memory instruction_memory(.pc(pc_current),.instruction(instruction));
	 
	 
	 // send instruction to control unit  
	 control_unit control_unit(.reset(reset), .opcode(instruction[15:11]),
										.reg_dst(reg_dst), .shift_reg(shift_reg),
										.alu_op(ALU_op), .jump(jump),.branch(branch),
										.mem_read(mem_read), .mem_write(mem_write),
										.alu_src(alu_src),.reg_write(reg_write),
										.jump_reg(jump_reg), .call(syscall));  
 
 
	 // extract registers' data that will be used  
	 assign reg_read_addr_1 = instruction[10:8];  
	 assign reg_read_addr_2 = instruction[7:5];  
	 assign reg_write_dest_1 = (reg_dst == 1'b1) ? instruction[4:2] : instruction[7:5];
 
 
	 // multiplexer regdest  
	 assign reg_write_dest = (jump==1'b1) ? 3'b111 : reg_write_dest_1;
	 
	 register_file reg_file(.clk(clk),.rst(reset),
									.write_enable(reg_write),  
									.write_destination(reg_write_dest),  
									.write_data(reg_write_data),  
									.read_address_1(reg_read_addr_1),  
									.read_data_1(reg_read_data_1),  
									.read_address_2(reg_read_addr_2),  
									.read_data_2(reg_read_data_2));
		
		
	 // output display data
	 assign display_type = (reset) ? 0 : ((syscall) ? 1 : 0);
	 assign display_data = (reset) ? 16'bx : ((syscall == 1'b1) ? reg_read_data_1 
																			  : instruction[15:11]);	
	
	 // sign extend the immediate
	 assign sign_ext_imm = {{11{instruction[4]}},instruction[4:0]};  
	 
 
	 // multiplexer alu_src  
	 assign read_data1 = (alu_src==1'b1) ? sign_ext_imm : reg_read_data_2;
	 assign read_data2 = (shift_reg==1'b1) ? 4'b1000 : reg_read_data_1;  
	 
	 
	 // ALU   
	 ALU alu_unit(.operation(ALU_op),.a(read_data1),.b(read_data2),
					  .result(ALU_out),.zero(zero_flag));  
	 
	 
	 // data memory  
	 data_memory data_memory(.clk(clk), 
									 .read_enable(mem_read),  
									 .write_enable(mem_write), 
									 .address(ALU_out),
								    .write_data(reg_read_data_2),
									 .read_data(mem_read_data)); // data_out

	 
	 // write back  
	 assign reg_write_data = (jump == 1'b1) ? (pc_current + 16'd2) : 
						  ((mem_read == 1'b1) ? mem_read_data : ALU_out);


	 // update PC 
	 
	 // PC + 2   
	 assign pc2 = pc_current + 16'd2;  
	 
	 // immediate shift 1  
	 assign im_shift_1 = {sign_ext_imm[14:0],1'b0};  
	 
	 // jump shift left 1  
	 assign jump_shift_1 = {instruction[10:0],1'b0};
	 
	 // jump address 
	 assign jump_address = {{4{pc2[15]}},jump_shift_1};  
	 // jump address came already shifted
	 //assign PC_j = {{5{pc2[15]}},instruction[10:0]}; 	 
	 
	 // branch address
	 assign branch_address = pc2 + im_shift_1;
	 
	 // is branch
	 assign is_branch = (branch && zero_flag && ~reg_dst)|| // beq
							  (branch && reg_dst && ~zero_flag);  // bne
							  
	 assign pc_branch = (is_branch == 1'b1) ? branch_address : pc2;
	 assign pc_jump = (jump == 1'b1) ? jump_address : pc_branch;
	 assign pc_jump_reg = (jump_reg == 1'b1) ? reg_read_data_1 : pc_jump;
	 assign pc_next = pc_jump_reg;

	 // output  
	 assign pc_out = pc_current;  
	 assign alu_result = (reset) ? 16'd0 : ALU_out;  
	 
 endmodule  
