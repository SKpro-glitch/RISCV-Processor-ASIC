module Fetch(clk, Reset, Branch, TargetAddress, Instruction, Add, plus32);
    wire [9:0] Address, Previous;
    wire [31:0] I;
    reg [9:0] JumpTo;
    input clk, Reset;
    input Branch;
    input [9:0] TargetAddress;
    output [31:0] Instruction;
    output [9:0] Add;
    input [31:0] plus32;
        
    Prog_Count PC(
    .clk(clk),
    .Reset(Reset),
    .Jump(Jump),
    .JumpTo(TargetAddress),
    .Address(Address));
            
    Prog_Mem IMEM(
    .clk(clk),
    .Reset(Reset),
    .Address(Address),
    .Instruction(I),
    .plus32(plus32));
    
    assign Add  = Address;
    assign Instruction = I;
endmodule
