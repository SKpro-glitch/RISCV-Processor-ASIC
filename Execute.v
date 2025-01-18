`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 16:11:40
// Design Name: 
// Module Name: Execute
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


module Execute(
    input clk, valid,
    input [0:5] type,
    input [3:0] alu_opcode,
    input [6:0] opcode,
    input [31:0] op0, op1,
    input [4:0] rdt,
    input [2:0] funct3,
    input [6:0] funct7,
    input [19:0] imm,
    input [9:0] address,
    
    output reg [4:0] write_address,
    output [31:0] result,
    output s, i, branch,
    output [31:0] mem_address,
    output [31:0] store_data,
    output [9:0] targetAddress
    );
    
    reg valid_check;
    reg [0:5] type_pipo;
    reg [3:0] alu_opcode_pipo;
    reg [6:0] opcode_pipo;
    reg [31:0] op0_pipo, op1_pipo;
    reg [2:0] funct3_pipo;
    reg [6:0] funct7_pipo;
    reg [19:0] imm_pipo;
    reg [9:0] address_pipo;
         
    reg en_alu=0, en_bu=0, en_lsu=0;
    
    wire r, b, u, j; 
    assign {r, i, s, b, u, j} = type_pipo; 

    always @ (posedge clk) begin
        valid_check <= valid;
        #1;
        if(valid) begin        
            type_pipo <= type;
            alu_opcode_pipo <= alu_opcode;
            opcode_pipo <= opcode;
            op0_pipo <= op0; op1_pipo <= op1;
            funct3_pipo <= funct3;
            funct7_pipo <= funct7;
            imm_pipo <= imm;
            address_pipo <= address;
            write_address <= rdt;
            
            if(i) {en_alu, en_bu, en_lsu} = 3'b100;
            else if(b | j) {en_alu, en_bu, en_lsu} = 3'b010;
            else if(s) {en_alu, en_bu, en_lsu} = 3'b001;
        end
    end
    
    always @ (negedge clk) {en_alu, en_bu, en_lsu} = 3'b000;
    
    Branch bu(
    .en(en_bu),
    .b(b), .j(j),
    .funct3(funct3_pipo), .imm(imm_pipo),
    .op0(op0_pipo), .op1(op1_pipo),
    .address(address_pipo),
    .branch(branch),
    .targetAddress(targetAddress));
    
    ALU alu(
    .en(en_alu),
    .i(i),
    .op0(op0_pipo), .op1(op1_pipo), 
    .opcode(alu_opcode_pipo),
    .result(result));
    
    Loadstore lsu(
    .en(en_lsu),
    .s(s), 
    .opcode(opcode_pipo), 
    .funct3(funct3_pipo), 
    .imm(imm_pipo[11:0]), 
    .op0(op0_pipo), .op1(op1_pipo), 
    .mem_address(mem_address), 
    .store_data(store_data));

endmodule
