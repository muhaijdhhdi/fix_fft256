`include "fix_fft.v"
`timescale 1ns/1ns
module fix_fft_tb();

parameter N=256;
parameter T=10;

parameter WIDTHa=16;
parameter WIDTHb=16;
parameter WIDTHr=WIDTHa;
parameter WIDTH_F=9;
parameter WIDTH_I=WIDTHa-WIDTH_F;
reg clk,rstn,vld_in;
reg [WIDTHa-1:0] x_r,x_i;
wire [WIDTHa-1:0] y_r,y_i;
wire vld_out;



always #(T/2) clk=~clk;



reg [WIDTHa-1:0]x_r_data[0:N-1];
reg [WIDTHa-1:0]x_i_data[0:N-1];
reg [WIDTHa-1:0]y_r_data[0:N-1];
reg[WIDTHa-1:0]y_i_data[0:N-1];
integer i,j,k;
reg finish_write=0;

initial begin
   clk=0;rstn=0;vld_in=0;x_r=0;x_i=0;i=0;j=0;k=0;
   // 从x_r.txt文件中读取数据到x_r_data数组
    #1;
    $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\x_r_fix_bin.txt", x_r_data);
    // 从x_i.txt文件中读取数据到x_i_data数组
    $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\x_i_fix_bin.txt", x_i_data);
   #(T+1);
    rstn=1;
    #(T);
    vld_in=1;
    repeat(N) begin
        #(T);
            x_r=x_r_data[i];
            x_i=x_i_data[i];
            i=i+1;
            if(i==1)
            vld_in=0;
    end         
    end
initial begin
    #(800*T);
    #(T);
    $finish;
end
    
initial begin
    @(posedge vld_out)
        repeat(N)
            begin
                #(T);
                y_r_data[j]=y_r;
                y_i_data[j]=y_i;
                j=j+1;      
            end 
finish_write=1;
end

    integer file_r,file_i;

initial begin
    file_r = $fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\y_r_fix_bin.txt", "w");
    file_i = $fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\y_i_fix_bin.txt", "w");

    if (!file_r||!file_i) begin
        $display("can't open file,exit");
        $finish;
    end
    @(posedge finish_write)
        for (k = 0; k< N; k = k + 1) begin
             $fwrite(file_r, "%b\n", y_r_data[k]);
             $fwrite(file_i, "%b\n", y_i_data[k]);
        end
    $fclose(file_r);
    $fclose(file_i);
    $display("ok finish");
    $finish;
end

fix_fft #(.WIDTHa(WIDTHa),.WIDTHb(WIDTHb),.WIDTHr(WIDTHr),.WIDTH_F(WIDTH_F),.WIDTH_I(WIDTH_I)) 
fft_u_1 (.clk(clk),.rstn(rstn),.x_r(x_r),.x_i(x_i),.y_r(y_r),.y_i(y_i),.vld_in(vld_in),.vld_out(vld_out));

initial begin
   $dumpfile("fix_fft_tb.vcd"); //生成的vcd文件名称
   $dumpvars(0, fix_fft_tb); //tb模块名称
end  
endmodule