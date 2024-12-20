`timescale 1ns / 1ps

//Entire code of the processor is compiled in one file here

module Processor_Compiled(clk, Reset, out, file);

    input clk, Reset;    
    output [31:0] out, file;
        
    Synchronous_Core sync(.clk(clk), .Reset(Reset), .out(out), .file(file));
    
endmodule

module Synchronous_Core(clk, Reset, out, file);
    input clk, Reset;
    output [31:0] out, file;
//////////////////////////////////////////////////////////////////////////////////
// DECLARATIONS

    //Fetch Unit declarations
    wire [1:0] Branch;
    wire [9:0] TargetAddress;
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
    
    assign out = result;

    wire [31:0] mem_address, store_data;
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
    reg [31:0] Reg_File [0:15];
    assign op0 = rs0[4] ? Reg_File[rs0] : {28'b0, rs0[3:0]};
    assign op1 = rs1[4] ? Reg_File[rs1] : {28'b0, rs1[3:0]};
    wire [31:0] write_data;
    
    assign file = Reg_File[0]; 
    
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
        if(s) Reg_File[rdt] = write_data;
        else if(i) Reg_File[rdt] = result;        
    end
    
endmodule

module RAM(
    write_enable,
    address,
    data_in,
    data_out
);
    input write_enable;
    input [9:0] address;
    input [31:0] data_in;
    output reg [31:0] data_out;
    
    reg [31:0] memory [0:1023];

    always @(address) begin
        if (write_enable) begin
            memory[address] <= data_in;
        end
        data_out <= memory[address];
    end

endmodule

module Fetch(clk, Reset, Branch, TargetAddress, Instruction, Add, plus32);
    wire [9:0] Address, Previous;
    wire [31:0] I;
    reg [9:0] JumpTo;
    input clk, Reset;
    input Branch;
    input [9:0] TargetAddress;
    output [31:0] Instruction;
    output [9:0] Add;
    input [31:0] plus32;
        
    Prog_Count PC(
    .clk(clk),
    .Reset(Reset),
    .Jump(Branch),
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

module Prog_Count(clk,Reset,Jump,JumpTo,Address,Previous);
    input clk, Reset, Jump;
    input [9:0] JumpTo;
    output [9:0]Address, Previous;
    reg [9:0]Address, Previous;
    
    initial Address = 10'd0;
    
    always @(posedge clk)
    begin
        Previous = Address;
        
        if(Reset)
            Address = 10'd0;
        else if(Jump)
            Address = JumpTo;
        else
            Address = Address + 10'd1;
    end
    
endmodule

module Prog_Mem(clk,Reset,Address,Instruction,plus32);
  input clk, Reset;
  input [9:0]Address;
  output reg [31:0]Instruction;
  input [31:0] plus32;
  
  reg [31:0] Cache [4:0] [7:0];
  // Cache[0] and Cache[1] are Switching Caches.
  // Cache[2:4] are Subroutine Caches.
  reg [9:0] lb [4:0], ub [4:0];
  
  reg k=0;
  wire kbar;
  integer i;
  
  initial begin
    
//    for(i=0; i<8; i=i+1) Cache[0][i] = RAM[i];
    
    Cache[0][0] = 32'h00528003;
    Cache[0][1] = 32'h00228003;
    Cache[0][2] = 32'h00b18003;
    Cache[0][3] = 32'h00000000;
    Cache[0][4] = 32'h00000000;
    Cache[0][5] = 32'h00000000;
    Cache[0][6] = 32'h00000000;
    Cache[0][7] = 32'h00000000;
    Cache[0][8] = 32'h00000000;
    
    Cache[1][0] = 32'h00b18003;
    Cache[1][1] = 32'h00000000;
    Cache[1][2] = 32'h00000000;
    Cache[1][3] = 32'h00000000;
    Cache[1][4] = 32'h00000000;
    Cache[1][5] = 32'h00000000;
    Cache[1][6] = 32'h00000000;
    Cache[1][7] = 32'h00000000;
    Cache[1][8] = 32'h00000000;
//    lb[0] = 10'b0000000000; ub[0] = 10'b0000011111;
    lb[0] = 10'b0000000000; ub[0] = 10'b0000000111;
//    lb[1] = 10'b0000100000; ub[1] = 10'b0000111111;
    lb[1] = 10'b0000001000; ub[1] = 10'b0000001111;
    lb[2] = 10'b0100000000; ub[2] = 10'b0100011111;
  end
  
  assign kbar = ~k;
    always @ (posedge clk) begin
        if(Reset) // Reset/Flush logic
            Instruction = {32{1'b0}};
        else begin //Cache usage logic
                if(Address>=lb[k] && Address<=ub[k]) begin
                    Instruction <= {Cache[k][Address-lb[k]]};
                    Cache[kbar][Address-lb[kbar]] <= plus32;
                end
                else if(Address>=lb[2] && Address<=ub[2])
                    Instruction = {Cache[2][Address-lb[2]]}; 
                else if(Address>=lb[3] && Address<=ub[3])
                    Instruction = {Cache[3][Address-lb[3]]}; 
                else if(Address>=lb[4] && Address<=ub[4])
                    Instruction = {Cache[4][Address-lb[4]]}; 
                else
                    Instruction = plus32;
                
                //Switching cache logic
                if(Address==ub[k]) begin
                    lb[k] = ub[kbar] + 1;
                    ub[k] = ub[kbar] + 8;
                    k = kbar;
                end
        end
    end

endmodule

module Decode(clk,
    instruction, 
    type,
    opcode, alu_opcode,
    rs0, rs1, rdt,
    funct3, funct7,
    imm
    );
    
    input clk;
    input [31:0] instruction;
    output reg [5:0] type;
    output reg [3:0] alu_opcode;
    output reg [6:0] opcode;
    output reg [4:0] rs0, rs1, rdt;
    output reg [2:0] funct3;
    output reg [6:0] funct7;
    output reg [19:0] imm;
        
    wire r, i, s, b, u, j; 
    assign {r, i, s, b, u, j} = type; 
    
    always @ (posedge clk) begin
        //Extractnig the opcode from the instruction
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
        if(r | i) alu_opcode = {funct3, funct7[5]};
        else if(u) alu_opcode = 0;
        
        //Deciding Immediate value based on type of instruction
        if(i) imm[11:0] = instruction[31:20];
        else if(s) imm[11:0] = {funct7, instruction[11:7]};
        else if(b) imm[11:0] = {instruction[31], instruction[7], funct7[5:0], instruction[11:8]};
        else if(u) imm[19:0] = instruction[31:12];
        else if(j) imm[19:0] = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
    end

endmodule

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
    input [5:0] type;
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

module Branch(clk, 
    b, j, funct3, imm,
    op0, op1, 
    address, branch, targetAddress);
    
    input clk, b, j;
    input [2:0] funct3;
    input [19:0] imm;
    input [31:0] op0, op1;
    input [9:0] address;
    output reg branch;
    output reg [9:0] targetAddress;
    
    wire [9:0] target;
    reg signed [31:0] s_op0, s_op1;
    
    always @ (posedge clk) begin
        targetAddress <= address + imm;
        s_op0 <= op0; s_op1 <= op1;
        
        //Branch Logic
        if(j) branch = 1;
        else if(b) begin
            branch = 1;
            case(funct3)
                3'b000: branch = (op0 == op1);
                3'b001: branch = ~(op0 == op1);
                3'b100: branch = (s_op0 < s_op1);
                3'b101: branch = ~(s_op0 < s_op1);
                3'b110: branch = (op0 < op1);
                3'b111: branch = ~(op0 < op1);
                default: branch = 0;
            endcase
        end
        else branch = 0;
    end
    
endmodule

module ALU(clk, op0, op1, opcode, result);
    input clk;
    input [31:0] op0, op1;
    input [3:0] opcode;
    output reg [31:0] result ;  // ALU result

reg signed [31:0] s_op0, s_op1;

always @ (posedge clk) begin
    s_op0 <= op0; s_op1 <= op1;
    case (opcode)
      // Legal ALU instructions
      4'b0000  : result = op0 + op1 ; 
      4'b0001  : result = op0 - op1 ;
      4'b0100  : result = {{63{1'b0}}, (s_op0 < s_op1)} ;
      4'b0110  : result = {{63{1'b0}}, (op0 < op1)} ;
      4'b1000  : result = op0 ^ op1 ;
      4'b1100  : result = op0 | op1 ;
      4'b1110  : result = op0 & op1 ;
      4'b0010  : result = op0 << op1[4:0] ;
      4'b1010  : result = op0 >> op1[4:0] ;
      4'b1011  : result = s_op0 >>> op1[4:0] ;
      default  : result = 0 ;
   endcase
end

endmodule

module Loadstore(
    clk,
    s, 
    opcode, 
    funct3, 
    imm, 
    op0, op1, 
    mem_address, store_data);
    
   input clk, s;
   input [6:0] opcode;  // Opcode
   input [2:0] funct3;  // funct3
   input [11:0] imm;  // immediate
   input [31:0] op0, op1;  // Operand-0 and Operand-1 from register file
   output reg [31:0] mem_address, store_data; //Address and data

   always @ (posedge clk) begin
        if(s) begin
            case(funct3[1:0])
                0: store_data = op1[7:0];
                1: store_data = op1[15:0];
                default: store_data = op1 ;
            endcase
        end
        
        mem_address = op0 + {{(20){imm[11]}}, imm};
   end
   
endmodule
