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
    input [31:0] op1, op2,
    input [4:0] rdt,
    input [2:0] funct3,
    input [6:0] funct7,
    input [19:0] imm,
    input [9:0] address,
    
    output reg [4:0] write_address,
    output reg s, i, 
    output branch,
    output [31:0] mem_address,
    output reg [31:0] store_data,
    output [9:0] targetAddress
    );
    
    reg valid_check;
    reg [0:5] type_pipo;
    reg [3:0] alu_opcode_pipo;
    reg [6:0] opcode_pipo;
    reg [31:0] op1_pipo, op2_pipo;
    reg [2:0] funct3_pipo;
    reg [6:0] funct7_pipo;
    reg [19:0] imm_pipo;
    reg [9:0] address_pipo;
         
    reg en_alu=0, en_bu=0, en_lsu=0;
    
    reg r, b, u, j; 
    
    wire [31:0] alu_result, lsu_out;
    
    always @ (posedge clk) begin
        valid_check = valid;
        {en_alu, en_bu, en_lsu} = 3'b000;
        if(valid_check) begin        
            {r, i, s, b, u, j} = type;
            alu_opcode_pipo = alu_opcode;
            opcode_pipo = opcode;
            op1_pipo = op1; op2_pipo = op2;
            funct3_pipo = funct3;
            funct7_pipo = funct7;
            imm_pipo = imm;
            address_pipo = address;
            write_address = rdt;
            
            #1;
            
            if(r) {en_alu, en_bu, en_lsu} = 3'b100;
            else if(b | j) {en_alu, en_bu, en_lsu} = 3'b010;
            else if(s) {en_alu, en_bu, en_lsu} = 3'b001;
            else if(i) begin
                if(opcode==7'h13) {en_alu, en_bu, en_lsu} = 3'b100;
                else {en_alu, en_bu, en_lsu} = 3'b001;
            end
            else {en_alu, en_bu, en_lsu} = 3'b000;

            #2;
            
            if(en_alu) store_data = alu_result;
            else if(en_lsu) store_data = lsu_out;
            else if(en_bu) begin end 
            else store_data = {{10{1'b0}}, imm_pipo};
        end
    end
        
    Branch bu(
    .en(en_bu),
    .b(b), .j(j),
    .funct3(funct3_pipo), .imm(imm_pipo),
    .op1(op1_pipo), .op2(op2_pipo),
    .address(address_pipo),
    
    .branch(branch),
    .targetAddress(targetAddress));
    
    ALU alu(
    .en(en_alu),
    .r(r), .i(i),
    .op1(op1_pipo), .op2(op2_pipo),
    .imm(imm_pipo),
    .alu_opcode(alu_opcode_pipo),
    
    .result(alu_result));
    
    Loadstore lsu(
    .en(en_lsu),
    .s(s), 
    .funct3(funct3_pipo), 
    .imm(imm_pipo[11:0]), 
    .op1(op1_pipo), .op2(op2_pipo), 
    
    .mem_address(mem_address), 
    .store_data(lsu_out));

endmodule
