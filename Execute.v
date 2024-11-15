module Execute(
    clk,
    type,
    opcode, alu_opcode,
    op0, op1,
    funct3, funct7,
    imm, address,
    result,
    branch,
    mem_address, 
    store_data,
    targetAddress
    );
    
    input clk;
    input [0:5] type;
    input [3:0] alu_opcode;
    input [6:0] opcode;
    input [31:0] op0, op1;
    input [2:0] funct3;
    input [6:0] funct7;
    input [19:0] imm;
    input [9:0] address;
    output [31:0] result;
    output branch;
    output [31:0] mem_address;
    output [31:0] store_data;
    output [9:0] targetAddress;
    
    Branch bu(.clk(clk),
    .b(type[3]), .j(type[5]),
    .funct3(funct3), .imm(imm),
    .op0(op0), .op1(op1),
    .address(address),
    .branch(branch),
    .targetAddress(targetAddress));
    
    ALU alu(.clk(clk),
    .i(type[1]),
    .op0(op0), .op1(op1), 
    .opcode(alu_opcode),
    .result(result));
    
    Loadstore lsu(
    .clk(clk),
    .s(type[2]), 
    .opcode(opcode), 
    .funct3(funct3), 
    .imm(imm[11:0]), 
    .op0(op0), .op1(op1), 
    .mem_address(mem_address), 
    .store_data(store_data));

endmodule
