`timescale 1ns / 1ps

module ALU
 (    
      input [2:0] operation,     // ALU operation  
      input signed [15:0] a,     // src1  
      input signed [15:0] b,     // src2   
      output reg[15:0] result,   // ALU result       
      output zero  
 );  
	 reg multiplier_sign, multiplicand_sign;
	 reg signed [7:0] multiplier, multiplicand, product_upper, product_lower;
	 reg signed [15:0] multiplier_temp, multiplicand_temp, product;
	 integer i; 
	 
	 always @(operation, a, b)  
	 case(operation)  
		 3'b000: result = a + b; // add  
		 3'b001: result = b - a; // sub  
		 3'b010: result = a & b; // and  
		 3'b011: result = a | b; // or  
		 3'b111: begin 
						if (b<a) result = 16'd1;  // slt
						else result = 16'd0;  
					end 
		 3'b101: result = a << b; // sll
		 3'b110: result = a >> b; // srl	
		 3'b100: 
					begin	
						// keep sign values
						assign multiplier_sign = a[15];
						assign multiplicand_sign = b[15];
						
						// take two's complement if negative
						if (multiplier_sign == 1'b1)  
							assign multiplier_temp = ~a + 1;
						else
							assign multiplier_temp = a;
						
						if (multiplicand_sign == 1'b1) 
							assign multiplicand_temp = ~b + 1;
						else
							assign multiplicand_temp = b;
						
						// assign right 8 bit of multiplier to right 8 bit of product
						assign product = {{8{1'b0}},multiplier_temp[7:0]};
						assign multiplier = multiplier_temp[7:0];
						assign multiplicand = multiplicand_temp[7:0];
						assign product_lower = multiplier;
						assign product_upper = 8'b0;
						 
						for(i=0;i<8;i=i+1) 
						begin
							if (product[0]==1'b1) 
							begin
								assign product_upper = product_upper + multiplicand;
								assign product = {product_upper,product_lower};
							end
							
							assign product = product >> 1;
							assign product_upper = product[15:8];
							assign product_lower = product[7:0];
						end
						
						// set product sign
						if (multiplicand_sign ^ multiplier_sign) 
						begin 
							assign product = ~product + 1;
						end
							
						result = product;
					end
		 default: result = 16'b0;
	 endcase  
	 
	 assign zero = (result==16'd0) ? 1'b1: 1'b0;  
 endmodule
 