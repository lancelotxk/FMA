module compressor3_2_group (in1,in2,in3,s,c);


parameter GRP_WIDTH=79;
    
input [GRP_WIDTH-1:0] in1, in2, in3;
output [GRP_WIDTH-1:0] s, c;

genvar i;
generate
  for (i=0;i<79;i=i+1)
	compress3_2 compress({in1[i], in2[i],in3[i]}, s[i], c[i]);
endgenerate

endmodule
