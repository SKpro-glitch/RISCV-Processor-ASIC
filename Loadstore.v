module Loadstore(
    input clk, s,
    input [6:0] opcode,  // Opcode
    input [2:0] funct3,  // funct3
    input [11:0] imm,  // immediate
    input [31:0] op0, op1,  // Operand-0 and Operand-1 from register file
    output reg [31:0] mem_address, store_data //Address and data
    );

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
