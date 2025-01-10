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

module Processor(Reset);
//Additional top module to encapsulate the processor

    input Reset=0;    
    reg clk=0;
    
    always #10 clk = ~clk;
    
    Synchronous_Core sync(.clk(clk), .Reset(Reset));
        
endmodule
