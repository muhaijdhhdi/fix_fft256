
module fix_adder #(
    parameter WIDTH1 = 9,//整数位
    parameter WIDTH2 = 7,//小数位
    parameter WIDTH = 16
)(
    input clk,
    input rstn,
    input vld_in,           //vld_in和a,b同时进来，持续一个周期后为0     
    input [WIDTH-1:0] a,    // 二进制定点补码
    input [WIDTH-1:0] b,    // 二进制定点补码 WIDTH1.WIDTH2
    output [WIDTH-1:0] r,   //r 与vld_out 同时有效这样有利于vld_out作为下一级的vld_in
    output vld_out,
    output overflow       // 溢出处理，直接舍弃将最高位仍然看出符号位，使得溢出的正数变成了负数
);

reg [WIDTH:0] a_reg, b_reg; 
reg [WIDTH:0]r_reg;
reg finish_add,vld_out_reg; 
reg a_sign,b_sign;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        a_reg <= 0;
        b_reg <= 0;
        a_sign<=0;
        b_sign<=0;
    end else if (vld_in) begin
        a_reg <= {a[WIDTH-1],a};
        b_reg <= {b[WIDTH-1],b};
        a_sign<=a[WIDTH-1];
        b_sign<=b[WIDTH-1];
    end
end

reg vld_in_diff;

always @(posedge clk) begin
    vld_in_diff <= vld_in;
end

reg [WIDTH:0] c;

integer i;
always @(*) begin
    if (!rstn) begin
        c = 0;
        r_reg = 0;
        finish_add = 0;
    end else if (vld_in_diff) begin
        for (i = 0; i < WIDTH+1; i = i + 1) begin
            if(i==0) 
            begin
                r_reg[i]=a_reg[i]^b_reg[i];
                c[i]=a_reg[i]&b_reg[i];
            end
              
            else
                begin 
                    r_reg[i] = a_reg[i] ^ b_reg[i] ^ c[i-1];
                    c[i]=(a_reg[i]&b_reg[i])|((a_reg[i]^b_reg[i])&c[i-1]);
                end
        end
        finish_add = 1;
    end 
    else begin
        c = 0;
        r_reg = 0;
        finish_add = 0;
    end
end

reg overflow_reg=0;
reg [WIDTH:0] result_reg;
 always @(*) begin
    if(!rstn)   
        begin
           result_reg=0; 
           overflow_reg=0;                                                                                                                                                     
        end
    else if(finish_add==1)
        begin
            vld_out_reg=1;
            if(!(a_sign^b_sign)&&r_reg[WIDTH]^r_reg[WIDTH-1])//只有同号时才会出现溢出，一正一负相加结果不会溢出
                overflow_reg=1;//溢出时就会舍弃高位,例如2^31-1加1后本来得到2^31,10000....00,31个0，但是溢出，抢占了符号位，但是系统仍将其看作符号位
                //所以最后系统认成是2^-32c次幂
            else 
                overflow_reg=0;
            result_reg=r_reg;    
        end
    else begin 
        overflow_reg=0;
        result_reg=0;
        vld_out_reg=0;
    end    
 end
// 输出寄存器赋值

assign overflow=overflow_reg;
assign vld_out=vld_out_reg;
assign r=result_reg[WIDTH-1:0];
endmodule
