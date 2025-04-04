`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2024 15:27:57
// Design Name: 
// Module Name: ALU
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


module ALU(
    input en, r, i,
    input [31:0] op1, op2, imm,
    input [3:0] alu_opcode,
    
    output reg [31:0] result  // ALU result
    );
    
    reg signed [31:0] op3, s_op1, s_op3;
    
    always @ (posedge en) begin
            #1;
            if(r) op3 = op2;
            else op3 = imm;
            
            s_op1 = op1; s_op3 = op3;
            
            case (alu_opcode)
              // Legal ALU instructions
              4'b0000  : result = op1 + op3 ; //Addition
              4'b0001  : result = op1 - op3 ; //Subtraction
              4'b0100  : result = {{31{1'b0}}, (s_op1 < s_op3)} ; // Signed less than
              4'b0110  : result = {{31{1'b0}}, (op1 < op3)} ; // Unsigned less than
              4'b1000  : result = op1 ^ op3 ; // Bitwise XOR
              4'b1100  : result = op1 | op3 ; // Bitwise OR
              4'b1110  : result = op1 & op3 ; // Bitwise AND
              4'b0010  : result = op1 << op3[4:0] ; //Left shift
              4'b1010  : result = op1 >> op3[4:0] ; //Right shift
              4'b1011  : result = s_op1 >>> op3[4:0] ; //Signed right shift
              default  : result = 0 ;
           endcase
    end
    
endmodule
