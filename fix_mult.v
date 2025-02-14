module fix_mult #(
    parameter WIDTHa = 16,
    parameter WIDTHb = 16,
    parameter WIDTHr = 16 
)(
    input clk,
    input rstn,
    input vld_in,           //vld_in和a,b同时进来，持续一个周期后为0     
    input [WIDTHa-1:0] a,    // 二进制定点补码 
    input [WIDTHb-1:0] b,    // 二进制定点补码 
    output [WIDTHr-1:0] r,   //r 与vld_out 同时有效这样有利于vld_out作为下一级的vld_in
    output vld_out
);

reg signed [WIDTHa-1:0] a_reg;reg signed [WIDTHb-1:0]b_reg;
reg signed [WIDTHr-1:0] result_reg;
reg [WIDTHa+WIDTHb-1:0] r_reg;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        a_reg <= 0;
        b_reg <= 0;
    end else if (vld_in) begin
        a_reg <=a;
        b_reg <=b;
    end
end

reg vld_in_diff;
reg finish_mult;

always @(posedge clk) begin
    vld_in_diff <= vld_in;
end


always @( *) begin
if(!rstn)
    begin
      r_reg=0;
      finish_mult=0;
    end
else if (vld_in_diff) begin 
    r_reg=a_reg*b_reg;
    finish_mult=1;
end
else begin
  r_reg=0;finish_mult=0;
end    
end

reg vld_out_reg;

always @(*) begin
    if(!rstn)   
        begin
           result_reg=0;  
           vld_out_reg=0;                                                                                                                                              
        end
    else if(finish_mult==1)
        begin
          result_reg=r_reg[WIDTHa+WIDTHb-3:WIDTHa+WIDTHb-WIDTHr-2];
          vld_out_reg=1;
        end
    else begin
        result_reg=0;
        vld_out_reg=0;
    end 

end

assign vld_out=vld_out_reg;
assign r=result_reg;
endmodule