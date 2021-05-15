`timescale 1ns / 1ps

module LCD
(
	 input clk,
    input reset,
    input[15:0] data,
	 input call
 );

	 always @(posedge clk)
	 begin
		 if(reset)
			$display("%d",1'dx);
		 else
		 begin
			if (call)
				$display("%d",data);
			else
				$display("op:%b j:%b im:%b",data[4:2], data[1], data[0]);
		 end
	 end
endmodule
