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


module Decode(
    input clk,
    input [31:0] instruction,
    input [9:0] PC,
    
    output reg valid,
    output reg [9:0] Instruction_Address,
    output reg [0:5] type,
    output reg [3:0] alu_opcode,
    output reg [6:0] opcode,
    output reg [4:0] rs1, rs2, rdt,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [19:0] imm
    );
        
    wire r, i, s, b, u, j; 
    assign {r, i, s, b, u, j} = type; 
    reg [31:0] Instr;
    
    always @ (posedge clk) begin
        Instr = instruction;
        Instruction_Address = PC;
        //Extracting the opcode from the instruction
        opcode = Instr[6:0];
        
        //Obtaining the operand source and target addresses from the instruction
        rdt = Instr[11:7];
        rs1 = Instr[19:15];
        rs2 = Instr[24:20];
        
        //Getting the functions from the instruction
        funct3 = Instr[14:12];
        funct7 = Instr[31:25];
        
        valid = 1'b1;
        #1;
        //Deciding type of instruction based on opcode
        case(opcode)
            7'h33: begin //R
                type = 6'b100000;
                imm = funct7;
            end
            7'h67, 7'h03, 7'h13: begin //I
                type = 6'b010000;
                imm = {funct7, rs2};
            end
            7'h23: begin //S
                type = 6'b001000;
            end
            7'h63:begin //B
                type = 6'b000100;
                imm = {Instr[31], Instr[7], funct7[5:0], Instr[11:8]};
            end
            7'h37, 7'h17: begin //U
                type = 6'b000010;
                imm = {funct7, rs2, rs1, funct3};
            end
            7'h6f: begin //J
                type = 6'b000001;
                imm = {Instr[31], Instr[19:12], Instr[20], Instr[30:21]};
            end
            default: valid = 1'b0;
        endcase
        #1;
        //Selecting ALU Opcode based on type of instruciton
        if(r | i) alu_opcode = {funct3, funct7[6]};
        else if(u) alu_opcode = 0;
        
    end

endmodule
