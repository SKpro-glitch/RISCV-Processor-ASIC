`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2024 09:29:27
// Design Name: 
// Module Name: Synchronous_Core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Synchronous_Core(clk, Reset, out, file);
    input clk, Reset;
    output [31:0] out, file;
//////////////////////////////////////////////////////////////////////////////////
// DECLARATIONS

    //Fetch Unit declarations
    wire Branch; //Branch status
    wire [9:0] TargetAddress; //Target instruction address to jump to 
    wire [31:0] Instruction; //Fetched instruction
    wire [9:0] Add; //Current address of fetched instruction
    
    //Decode Unit declarations
    wire [5:0] type; //Instruction type - R, I, S, B, U, J
    wire [3:0] opcode; //Opcode to select type of instruction
    wire [6:0] alu_opcode; //Opcode select operation of ALU
    wire [4:0] rs0, rs1, rdt; //First source operand, Second source operand, Destination address of result
    wire [2:0] funct3; //3-bit function
    wire [6:0] funct7; //7-bit function
    wire [19:0] imm; //Immediate value
    
    wire r, i, s, b, u, j; 
    assign {r, i, s, b, u, j} = type; 
    
    //Execute Unit declarations
    wire [31:0] op0, op1;
    wire [31:0] result;
    
    assign out = result;
//////////////////////////////////////////////////////////////////////////////////
// FUNCTIONAL UNITS

    //RAM
    wire write_enable;
    wire [31:0] data_in;
    wire [31:0] data_out;
    reg [9:0] Ram_add;

    //Instruction Memory
    RAM i_ram(
    .write_enable(write_enable),
    .address(Ram_add),
    .data_in(data_in),
    .data_out(data_out)
    );

    //If branch is present, fetch target address, else fetch next address
    always @ * begin
        if(|Branch) 
            Ram_add = TargetAddress;
        else 
            Ram_add = Add;
    end
    
    //Register File
    reg [31:0] Reg_File [0:15]; //16 registers of 32-bits each
    assign op0 = rs0[4] ? Reg_File[rs0] : {28'b0, rs0[3:0]}; //Get first operand from Register File
    assign op1 = rs1[4] ? Reg_File[rs1] : {28'b0, rs1[3:0]}; //Get second operand from Register File
    wire [31:0] write_data; //Data to be written to the Reg File
    assign file = Reg_File[0]; //The address zero of Reg File is given as output

    //Data Memory
    RAM d_ram(
    .write_enable(s),
    .address(mem_address),
    .data_in(store_data),
    .data_out(write_data)
    );
    
//////////////////////////////////////////////////////////////////////////////////
    //PIPELINE BEGINS
    
    Fetch fu(.clk(clk),
    .Reset(Reset),
    .Branch(Branch),
    .TargetAddress(TargetAddress),
    .Instruction(Instruction),
    .Add(Add),
    .plus32(data_out)
    );
    
    Decode du(.clk(clk),
    .instruction(Instruction), 
    .type(type),
    .opcode(opcode), .alu_opcode(alu_opcode),
    .rs0(rs0), .rs1(rs1), .rdt(rdt),
    .funct3(funct3), .funct7(funct7),
    .imm(imm)
    );
    
    Execute eu(.clk(clk),
    .type(type),
    .opcode(opcode), .alu_opcode(alu_opcode),
    .op0(op0), .op1(op1),
    .funct3(funct3), .funct7(funct7),
    .imm(imm), .address(Add),
    .targetAddress(TargetAddress),
    .result(result),
    .branch(Branch),
    .mem_address(mem_address), 
    .store_data(store_data)
    );
    
//////////////////////////////////////////////////////////////////////////////////
    //  MEMORY ACCESS AND WRITE BACK LOGIC
    
    always @ (posedge clk) begin
        //Writing to Register File / Store operation
        if(s) Reg_File[rdt] <= write_data;
        else if(i) Reg_File[rdt] <= result;        
    end
    
endmodule
