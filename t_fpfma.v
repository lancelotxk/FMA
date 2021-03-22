module t_fpfma();
  `include "parameters.v"

  reg [WIDTH-1:0] A1,A2,A3,A4,A5,A6,A7,A8,A9,B1,B2,B3,B4,B5,B6,B7,B8,B9,C;
  reg [31:0] x_ideal;
  reg [23:0] x_man;
  reg [7:0] idealExp;
  reg [1:0] rnd;  
  wire [WIDTH-1:0] result;
  wire res_compare;
  /*
  wire [23:0] aSig={1'b1,A[22:0]};
  wire [23:0] bSig={1'b1,B[22:0]};
  wire [23:0] cSig={1'b1,C[22:0]};
  
  wire [7:0] aExp = A[30:23]; 
  wire [7:0] bExp = B[30:23];
  wire [7:0] cExp = C[30:23];
*/
    
  //wire [49:0] productSig = aSig * bSig;
  //wire [7:0] productExp = aExp + bExp;
  
  
  
  fpfma UUT(A1,A2,A3,A4,A5,A6,A7,A8,A9, 
	     B1,B2,B3,B4,B5,B6,B7,B8,B9,C, rnd,result);

  integer fd;
  initial begin
    rnd=2'b01;
	fd=$fopen("data.txt", "r");//   //fd=$fopen("testInputs.txt", "r");
    //op=0;
  end
  integer i;
  
  always @ * begin
    while(!$feof(fd)) begin
      $fscanf(fd, "%x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x", A1,A2,A3,A4,A5,A6,A7,A8,A9,B1,B2,B3,B4,B5,B6,B7,B8,B9,C, x_ideal);
     idealExp=x_ideal[30:23];
     x_man={1'b1,x_ideal[22:0]};
      #5;
    $display("A1=%x, B1=%x, C=%x, X=%x\n", A1, B1, C, x_ideal);
   end

  end
 
 //wire sig_compare = (UUT.renormalized!=x_man);
assign res_compare = result!=x_ideal;
//initial
//  # 5 $stop;



/*
integer i;
initial begin
A1=32'hC0A00000;   //3
A2=32'hC0A00000;
A3=32'hC0A00000;
A4=32'hC0A00000;
A5=32'hC0A00000;
A6=32'hC0A00000;
A7=32'hC0A00000;
A8=32'hC0A00000;
A9=32'hC0A00000;
B1=32'h3F800000;
B2=32'h3F800000;
B3=32'h3F800000;
B4=32'h3F800000;
B5=32'h3F800000;
B6=32'h3F800000;
B7=32'h3F800000;
B8=32'h3F800000;
B9=32'h3F800000;
     
C=32'h41700000;
x_ideal=32'h41200000;
$display("A1=%x, B1=%x, C=%x, X=%x\n", A1, B1, C, result);
end
assign res_compare = result!=x_ideal;
*/
/*
    for (i=0;i<25453;i=i+1) begin
      A = A + 8'hff;
      B = B + 4'hc;
      #5;
    end
  */  
 // end
  
endmodule
