module ALU(clk, i, op0, op1, opcode, result);
    input clk, i;
    input [31:0] op0, op1;
    input [3:0] opcode;
    output reg [31:0] result ;  // ALU result

reg signed [31:0] s_op0, s_op1;

always @ (posedge clk) begin
    if(i) begin
    s_op0 <= op0; s_op1 <= op1;
    case (opcode)
      // Legal ALU instructions
      4'b0000  : result = op0 + op1 ; //Addition
      4'b0001  : result = op0 - op1 ; //Subtraction
      4'b0100  : result = {{63{1'b0}}, (s_op0 < s_op1)} ; // Signed less than
      4'b0110  : result = {{63{1'b0}}, (op0 < op1)} ; // Unsigned less than
      4'b1000  : result = op0 ^ op1 ; // Bitwise XOR
      4'b1100  : result = op0 | op1 ; // Bitwise OR
      4'b1110  : result = op0 & op1 ; // Bitwise AND
      4'b0010  : result = op0 << op1[4:0] ; //Left shift
      4'b1010  : result = op0 >> op1[4:0] ; //Right shift
      4'b1011  : result = s_op0 >>> op1[4:0] ; //Signed right shift
      default  : result = 0 ;
   endcase
   end
end

endmodule
