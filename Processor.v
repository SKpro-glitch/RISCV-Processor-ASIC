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


module Processor(
    input clk, Reset,
    
    output [31:0] out, reg_file0
    /*
    output [0:5] Type,
    output [3:0] Opcode, 
    output [31:0] Op1, Op2,
    output [19:0] Immediate */
    );
//////////////////////////////////////////////////////////////////////////////////
// DECLARATIONS

    //Fetch Unit declarations
    wire Branch;
    wire [9:0] TargetAddress;
    wire [31:0] Instruction;
    wire [9:0] PC;
    
    //Decode Unit declarations
    wire valid_buf;
    wire [0:5] type_buf;
    wire [3:0] opcode_buf; 
    wire [6:0] alu_opcode_buf;
    wire [4:0] rs1_buf, rs2_buf, rdt_buf;
    wire [2:0] funct3_buf;
    wire [6:0] funct7_buf;
    wire [19:0] imm_buf;
    wire [9:0] Instruction_Address;
            
    //Operand Forward Control declarations
    reg valid;
    reg [9:0] current_address;
    reg [0:5] type;
    reg [3:0] opcode; 
    reg [6:0] alu_opcode;
    reg [4:0] rs1, rs2, rdt;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [19:0] imm;
    reg [31:0] op1, op2;

    assign {Type, Opcode, Op1, Op2, Immediate} = {type, opcode, op1, op2, imm};
    
    //Execute Unit declarations
    wire s, i;
    wire [4:0] write_address;
    wire [9:0] mem_address;
    wire [31:0] store_data;
    
    //Memory Access and Writeback Unit declarations
    reg [31:0] write_data;
    reg [4:0] reg_file_address;
    reg type_s, type_i;
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
    
    reg read=0;
    wire [31:0] load_data;
    reg [9:0] read_mem_address=0, write_mem_address=0;
    
    Data_RAM data_ram(
    .read_enable(read),
    .write_enable(type_s),
    .read_address(read_mem_address),
    .write_address(write_mem_address),
    .data_in(write_data),
    .data_out(load_data)
    );
  
    //Register File
    reg [31:0] Reg_File [0:31];
    integer loop;
    initial begin
        for(loop=0; loop<32; loop=loop+1)
            Reg_File[loop] = 0;
    end
    
    assign file = Reg_File[0]; 

    always @ (*) begin
    end

    
    always @ (negedge clk) begin
        //Instruction Address Control
        if(Branch)
            Ram_add = TargetAddress;
        else 
            Ram_add = current_address;

        //Operand Forward Control
        valid = valid_buf;
        current_address = Instruction_Address;
        type = type_buf;
        opcode = opcode_buf;
        alu_opcode = alu_opcode_buf;
        rs1 = rs1_buf;
        rs2 = rs2_buf;
        rdt = rdt_buf;
        funct3 = funct3_buf;
        funct7 = funct7_buf;
        imm = imm_buf;
        
        op1 = Reg_File[rs1_buf];
        read_mem_address = op1 + imm;
        read = 1;
        #1 op2 = type[1] ? load_data  : Reg_File[rs2_buf];
        read = 0;
    end
                
//////////////////////////////////////////////////////////////////////////////////
    //PIPELINE BEGINS
    
    // Stage 1
    Fetch fu(
    .clk(clk),
    .Reset(Reset),
    .Branch(Branch),
    .TargetAddress(TargetAddress),
    .plus32(data_out),
    
    .Instruction(Instruction),
    .Add(PC)
    );
    
    // Stage 2
    Decode du(
    .clk(clk),
    .instruction(Instruction), 
    .PC(PC),
    
    .valid(valid_buf),
    .Instruction_Address(Instruction_Address),
    .type(type_buf),
    .opcode(opcode_buf), .alu_opcode(alu_opcode_buf),
    .rs1(rs1_buf), .rs2(rs2_buf), .rdt(rdt_buf),
    .funct3(funct3_buf), .funct7(funct7_buf),
    .imm(imm_buf)
    );
    
    // Stage 3
    Execute eu(
    .clk(clk),
    .valid(valid),
    .type(type),
    .opcode(opcode), .alu_opcode(alu_opcode),
    .op1(op1), .op2(op2), .rdt(rdt),
    .funct3(funct3), .funct7(funct7),
    .imm(imm), .address(current_address),
    
    .write_address(write_address),
    .s(s), .i(i),
    .branch(Branch),
    .mem_address(mem_address), 
    .store_data(store_data),
    .targetAddress(TargetAddress)
    );
    
    // Stage 4
    //Memory Access and Write-Back logic
    
    assign out = Instruction;
    assign reg_file0 = Reg_File[0];
    
    always @ (posedge clk) begin
        //Writing to Register File / Store operation
        #1;
        type_s = s;
        reg_file_address = write_address;
        write_data = store_data;
        write_mem_address = mem_address;
        #1;
        if(!type_s) Reg_File[reg_file_address] = write_data;        
    end
    
endmodule
