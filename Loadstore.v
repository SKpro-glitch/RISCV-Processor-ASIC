`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2024 12:36:47
// Design Name: 
// Module Name: MAC
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

module Loadstore(
   input en, s,
   input [2:0] funct3,      // funct3
   input [11:0] imm,        // immediate
   input [31:0] op1, op2,   // Operand-0 and Operand-1 from register file
   
   output reg [31:0] mem_address, store_data //Address and data
   );
   
   always @ (posedge en) begin
        case(funct3[1:0])
            0: store_data = op2[7:0];
            1: store_data = op2[15:0];
            default: store_data = op2;
        endcase
        
        if(s) mem_address = op1 + {{(20){imm[11]}}, imm};
   end
   
endmodule
