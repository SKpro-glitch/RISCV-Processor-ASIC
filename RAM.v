`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2024 19:56:00
// Design Name: 
// Module Name: RAM
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
