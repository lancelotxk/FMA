module CLA_adder (A,B,cin,S,cout);
`include "parameters.v"
input cin;
input [CLA_GRP_WIDTH-1:0]A;
input [CLA_GRP_WIDTH-1:0]B;

output reg[CLA_GRP_WIDTH-1:0]S;
output reg cout;

reg [CLA_GRP_WIDTH-1:0]G;
reg [CLA_GRP_WIDTH-1:0]P;

reg [CLA_GRP_WIDTH-1:0]C;

integer i;
always @ (*) begin
for(i=0;i<CLA_GRP_WIDTH;i=i+1) begin
	G[i] <= A[i] & B[i];
	P[i] <= A[i] | B[i];
end

	C[0]<= G[0] | (cin&P[0]);
	S[0]<=A[0]^B[0]^cin;

for(i=1;i<CLA_GRP_WIDTH;i=i+1) begin
	C[i]<=G[i] | (C[i-1] & P[i]) ;
	S[i]<=A[i]^B[i]^C[i-1];
end
	cout<=C[CLA_GRP_WIDTH-1];
end
endmodule
