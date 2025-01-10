`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.08.2024 19:05:36
// Design Name: 
// Module Name: Decode
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

//Decode Stage - Decodes the instructino to obtain its functional components
module Decode(
    input clk,
    input [31:0] instruction,
    
    output reg [0:5] type,
    output reg [3:0] alu_opcode,
    output reg [6:0] opcode,
    output reg [4:0] rs0, rs1, rdt,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [19:0] imm
    );
        
    wire r, i, s, b, u, j; 
    assign {r, i, s, b, u, j} = type; 
    
    always @ (posedge clk) begin
        //Extracting the opcode from the instruction
        opcode = instruction[6:0];
        
        //Obtaining the operand source and target addresses from the instruction
        rdt = instruction[11:7];
        rs0 = instruction[19:15];
        rs1 = instruction[24:20];
        
        //Getting the functions from the instruction
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];
        
        //Deciding type of instruction based on opcode
        case(opcode)
            7'h33: type = 6'b100000;
            7'h67, 7'h03, 7'h13: type = 6'b010000;
            7'h23: type = 6'b001000;
            7'h63: type = 6'b000100;
            7'h37, 7'h17: type = 6'b000010;
            7'h6f: type = 6'b000001;
        endcase
        
        //Selecting ALU Opcode based on type of instruciton
        if(r | i) alu_opcode = {funct3, funct7[6]};
        else if(u) alu_opcode = 0;
        
        //Deciding Immediate value based on type of instruction
        if(i) imm[11:0] = instruction[31:20];
        else if(s) imm[11:0] = {funct7, instruction[11:7]};
        else if(b) imm[11:0] = {instruction[31], instruction[7], funct7[5:0], instruction[11:8]};
        else if(u) imm[19:0] = instruction[31:12];
        else if(j) imm[19:0] = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
    end

endmodule
