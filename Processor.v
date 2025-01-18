`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.08.2024 15:48:35
// Design Name: 
// Module Name: Processor
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


module Processor(clk, Reset, out, file);

    input clk, Reset;    
    output [31:0] out, file;
        
    Synchronous_Core sync(.clk(clk), .Reset(Reset), .out(out), .file(file));
    
endmodule
