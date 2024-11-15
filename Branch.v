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
