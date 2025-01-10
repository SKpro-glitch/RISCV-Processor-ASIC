module Prog_Count(
    input clk, Reset, Jump,
    input [9:0] JumpTo,
    output reg [9:0] Address, Previous,
    );
        
    initial Address = 10'd0;
    
    always @(posedge clk) begin
        Previous = Address; //Save the address of the previous instruction
        
        if(Reset)
            Address = 10'd0;
        else if(Jump) //If branch is taken, jump to target address
            Address = JumpTo;
        else //Else go to next address
            Address = Address + 10'd1;
    end
    
endmodule
