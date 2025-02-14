`include "fix_mult.v"
module fix_mult_tb();
    reg clk, rstn, vld_in;
    reg signed  [WIDTHa-1:0] a; 
    reg signed  [WIDTHb-1:0] b;
    wire signed [WIDTHr-1:0] r;
    wire vld_out;

    parameter WIDTHa = 16; //q9.7
    parameter WIDTHb = 16;//cos sin值q 2.14
    parameter WIDTHr = 16;//q11.5

    // 实例化 fix_mult 模块，使用正确的参数名
    fix_mult #(.WIDTHa(WIDTHa), .WIDTHb(WIDTHb), .WIDTHr(WIDTHr)) fix_mult_u1N (
        .clk(clk),
        .rstn(rstn),
        .vld_in(vld_in),
        .vld_out(vld_out),
        .a(a),
        .b(b),
        .r(r)
    );

    parameter T = 10;

    // 时钟生成
    always #(T/2) clk = ~clk;
    reg [WIDTHa-1:0] a_mem[0:511];
    reg [WIDTHb-1:0] b_mem[0:511];
    reg [WIDTHr-1:0] r_mem[0:511];

    integer i=0;
    integer file_r;
    initial begin
        clk = 1; rstn = 0; vld_in = 0;a=0;b=0;i=0;
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid\\a_fix_bin.txt", a_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid\\b_fix_bin.txt", b_mem);
        file_r=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid\\r_fix_bin.txt", "w");
        #(T + 1) rstn = 1; 
        #(T - 1) ;
        repeat(512)
            begin
                a=a_mem[i];
                b=b_mem[i];
                vld_in=1;
                #(T);
                vld_in=0;
                if(vld_out)
                    $fdisplay(file_r,"%b",r);
                #(T);
                i=i+1;
            end
        $fclose(file_r);
        $finish;
    end
initial begin
   $dumpfile("fix_mult_tb.vcd"); //生成的vcd文件名称
   $dumpvars(0, fix_mult_tb); //tb模块名称
end
endmodule
