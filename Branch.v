`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2024 16:29:49
// Design Name: 
// Module Name: Branch
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


module Branch(
    input en, b, j,
    input [2:0] funct3,
    input [19:0] imm,
    input [31:0] op1, op2,
    input [9:0] address,
    
    output reg branch,
    output reg [9:0] targetAddress
    );
    
    wire [9:0] target;
    reg signed [31:0] s_op1, s_op2;
    
    always @ (posedge en) begin
        targetAddress <= address + imm;
        s_op1 <= op1; s_op2 <= op2;
        
        //Branch Logic
        if(j) branch = 1;
        else if(b) begin
            branch = 1;
            case(funct3)
                3'b000: branch = (op1 == op2);
                3'b001: branch = ~(op1 == op2);
                3'b100: branch = (s_op1 < s_op2);
                3'b101: branch = ~(s_op1 < s_op2);
                3'b110: branch = (op1 < op2);
                3'b111: branch = ~(op1 < op2);
                default: branch = 0;
            endcase
        end
        else branch = 0;
    end
    
endmodule
