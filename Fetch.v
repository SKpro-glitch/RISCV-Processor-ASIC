module Fetch(
    input clk, Reset,
    input Branch,
    input [9:0] TargetAddress,
    input [31:0] plus32,
    
    output [31:0] Instruction,
    output [9:0] Add
    );
    
    wire [9:0] Address, Previous;
    wire [31:0] I;
    
    reg branch;
    reg [9:0] JumpTo;
    reg [31:0] Plus32;
        
    always @ (posedge clk) begin 
        {branch, JumpTo} <= {Branch, TargetAddress};
        Plus32 <= plus32;
    end
    
    Prog_Count PC(
    .clk(clk),
    .Reset(Reset),
    .Jump(branch),
    .JumpTo(JumpTo),
    .Address(Address)
    );
            
    Prog_Mem IMEM(
    .clk(clk),
    .Reset(Reset),
    .Address(Address),
    .plus32(Plus32),
    .Instruction(I)
    );
    
    assign Add  = Address;
    assign Instruction = I;
endmodule
