module Fetch(
    input clk, Reset,
    input Branch, //Branch taken status
    input [9:0] TargetAddress, //Target Address to jump to
    
    output [31:0] Instruction, //Fetched instruction
    output [9:0] Add, //Address of fetched instruction
    input [31:0] plus32 //Instruction of next cache
    );

    //Fetch Stage - Fetches instruction from the Instruction Memory
    
    wire [9:0] Address, Previous; //Current address, Previous instruction's address
    wire [31:0] I; //Instruction
    
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
