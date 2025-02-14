`include "fix_butterfly.v"
module fix_butterfly_tb();

    parameter WIDTHa=20;
    parameter WIDTHb=20;
    parameter WIDTHr=20;
    parameter WIDTH_I=11;
    parameter WIDTH_F=WIDTHr-WIDTH_I;

    reg clk,rstn,vld_in;
    reg [WIDTHa-1:0] x1_i,x1_r,x2_r,x2_i;
    reg [WIDTHb-1:0] sinValue,cosValue ;
    wire [WIDTHr-1:0] y1_i,y1_r,y2_r,y2_i;
    wire vld_out,overflow;

    parameter T = 10;


    // 时钟生成
    always #(T/2) clk = ~clk;

    parameter N=20;
    reg [WIDTHa-1:0]x1_r_mem[0:N-1];
    reg [WIDTHa-1:0]x1_i_mem[0:N-1];
    reg [WIDTHa-1:0]x2_r_mem[0:N-1];
    reg [WIDTHa-1:0]x2_i_mem[0:N-1];
    
    reg [WIDTHb-1:0]sin_mem[0:N-1];
    reg[WIDTHb-1:0] cos_mem[0:N-1];

    integer i;
    integer file_y1_r,file_y2_r,file_y1_i,file_y2_i;
    initial begin
        clk=1;rstn=0;vld_in=0;x1_r=0;x1_i=0;x2_r=0;x2_i=0;i=0;
        sinValue=0;cosValue=0;
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x1_r_fix_bin.txt", x1_r_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x1_i_fix_bin.txt", x1_i_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x2_r_fix_bin.txt",x2_r_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x2_i_fix_bin.txt", x2_i_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\sinx_fix_bin.txt", sin_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\cosx_fix_bin.txt",cos_mem);
        
        file_y1_r=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y1_r_fix_bin.txt", "w");
        file_y2_r=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y2_r_fix_bin.txt", "w");
        file_y1_i=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y1_i_fix_bin.txt", "w");
        file_y2_i=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y2_i_fix_bin.txt", "w");

        #(T+1) rstn=1;
        #(T-1) ;

        repeat(N)
            begin
                x1_r=x1_r_mem[i];
                x1_i=x1_i_mem[i];
                x2_r=x2_r_mem[i];
                x2_i=x2_i_mem[i];
                sinValue=sin_mem[i];
                cosValue=cos_mem[i];
                vld_in=1;
                #(T);
                vld_in=0;
                @( posedge vld_out)
                   begin
                        $fdisplay(file_y1_r,"%b",y1_r);
                        $fdisplay(file_y1_i,"%b",y1_i);
                        $fdisplay(file_y2_r,"%b",y2_r);
                        $fdisplay(file_y2_i,"%b",y2_i);
                   end 
                #(T);
                i=i+1;
            end
        $fclose(file_y1_r);
        $fclose(file_y2_r);
        $fclose(file_y1_i);
        $fclose(file_y2_i);
        #(T)
        #1
        $finish;
    end


fix_butterfly #(
        .WIDTHa(WIDTHa),
        .WIDTHb(WIDTHb),
        .WIDTHr(WIDTHr),
        .WIDTH_I(WIDTH_I),
        .WIDTH_F(WIDTH_F)
    ) u_fix_butterfly (
        .clk(clk),
        .rstn(rstn),
        .x1_r(x1_r),
        .x1_i(x1_i),
        .x2_r(x2_r),
        .x2_i(x2_i),
        .sinValue(sinValue),
        .cosValue(cosValue),
        .y1_r(y1_r),
        .y1_i(y1_i),
        .y2_r(y2_r),
        .y2_i(y2_i),
        .en(vld_in),
        .vld_out(vld_out),
        .overflow(overflow)
    );

initial begin
   $dumpfile("fix_butterfly_tb.vcd"); //生成的vcd文件名称
   $dumpvars(0, fix_butterfly_tb); //tb模块名称
end
endmodule