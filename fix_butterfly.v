`include "fix_adder.v"
`include "fix_mult.v"
//`define Debug
//`define Debug_butterfly
module fix_butterfly#(
    parameter WIDTHa = 16,//X
    parameter WIDTHb = 16,//SIN,COS
    parameter WIDTHr = 16 ,
    parameter WIDTH_I=9,
    parameter WIDTH_F=23
)
(
    input clk,
    input rstn,
    input [WIDTHa-1:0] x1_r,x1_i,x2_r,x2_i,//9.7
    input [WIDTHb-1:0] sinValue,cosValue, //2.14
    output reg [WIDTHr-1:0] y1_r,y1_i,y2_r,y2_i,//9.7
    input en,
    output reg vld_out,
    output overflow 
);

parameter T=10;
//y1_r=x1_r+(factory_cos*x2_r-factory_sin*x2_i)
//y1_i=x1_i+(factory_sin*x2_r+factory_cos*x2_i)
//y2_r=x1_r-(factory_cos*x2_r-factory_sin*x2_i)
//y2_i=x1_i-(factory_sin*x2_r+factory_cos*x2_i)

reg [WIDTHa-1:0] a,b;
reg [WIDTHb-1:0]c,d;
wire [WIDTHr-1:0]ac,bd,ad,bc;
wire [WIDTHr-1:0]temp_r,temp_i;
reg en_reg=0;

//先计算ac,bd,ad,bc;
//在计算temp_r=ac-bd,temp_r=ad+bc;
//最后计算 y1_r=x1_r+temp_r;y1_r=x1_i+temp_i;
//y2_r=x2_r-temp_r;y2_r=x2_i-temp_i;

reg [1:0] cnt;

always @(posedge clk or negedge rstn ) begin
    if(!rstn)
        begin
          cnt<=0;
        end
    else if(cnt==0&&en==1)
        cnt<=cnt+1;
    else if(cnt>0)
        if(cnt==3)
            cnt<=0;
        else cnt<=cnt+1;
    end     

always @(posedge clk or negedge rstn ) begin
    if(!rstn)//
        begin
           a<=0;b<=0;c<=0;d<=0;
        end
    else if(en==1&&cnt==0)
        begin
          a<=x2_r;b<=x2_i;c<=cosValue;d<=sinValue;
        end
end

always @(posedge clk) begin
    en_reg<=en;
end
wire en_multi,vld_out1,vld_out2,vld_out3,vld_out4;
wire vld_out5,vld_out6,vld_out7,vld_out8,vld_out9,vld_out10,vld_out_all;
//reg vld_out_reg;
assign en_multi=en_reg;

fix_mult #(.WIDTHa(WIDTHa), .WIDTHb(WIDTHb), .WIDTHr(WIDTHr)) fix_mult_u1(.clk(clk), .rstn(rstn),.a(a),.b(c),.vld_in(en_multi),.vld_out(vld_out1),.r(ac));
fix_mult #(.WIDTHa(WIDTHa), .WIDTHb(WIDTHb), .WIDTHr(WIDTHr))fix_mult_u2(.clk(clk), .rstn(rstn),.a(b),.b(d),.vld_in(en_multi),.vld_out(vld_out2),.r(bd));
fix_mult #(.WIDTHa(WIDTHa), .WIDTHb(WIDTHb), .WIDTHr(WIDTHr))fix_mult_u3(.clk(clk), .rstn(rstn),.a(a),.b(d),.vld_in(en_multi),.vld_out(vld_out3),.r(ad));
fix_mult #(.WIDTHa(WIDTHa), .WIDTHb(WIDTHb), .WIDTHr(WIDTHr))fix_mult_u4(.clk(clk), .rstn(rstn),.a(b),.b(c),.vld_in(en_multi),.vld_out(vld_out4),.r(bc));

wire en_add1;
assign en_add1=vld_out1&&vld_out2&&vld_out3&&vld_out4;
reg [WIDTHr-1:0]ad_reg,bc_reg,ac_reg,bd_reg;
reg en_add1_reg=0;
always @(posedge clk) begin//加法器使能打一拍
    ad_reg<=ad;
    ac_reg<=ac;
    bc_reg<=bc;
    bd_reg<=bd;
    en_add1_reg<=en_add1;
end

 

wire en_add2;

