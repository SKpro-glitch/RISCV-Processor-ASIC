`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.02.2025 16:20:14
// Design Name: 
// Module Name: Data_RAM
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


module Data_RAM(
    input read_enable, write_enable,
    input [9:0] read_address, write_address,
    input [31:0] data_in,
    
    output reg [31:0] data_out
    );
    
    reg [31:0] memory [0:1023];
    
    initial memory [0] = 32'h22222222;
    
    
    always @ (posedge read_enable) data_out = memory[read_address];
    
    always @ (posedge write_enable) memory[write_address] = data_in;

endmodule
