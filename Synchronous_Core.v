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


module Synchronous_Core(
    input clk, Reset,
    
    output [31:0] out, file
    );
//////////////////////////////////////////////////////////////////////////////////
// DECLARATIONS

    //Fetch Unit declarations
    wire Branch;
    wire [9:0] TargetAddress;
    wire [31:0] Instruction;
    wire [9:0] Add;
    
    //Decode Unit declarations
    wire valid;
    wire [0:5] type;
    wire [3:0] opcode; 
    wire [6:0] alu_opcode;
    wire [4:0] rs0, rs1, rdt;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [11:0] imm;
        
    //Execute Unit declarations
    wire [31:0] op0, op1;
    wire s, i;
    wire [4:0] write_address;
    wire [9:0] mem_address;
    wire [31:0] result;    
    assign out = result;
    
    //Memory Access and Writeback Unit declarations
    wire [31:0] write_data;
    reg [4:0] reg_file_address;
    reg [31:0] alu_result;
    reg type_s, type_i;
//////////////////////////////////////////////////////////////////////////////////
// SUPPLEMENTARY COMPONENTS

    //Instruction RAM
    wire instruction_write;
    wire [31:0] data_in;
    wire [31:0] data_out;
    reg [9:0] instruction_address;
        
    RAM i_ram(
    .write_enable(instruction_enable),
    .address(instruction_address),
    .data_in(data_in),
    .data_out(data_out)
    );
    
    always @ * begin
        if(|Branch) 
            instruction_address = TargetAddress;
        else 
            instruction_address = Add;
    end
    
    //Register File
    reg [31:0] Reg_File [0:15];
    
    assign op0 = rs0[4] ? Reg_File[rs0] : {28'b0, rs0[3:0]};
    assign op1 = rs1[4] ? Reg_File[rs1] : {28'b0, rs1[3:0]};
    
    assign file = Reg_File[0];
    
    reg [9:0] data_address=0;
    
    //Data RAM
    RAM d_ram(
    .write_enable(type_s),
    .address(data_address),
    .data_in(store_data),
    .data_out(write_data)
    );
    
//////////////////////////////////////////////////////////////////////////////////
    //PIPELINE BEGINS
    
    // Stage 1
    Fetch fu(.clk(clk),
    .Reset(Reset),
    .Branch(Branch),
    .TargetAddress(TargetAddress),
    .plus32(data_out),
    
    .Instruction(Instruction),
    .Add(Add)
    );
    
    // Stage 2
    Decode du(.clk(clk),
    .instruction(Instruction), 
    
    .valid(valid),
    .type(type),
    .opcode(opcode), .alu_opcode(alu_opcode),
    .rs0(rs0), .rs1(rs1), .rdt(rdt),
    .funct3(funct3), .funct7(funct7),
    .imm(imm)
    );
    
    // Stage 3
    Execute eu(.clk(clk),
    .valid(valid),
    .type(type),
    .opcode(opcode), .alu_opcode(alu_opcode),
    .op0(op0), .op1(op1), .rdt(rdt),
    .funct3(funct3), .funct7(funct7),
    .imm(imm), .address(Add),
    
    .targetAddress(TargetAddress),
    .write_address(write_address),
    .result(result),
    .s(s), .i(i),
    .branch(Branch),
    .mem_address(mem_address), 
    .store_data(store_data)
    );
    
    // Stage 4
    //Memory Access and Write-Back logic
    always @ (posedge clk) begin
        //Writing to Register File / Store operation
        reg_file_address <= write_address;
        data_address <= mem_address;
        alu_result <= result;
        {type_s, type_i} <= {s, i};
        #5;
        if(type_s) Reg_File[reg_file_address] <= write_data;
        else if(type_i) Reg_File[reg_file_address] <= alu_result;        
    end
    
endmodule
