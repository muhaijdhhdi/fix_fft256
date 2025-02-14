`include "fix_adder.v"
module fix_adder_tb();
    reg clk, rstn, vld_in;
    reg signed  [WIDTH-1:0] a, b;
    wire signed [WIDTH-1:0] r;
    wire vld_out,overflow;

    parameter WIDTH1 =10;
    parameter WIDTH2 =6;
    parameter WIDTH = 16;

    // 实例化 fix_adder 模块，使用正确的参数名
    fix_adder #(.WIDTH(WIDTH), .WIDTH1(WIDTH1), .WIDTH2(WIDTH2)) fix_adder_u1N (
        .clk(clk),
        .rstn(rstn),
        .vld_in(vld_in),
        .vld_out(vld_out),
        .a(a),
        .b(b),
        .r(r),
        .overflow(overflow)
    );

    parameter T = 10;

    // 时钟生成
    always #(T/2) clk = ~clk;

    reg [WIDTH-1:0] a_mem[0:511];
    reg [WIDTH-1:0] b_mem[0:511];
    reg [WIDTH-1:0] r_mem[0:511];

    integer i=0;
    integer file_adder,file_sub;

    initial begin
        clk = 0; rstn = 0; vld_in = 0;a=0;b=0;
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\a_fix_bin.txt", a_mem);
        $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\b_fix_bin.txt", b_mem);
        file_adder=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\adder_fix_bin.txt", "w");
        file_sub=$fopen("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\sub_fix_bin.txt", "w");

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
                    $fdisplay(file_adder,"%b",r);
                #(T);
                vld_in=1;
                b=~b_mem[i]+1'b1;
                #(T);
                vld_in=0;
                if(vld_out)
                    $fdisplay(file_sub,"%b",r);
                #(T);    
                i=i+1;
            end
        $fclose(file_adder);
        $fclose(file_sub);

        $finish;
    end
initial begin
   $dumpfile("fix_adder_tb.vcd"); //生成的vcd文件名称
   $dumpvars(0, fix_adder_tb); //tb模块名称
end
endmodule
