module align(C, shamt, cSign,CAligned);
  `include "parameters.v"
input [SIG_WIDTH:0] C;
input cSign;
input [SHAMT_WIDTH-1:0] shamt;
output [3*(SIG_WIDTH+1)+6:0] CAligned;//79-bit
//output sticky;
  
/*
wire [SIG_WIDTH+2*(SIG_WIDTH+1):0] T;
  genvar i;
  generate
    for(i=2*(SIG_WIDTH+1);i<=SIG_WIDTH+2*(SIG_WIDTH+1);i=i+1) begin: gen_T
      assign T[i]=|C[i-2*(SIG_WIDTH+1):0];
    end
  endgenerate
*/
wire [3*(SIG_WIDTH+1)+6:0] CAligned_pre;
assign CAligned_pre = {2'b0,C,{(2*(SIG_WIDTH+1)+2+2+1){1'b0}}} >> shamt; //2,24, 53
assign CAligned=(cSign)? ~CAligned_pre:CAligned_pre;

 
//assign sticky = (shamt< 2*(SIG_WIDTH+1) + 7 /*55*/)?1'b0:T[shamt];   //why 55??

  
endmodule