fix_adder #(.WIDTH1(WIDTH_I), .WIDTH2(WIDTH_F), .WIDTH(WIDTHr)) fix_adder_u1  (.clk(clk),.rstn(rstn),.a(ac_reg),.b(~bd_reg+1'b1),.vld_in(en_add1_reg),.r(temp_r),.vld_out(vld_out5));
fix_adder #(.WIDTH1(WIDTH_I), .WIDTH2(WIDTH_F), .WIDTH(WIDTHr)) fix_adder_u2  (.clk(clk),.rstn(rstn),.a(ad_reg),.b(bc_reg),.vld_in(en_add1_reg),.r(temp_i),.vld_out(vld_out6));


assign en_add2=vld_out5&&vld_out6;

reg en_add2_reg=0;
reg[WIDTHr-1:0] temp_i_reg,temp_r_reg;

always @(posedge clk) begin//加法器使能打一拍
    en_add2_reg<=en_add2;
    temp_i_reg<=temp_i;
    temp_r_reg<=temp_r;
end

wire [WIDTHr-1:0] y1_r_w,y2_r_w,y1_i_w,y2_i_w;

fix_adder #(.WIDTH1(WIDTH_I), .WIDTH2(WIDTH_F), .WIDTH(WIDTHr)) fix_adder_u3 (.clk(clk),.rstn(rstn),.a(x1_r),.b(temp_r_reg),.vld_in(en_add2_reg), .r(y1_r_w),.vld_out(vld_out7));
fix_adder #(.WIDTH1(WIDTH_I), .WIDTH2(WIDTH_F), .WIDTH(WIDTHr)) fix_adder_u4 (.clk(clk),.rstn(rstn),.a(x1_i),.b(temp_i_reg),.vld_in(en_add2_reg), .r(y1_i_w),.vld_out(vld_out8));
fix_adder #(.WIDTH1(WIDTH_I), .WIDTH2(WIDTH_F), .WIDTH(WIDTHr)) fix_adder_u5 (.clk(clk),.rstn(rstn),.a(x1_r),.b(~temp_r_reg+1'b1),.vld_in(en_add2_reg), .r(y2_r_w),.vld_out(vld_out9));
fix_adder #(.WIDTH1(WIDTH_I), .WIDTH2(WIDTH_F), .WIDTH(WIDTHr)) fix_adder_u6 (.clk(clk),.rstn(rstn),.a(x1_i),.b(~temp_i_reg+1'b1),.vld_in(en_add2_reg), .r(y2_i_w),.vld_out(vld_out10));

assign vld_out_all=vld_out7&vld_out8&&vld_out9&vld_out10;


always @(posedge clk) begin
    y1_r<=y1_r_w;y1_i<=y1_i_w;
    y2_r<=y2_r_w;y2_i<=y2_i_w;
    vld_out<=vld_out_all;
end

`ifdef Debug_butterfly
initial
begin @(posedge vld_out1)begin
        $display("ac:%b\n",ac);
        $display("bd:%b\n",bd);
        $display("ad:%b\n",ad);
        $display("bc:%b\n",bc); 
    end
   @(posedge vld_out5)
     $display("temp_r:%b\n",temp_r);
     $display("temp_i:%b\n",temp_i);
end
    
`endif

`ifdef Debug 
parameter N=256;
integer file_ac,file_bd,file_ad,file_bc,file_temp_i,file_temp_r;
    initial begin
        file_ac=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\ac_fix_bin.txt", "w");
        file_bd=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\bd_fix_bin.txt", "w");
        file_ad=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\ad_fix_bin.txt", "w");
        file_bc=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\bc_fix_bin.txt", "w");
        file_temp_i=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\temp_i_fix_bin.txt", "w");
        file_temp_r=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\temp_r_fix_bin.txt", "w");        
        repeat(N)
            begin
                @(posedge vld_out1) 
                    begin
                        $fdisplay(file_ac,"%b",ac);
                        $fdisplay(file_bd,"%b",bd);
                        $fdisplay(file_ad,"%b",ad);
                        $fdisplay(file_bc,"%b",bc);
                    end
                @(posedge en_add2) 
                    begin
                        $fdisplay(file_temp_i,"%b",temp_i);
                        $fdisplay(file_temp_r,"%b",temp_r);
                    end   
            end   
        #1
        $fclose(file_ac);
        $fclose(file_ad);
        $fclose(file_bc);
        $fclose(file_bd);
        $fclose(file_temp_i);
        $fclose(file_temp_r);   
    end

`endif
endmodule