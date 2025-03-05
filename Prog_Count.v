module Prog_Count(
    input clk, Reset, Jump,
    input [9:0] JumpTo,
    
    output reg [9:0] Address, Previous
    );
    
    initial Address = 10'd0;
    
    always @(posedge clk) begin
        Previous = Address;
        
        if(Reset)
            Address = 10'd0;
        else if(Jump)
            Address = JumpTo;
        else
            Address = Address + 1;
    end
    
endmodule
