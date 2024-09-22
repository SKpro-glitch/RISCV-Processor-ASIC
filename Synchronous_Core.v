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


module Synchronous_Core(input clk, Reset);
    
//////////////////////////////////////////////////////////////////////////////////
// DECLARATIONS

    //Fetch Unit declarations
    wire [1:0] Branch;
    reg [9:0] TargetAddress;
    wire [31:0] Instruction;
    wire [9:0] Add;
    
    //Decode Unit declarations
    wire [5:0] type;
    wire [3:0] opcode; 
    wire [6:0] alu_opcode;
    wire [4:0] rs0, rs1, rdt;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [11:0] imm;
    
    wire r, i, s, b, u, j; 
    assign {r, i, s, b, u, j} = type; 
    
    //Execute Unit declarations
    wire [31:0] op0, op1;
    wire [31:0] result;

//////////////////////////////////////////////////////////////////////////////////
// FUNCTIONAL UNITS

    //RAM
    wire write_enable;
    wire [31:0] data_in;
    wire [31:0] data_out;
    reg [9:0] Ram_add;
        
    RAM i_ram(
    .write_enable(write_enable),
    .address(Ram_add),
    .data_in(data_in),
    .data_out(data_out)
    );
    
    always @ * begin
        if(|Branch) 
            Ram_add = TargetAddress;
        else 
            Ram_add = Add;
    end
    
    //Register File
    reg [31:0] Reg_File [0:31];
    assign op0 = Reg_File[rs0];
    assign op1 = Reg_File[rs1];
    reg [4:0] write_address;
    wire [31:0] write_data;

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
    .imm(imm),
    .result(result),
    .branch(Branch),
    .mem_address(mem_address), 
    .store_data(store_data)
    );
        
//////////////////////////////////////////////////////////////////////////////////
    //  MEMORY ACCESS AND WRITE BACK LOGIC
    
    always @ (posedge clk) begin
        //Writing to Register File / Store operation
        if(s) Reg_File[rdt] = write_data;
        else if(i) Reg_File[rdt] = result;        
    end
    
endmodule