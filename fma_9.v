module fpfma(A1,A2,A3,A4,A5,A6,A7,A8,A9, 
	     B1,B2,B3,B4,B5,B6,B7,B8,B9, C, rnd,result);
`include "parameters.v"

input [WIDTH-1:0] A1,A2,A3,A4,A5,A6,A7,A8,A9;
input [WIDTH-1:0] B1,B2,B3,B4,B5,B6,B7,B8,B9;
input [WIDTH-1:0] C;
input [1:0] rnd;
//input clk, rst;  
output [WIDTH-1:0] result;


//Unpacking and subnormal checks
wire aIsSubnormal, bIsSubnormal, cIsSubnormal;
wire [8:0] aSign, bSign;
wire cSign;
wire [EXP_WIDTH-1:0] a1Exp,a2Exp,a3Exp,a4Exp,a5Exp,a6Exp,a7Exp,a8Exp,a9Exp;
wire [EXP_WIDTH-1:0] b1Exp,b2Exp,b3Exp,b4Exp,b5Exp,b6Exp,b7Exp,b8Exp,b9Exp ;
wire [EXP_WIDTH-1:0] cExp;
wire [SIG_WIDTH:0] a1Sig,a2Sig,a3Sig,a4Sig,a5Sig,a6Sig,a7Sig,a8Sig,a9Sig; 
wire [SIG_WIDTH:0] b1Sig,b2Sig,b3Sig,b4Sig,b5Sig,b6Sig,b7Sig,b8Sig,b9Sig;
wire [SIG_WIDTH:0] cSig;


unpack PACK1(A1,A2,A3, aSign[0],a1Exp,a1Sig, aSign[1],a2Exp,a2Sig, aSign[2],a3Exp,a3Sig);
unpack PACK2(A4,A5,A6, aSign[3],a4Exp,a4Sig, aSign[4],a5Exp,a5Sig, aSign[5],a6Exp,a6Sig);
unpack PACK3(A7,A8,A9, aSign[6],a7Exp,a7Sig, aSign[7],a8Exp,a8Sig, aSign[8],a9Exp,a9Sig);

unpack PACK4(B1,B2,B3, bSign[0],b1Exp,b1Sig, bSign[1],b2Exp,b2Sig, bSign[2],b3Exp,b3Sig);
unpack PACK5(B4,B5,B6, bSign[3],b4Exp,b4Sig, bSign[4],b5Exp,b5Sig, bSign[5],b6Exp,b6Sig);
unpack PACK6(B7,B8,B9, bSign[6],b7Exp,b7Sig, bSign[7],b8Exp,b8Sig, bSign[8],b9Exp,b9Sig);

unpack PACK7(.A(),.B(),.aSign(), .aExp(), .aSig(),.bSign(), .bExp(), .bSig(),
		.C(C),.cSign(cSign), .cExp(cExp), .cSig(cSig),.cIsSubnormal(cIsSubnormal));

wire [8:0] product_sign=aSign ^ bSign;    // product_sign[0] is the sign of A1*B1




//Exponent comparison
wire [EXP_WIDTH-1:0] exp1;
wire [SHAMT_WIDTH-1:0] shamt_ab1,shamt_ab2,shamt_ab3,shamt_ab4,shamt_ab5,shamt_ab6,shamt_ab7,shamt_ab8,shamt_ab9,shamt_c;

exponentComparison  EC(a1Exp,a2Exp,a3Exp,a4Exp,a5Exp,a6Exp,a7Exp,a8Exp,a9Exp,
		       b1Exp,b2Exp,b3Exp,b4Exp,b5Exp,b6Exp,b7Exp,b8Exp,b9Exp,cExp,cIsSubnormal,
		       shamt_ab1,shamt_ab2,shamt_ab3,shamt_ab4,shamt_ab5,shamt_ab6,shamt_ab7,shamt_ab8,shamt_ab9,
		       shamt_c,exp1);

//align C
wire [3*(SIG_WIDTH+1)+6:0] CAligned ;  // 79bits which the MSB is the sign

align ALGN(cSig, shamt_c, cSign,CAligned);

// 9*booth multiplier and the outputs are 18 CSA sum and carry
wire [2*(SIG_WIDTH+1)-1:0] S1big,S2big,S3big,S4big,S5big,S6big,S7big,S8big,S9big;
wire [2*(SIG_WIDTH+1)-1:0] C1big,C2big,C3big,C4big,C5big,C6big,C7big,C8big,C9big;

DW02_multp  multp_1(.a(a1Sig),.b(b1Sig),.tc(1'b0),.out0(S1big),.out1(C1big) ); 
DW02_multp  multp_2(.a(a2Sig),.b(b2Sig),.tc(1'b0),.out0(S2big),.out1(C2big) ); 
DW02_multp  multp_3(.a(a3Sig),.b(b3Sig),.tc(1'b0),.out0(S3big),.out1(C3big) ); 
DW02_multp  multp_4(.a(a4Sig),.b(b4Sig),.tc(1'b0),.out0(S4big),.out1(C4big) ); 
DW02_multp  multp_5(.a(a5Sig),.b(b5Sig),.tc(1'b0),.out0(S5big),.out1(C5big) ); 
DW02_multp  multp_6(.a(a6Sig),.b(b6Sig),.tc(1'b0),.out0(S6big),.out1(C6big) ); 
DW02_multp  multp_7(.a(a7Sig),.b(b7Sig),.tc(1'b0),.out0(S7big),.out1(C7big) ); 
DW02_multp  multp_8(.a(a8Sig),.b(b8Sig),.tc(1'b0),.out0(S8big),.out1(C8big) ); 
DW02_multp  multp_9(.a(a9Sig),.b(b9Sig),.tc(1'b0),.out0(S9big),.out1(C9big) ); 


// shift the result according to the shamt of the exps
wire [2*(SIG_WIDTH+1):0] s1,s2,s3,s4,s5,s6,s7,s8,s9; //49bits
wire [2*(SIG_WIDTH+1):0] c1,c2,c3,c4,c5,c6,c7,c8,c9; //49bits

shifter mul_shift (S1big,S2big,S3big,S4big,S5big,S6big,S7big,S8big,S9big,
		   C1big,C2big,C3big,C4big,C5big,C6big,C7big,C8big,C9big,
		   shamt_ab1,shamt_ab2,shamt_ab3,shamt_ab4,shamt_ab5,shamt_ab6,shamt_ab7,shamt_ab8,shamt_ab9,
		   product_sign,
		   s1,s2,s3,s4,s5,s6,s7,s8,s9,c1,c2,c3,c4,c5,c6,c7,c8,c9);

wire [2*(SIG_WIDTH+1)+4:0] result_9_man_sum ,result_9_man_carry;
adder_pp add (s1,s2,s3,s4,s5,s6,s7,s8,s9,c1,c2,c3,c4,c5,c6,c7,c8,c9,result_9_man_sum ,result_9_man_carry);
wire [52:0] sumof6 = s1+s2+s3+s4+s5+s6+s7+s8+s9+c1+c2+c3+c4+c5+c6+c7+c8+c9;
wire [2*(SIG_WIDTH+1)+4:0] result_9_man = result_9_man_sum+result_9_man_carry;

wire [25:0] pad_man_1 = {26{result_9_man_sum[2*(SIG_WIDTH+1)+4]}};
wire [3*(SIG_WIDTH+1)+6:0] pad_man_sum = {pad_man_1,result_9_man_sum};
wire [25:0] pad_man_2 = {26{result_9_man_carry[2*(SIG_WIDTH+1)+4]}};
wire [3*(SIG_WIDTH+1)+6:0] pad_man_carry = {pad_man_2,result_9_man_carry};
// send to a group of 3_2 compressors
wire [3*(SIG_WIDTH+1)+6:0] sum,carry;
compressor3_2_group compress_group (pad_man_sum,pad_man_carry,CAligned,sum,carry);
wire [3*(SIG_WIDTH+1)+6:0] carry_shift = carry<<1;

wire [3*(SIG_WIDTH+1)+6:0] man_abc_pre = sum+carry_shift;
wire [3*(SIG_WIDTH+1)+6:0] man_abc;
wire sign_eff;
assign sign_eff = man_abc_pre[3*(SIG_WIDTH+1)+6];

assign man_abc = man_abc_pre[3*(SIG_WIDTH+1)+6]? (~ man_abc_pre)+1'b1 : man_abc_pre ; 

wire [3*(SIG_WIDTH+1)+5:0] man_abc_bin = man_abc[3*(SIG_WIDTH+1)+5:0];   //the MSB of man_abs is the sign of the result

wire [6:0] num;

LZC lzc (man_abc_bin,num);

wire [SIG_WIDTH:0] normalized;
wire [EXP_WIDTH-1:0] exp;
normalize normalize_shift (man_abc_bin,num,exp1,normalized,exp);

//wire [WIDTH-1:0] result;

assign result = {sign_eff,exp,normalized[SIG_WIDTH-1:0]};





endmodule
