module Prog_Mem(
  input clk, Reset,
  input [9:0] Address,
  input [31:0] plus32,
  
  output reg [31:0] Instruction
  );;
  
  reg [31:0] Cache [4:0] [7:0];
  // Cache[0] and Cache[1] are Switching Caches.
  // Cache[2:4] are Subroutine Caches.
  reg [9:0] lb [4:0], ub [4:0];
  
  reg k=0;
  wire kbar;
  integer i;
  
  initial begin
    
//    for(i=0; i<8; i=i+1) Cache[0][i] = RAM[i];
    
    Cache[0][0] = 32'h00528003;
    Cache[0][1] = 32'h00228003;
    Cache[0][2] = 32'h00b18003;
    Cache[0][3] = 32'h00000000;
    Cache[0][4] = 32'h00000000;
    Cache[0][5] = 32'h00000000;
    Cache[0][6] = 32'h00000000;
    Cache[0][7] = 32'h00000000;
    
    Cache[1][0] = 32'h00528003;
    Cache[1][1] = 32'h00b18003;
    Cache[1][2] = 32'h00000023;
    Cache[1][3] = 32'h00000000;
    Cache[1][4] = 32'h00000000;
    Cache[1][5] = 32'h00000000;
    Cache[1][6] = 32'h00000000;
    Cache[1][7] = 32'h00000000;
    
    lb[0] = 10'b0000000000; ub[0] = 10'b0000000111;
    lb[1] = 10'b0000001000; ub[1] = 10'b0000001111;
    lb[2] = 10'b0100000000; ub[2] = 10'b0100011111;
  end
  
  assign kbar = ~k;
    always @ (posedge clk) begin
        if(Reset) // Reset/Flush logic
                Instruction <= {32{1'b0}};
        else begin //Cache usage logic
                if(Address>=lb[k] && Address<=ub[k]) begin
                    Instruction <= {Cache[k][Address-lb[k]]};
                    Cache[kbar][Address-lb[kbar]] <= plus32;
                end
                else if(Address>=lb[2] && Address<=ub[2])
                    Instruction <= {Cache[2][Address-lb[2]]}; 
                else if(Address>=lb[3] && Address<=ub[3])
                    Instruction <= {Cache[3][Address-lb[3]]}; 
                else if(Address>=lb[4] && Address<=ub[4])
                    Instruction <= {Cache[4][Address-lb[4]]}; 
                else
                    Instruction = plus32;
                
                //Switching cache logic
                if(Address==ub[k]) begin
                    lb[k] <= ub[kbar] + 1;
                    ub[k] <= ub[kbar] + 8;
                    k <= kbar;
                end
        end
    end

endmodule
