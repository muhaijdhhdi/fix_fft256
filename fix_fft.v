`include "fix_butterfly.v"
`define ReadFFile
`define Debug

module fix_fft#(
    parameter WIDTHa = 32,//X
    parameter WIDTHb = 32,//SIN,COS
    parameter WIDTHr = WIDTHa,
    parameter WIDTH_I=9,
    parameter WIDTH_F=WIDTHa-WIDTH_I
)
(
    input clk,
    input rstn,
    input vld_in,
    input dir,//1 fft 0 ifft
    input [WIDTHa-1:0] x_r,x_i,
    output [WIDTHa-1:0] y_r,y_i,
    output vld_out  
);
parameter l=8;
parameter N=256;

reg [l-1:0] cnt_temp,cnt_output;



parameter IDLE=15;
parameter STAGE0=0;
parameter STAGE1=1;
parameter STAGE2=2;
parameter STAGE3=3;
parameter STAGE4=4;
parameter STAGE5=5;
parameter STAGE6=6;
parameter STAGE7=7;
parameter FinalSTAGE=8;
parameter INPUT=9;
parameter OUTPUT=10;

parameter      fileID_Stage0_r ="C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage0_r.txt",
              fileID_Stage0_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage0_i.txt",
              fileID_Stage1_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage1_r.txt",
              fileID_Stage1_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage1_i.txt",
              fileID_Stage2_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage2_r.txt",
              fileID_Stage2_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage2_i.txt",
              fileID_Stage3_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage3_r.txt",
              fileID_Stage3_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage3_i.txt",
              fileID_Stage4_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage4_r.txt",
              fileID_Stage4_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage4_i.txt",
              fileID_Stage5_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage5_r.txt",
              fileID_Stage5_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage5_i.txt",
              fileID_Stage6_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage6_r.txt",
              fileID_Stage6_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage6_i.txt",
              fileID_Stage7_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage7_r.txt",
              fileID_Stage7_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage7_i.txt",
              fileID_Stage8_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage8_r.txt",
              fileID_Stage8_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage8_i.txt",
              fileID_Output_r = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\Output_r.txt",
              fileID_Output_i = "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\Output_i.txt";
reg [3:0] state=IDLE;
reg vld_in_diff;

always @(posedge clk) begin
    vld_in_diff<=vld_in;
end


always @(posedge clk or negedge rstn) begin//cnt_temp为输入缓存计数
    if(!rstn)
        cnt_temp<=0;
    else if(vld_in_diff&&cnt_temp==0)
        cnt_temp<=cnt_temp+1;
    else if(cnt_temp==N-1)
        cnt_temp<=0;
    else if(cnt_temp>0)
        cnt_temp<=cnt_temp+1;     
end

always@(posedge clk or negedge rstn)//cnt_output为输出缓存计数
    begin
        if(!rstn)
            cnt_output<=0;
        else if(state==OUTPUT&&cnt_output==0)
                cnt_output<=cnt_output+1;
        else if(cnt_output==N-1)
                cnt_output<=0;
         else if(cnt_output>0)
                cnt_output<=cnt_output+1;
   end 

reg [WIDTHa-1:0] x_r_store_e[0:N-1];//存储偶数次序级数的fft蝶形运算中间值
reg[WIDTHa-1:0]x_i_store_e[0:N-1];
reg [WIDTHa-1:0]x_r_store_o[0:N-1];
reg[WIDTHa-1:0]x_i_store_o[0:N-1];//存储奇数次序的fft蝶形运算中间值


reg [WIDTHb-1:0]cosValue[0:(N>>1)-1];//存取sin,cos值
reg[WIDTHb-1:0]sinValue[0:(N>>1)-1];//存取sin,cos值

`ifdef ReadFFile
    initial begin
      $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\sinx_fix_bin.txt", sinValue);
      $readmemb("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\cosx_fix_bin.txt", cosValue);
    end
`endif


reg [WIDTHa-1:0]x1_r_in[0:(N>>1)-1];reg [WIDTHa-1:0]x1_i_in[0:(N>>1)-1];
reg [WIDTHa-1:0]x2_r_in[0:(N>>1)-1];reg [WIDTHa-1:0]x2_i_in[0:(N>>1)-1];
reg [WIDTHb-1:0]factory_sin[0:(N>>1)-1];reg[WIDTHb-1:0]factory_cos[0:(N>>1)-1];

wire [WIDTHa-1:0]x1_r_out[0:(N>>1)-1];wire [WIDTHa-1:0]x1_i_out[0:(N>>1)-1];
wire [WIDTHa-1:0]x2_r_out[0:(N>>1)-1];wire [WIDTHa-1:0]x2_i_out[0:(N>>1)-1];

reg en_butterfly,vld_out_butterfly_reg;
wire vld_out_butterfly;

integer i,j;

always @(posedge clk) begin
    case(state)
        IDLE:
            for (i=0;i<N;i=i+1)
                begin
                    x_r_store_o[i]<=0;x_r_store_e[i]<=0;
                    x_i_store_o[i]<=0;x_i_store_e[i]<=0;
                    state<=INPUT;
                    if(i<(N>>1))
                    begin
                        x1_r_in[i]<=0;x1_i_in[i]<=0;
                        x2_r_in[i]<=0;x2_i_in[i]<=0;
                        factory_sin[i]<=0;factory_cos[i]<=0;
                    end
                end
        INPUT:
                begin
                    if((vld_in_diff&&cnt_temp==0)||cnt_temp>0)
                    begin
                        x_r_store_o[cnt_temp]<=x_r;
                        x_i_store_o[cnt_temp]<=x_i;
                    end
                if(cnt_temp==N-1)
                    begin
                        state<=STAGE0;
                    end
                end
        STAGE0:
            begin//完成输入的反转逆序调整
                for (i = 0; i < N; i = i + 1) begin
                    x_r_store_e[i] = x_r_store_o[{i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7]}]; 
                     x_i_store_e[i] = x_i_store_o[{i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7]}]; 
                    end
                state<=STAGE1;
            end
        STAGE1:
            begin
                for(i=0;i<(N>>1);i=i+1)
                    begin
                        x1_i_in[i]<=x_i_store_e[i*2];
                        x2_i_in[i]<=x_i_store_e[2*i+1];
                        x1_r_in[i]<=x_r_store_e[i*2];
                        x2_r_in[i]<=x_r_store_e[2*i+1];
                        factory_cos[i]<=cosValue[0];
                        factory_sin[i]<=sinValue[0];
                    end 
                if(vld_out_butterfly==1'b1)
                    begin
                      state<=STAGE2;
                      for(i=0;i<(N>>1);i=i+1)
                        begin
                            x_r_store_o[i*2]<=x1_r_out[i];
                            x_i_store_o[2*i]<=x1_i_out[i];
                            x_r_store_o[i*2+1]<=x2_r_out[i];
                            x_i_store_o[2*i+1]<=x2_i_out[i];
                        end
                    end
            end
        STAGE2:
            begin
                for (i=0;i<(N>>2);i=i+1)//64
                    for(j=0;j<(1<<1);j=j+1)
                       begin
                            x1_i_in[2*i+j]<=x_i_store_o[4*i+j];
                            x1_r_in[2*i+j]<=x_r_store_o[4*i+j];
                            x2_i_in[2*i+j]<=x_i_store_o[4*i+j+2];
                            x2_r_in[2*i+j]<=x_r_store_o[4*i+j+2];
                            factory_cos[2*i+j]<=cosValue[(N>>2)*j];
                            factory_sin[2*i+j]<=sinValue[(N>>2)*j];
                        end
                if(vld_out_butterfly==1'b1)
                    begin
                      state<=STAGE3;
                      for (i=0;i<(N>>2);i=i+1)//64
                        for(j=0;j<(1<<1);j=j+1)
                            begin
                                x_r_store_e[i*4+j]<=x1_r_out[2*i+j];
                                x_i_store_e[i*4+j]<=x1_i_out[2*i+j];
                                x_r_store_e[i*4+j+2]<=x2_r_out[2*i+j];
                                x_i_store_e[i*4+j+2]<=x2_i_out[2*i+j];
                            end
                    end  
            end
        STAGE3:
            begin
                for(i=0;i<(N>>3);i=i+1)//32
                    for(j=0;j<(1<<2);j=j+1)
                        begin
                            x1_i_in[4*i+j]<=x_i_store_e[8*i+j];
                            x1_r_in[4*i+j]<=x_r_store_e[8*i+j];
                            x2_i_in[4*i+j]<=x_i_store_e[8*i+j+4];
                            x2_r_in[4*i+j]<=x_r_store_e[8*i+j+4];
                            factory_cos[4*i+j]<=cosValue[(N>>3)*j];
                            factory_sin[4*i+j]<=sinValue[(N>>3)*j];  
                        end
                if(vld_out_butterfly==1'b1)
                    begin
                        state<=STAGE4;
                        for(i=0;i<(N>>3);i=i+1)
                            for(j=0;j<(1<<2);j=j+1)
                                begin
                                    x_r_store_o[i*8+j]<=x1_r_out[4*i+j];
                                    x_i_store_o[i*8+j]<=x1_i_out[4*i+j];
                                    x_r_store_o[i*8+j+4]<=x2_r_out[4*i+j];
                                    x_i_store_o[i*8+j+4]<=x2_i_out[4*i+j];
                                end
                    end
            end
        STAGE4:
            begin
                for( i=0;i<(N>>4);i=i+1)
                    for(j=0;j<(1<<3);j=j+1)
                        begin
                            x1_i_in[8*i+j]<=x_i_store_o[16*i+j];
                            x1_r_in[8*i+j]<=x_r_store_o[16*i+j];
                            x2_i_in[8*i+j]<=x_i_store_o[16*i+j+8];
                            x2_r_in[8*i+j]<=x_r_store_o[16*i+j+8];
                            factory_cos[8*i+j]<=cosValue[(N>>4)*j];
                            factory_sin[8*i+j]<=sinValue[(N>>4)*j];
                        end
                if(vld_out_butterfly==1'b1)
                        begin
                            state<=STAGE5;
                            for(i=0;i<(N>>4);i=i+1)
                                for(j=0;j<(1<<3);j=j+1)
                                    begin
                                        x_r_store_e[i*16+j]<=x1_r_out[8*i+j];
                                        x_i_store_e[i*16+j]<=x1_i_out[8*i+j];
                                        x_r_store_e[i*16+j+8]<=x2_r_out[8*i+j];
                                        x_i_store_e[i*16+j+8]<=x2_i_out[8*i+j];
                                    end
                        end  
            end
        STAGE5:
            begin
                begin
                    for( i=0;i<(N>>5);i=i+1)
                        for(j=0;j<(1<<4);j=j+1)
                        begin
                            x1_i_in[16*i+j]=x_i_store_e[32*i+j];
                            x1_r_in[16*i+j]=x_r_store_e[32*i+j];
                            x2_i_in[16*i+j]=x_i_store_e[32*i+j+16];
                            x2_r_in[16*i+j]=x_r_store_e[32*i+j+16];
                        factory_cos[16*i+j]<=cosValue[8*j];
                        factory_sin[16*i+j]<=sinValue[8*j];
                        end 
                    if(vld_out_butterfly==1'b1)
                        begin
                            state<=STAGE6;
                            for(i=0;i<(N>>5);i=i+1)
                                for(j=0;j<(1<<4);j=j+1)
                                    begin
                                        x_r_store_o[i*32+j]<=x1_r_out[16*i+j];
                                        x_i_store_o[i*32+j]<=x1_i_out[16*i+j];
                                        x_r_store_o[i*32+j+16]<=x2_r_out[16*i+j];
                                        x_i_store_o[i*32+j+16]<=x2_i_out[16*i+j];
                                         `ifdef Debug_stage5
                                        $fdisplay(sincos_file,"stage5,sin[%d]=%b\tcos[%d]=%b\n",16*i+j,factory_sin[16*i+j],i*16+j,factory_cos[16*i+j]);
                                `endif
                                    end
                        end
                end
            end           
        STAGE6:
            begin
                    for( i=0;i<(N>>6);i=i+1)
                        for(j=0;j<(1<<5);j=j+1)
                        begin
                            x1_i_in[32*i+j]<=x_i_store_o[64*i+j];
                            x1_r_in[32*i+j]<=x_r_store_o[64*i+j];
                            x2_i_in[32*i+j]<=x_i_store_o[64*i+j+32];
                            x2_r_in[32*i+j]<=x_r_store_o[64*i+j+32];
                        factory_cos[32*i+j]<=cosValue[4*j];
                        factory_sin[32*i+j]<=sinValue[4*j];
                        end 
                    if(vld_out_butterfly==1'b1)
                        begin
                            state<=STAGE7;
                            for(i=0;i<(N>>6);i=i+1)
                                for(j=0;j<(1<<5);j=j+1)
                                    begin
                                        x_r_store_e[i*64+j]<=x1_r_out[32*i+j];
                                        x_i_store_e[i*64+j]<=x1_i_out[32*i+j];
                                        x_r_store_e[i*64+j+32]<=x2_r_out[32*i+j];
                                        x_i_store_e[i*64+j+32]<=x2_i_out[32*i+j];
                                            `ifdef Debug_stage6
                                        $fdisplay(sincos_file,"stage6,sin[%d]=%b\tcos[%d]=%b\n",32*i+j,factory_sin[32*i+j],i*32+j,factory_cos[32*i+j]);
                                `endif
                                    end
                        end
            end
        STAGE7:
            begin
                for( i=0;i<(N>>7);i=i+1)
                    for(j=0;j<(1<<6);j=j+1)
                    begin
                        x1_i_in[64*i+j]<=x_i_store_e[128*i+j];
                        x1_r_in[64*i+j]<=x_r_store_e[128*i+j];
                        x2_i_in[64*i+j]<=x_i_store_e[128*i+j+64];
                        x2_r_in[64*i+j]<=x_r_store_e[128*i+j+64];
                        factory_cos[64*i+j]<=cosValue[2*j];
                        factory_sin[64*i+j]<=sinValue[2*j];
                    end 
                if(vld_out_butterfly==1'b1)
                    begin
                        state<=FinalSTAGE;
                        for( i=0;i<(N>>7);i=i+1)
                            for(j=0;j<(1<<6);j=j+1)                   
                                begin
                                    x_r_store_o[i*128+j]<=x1_r_out[64*i+j];
                                    x_i_store_o[i*128+j]<=x1_i_out[64*i+j];
                                    x_r_store_o[i*128+j+64]<=x2_r_out[64*i+j];
                                    x_i_store_o[i*128+j+64]<=x2_i_out[64*i+j];
                                    `ifdef Debug_stage7
                                        $fdisplay(sincos_file,"stage7,sin[%d]=%b\tcos[%d]=%b\n",64*i+j,factory_sin[64*i+j],i*64+j,factory_cos[64*i+j]);
                                    `endif
                                end
                    end
            end
        FinalSTAGE:
                begin
                    for(j=0;j<(1<<7);j=j+1)
                        begin
                            x1_i_in[j]<=x_i_store_o[j];
                            x1_r_in[j]<=x_r_store_o[j];
                            x2_i_in[j]<=x_i_store_o[j+128];
                            x2_r_in[j]<=x_r_store_o[j+128];
                            factory_cos[j]<=cosValue[j];
                            factory_sin[j]<=sinValue[j];
                        end 
                    if(vld_out_butterfly==1'b1)
                        begin
                            state<=OUTPUT;
                            for(j=0;j<128;j=j+1)
                                begin
                                    x_r_store_e[j]<=x1_r_out[j];
                                    x_i_store_e[j]<=x1_i_out[j];
                                    x_r_store_e[j+128]<=x2_r_out[j];
                                    x_i_store_e[j+128]<=x2_i_out[j];
                                    `ifdef Debug_stage8
                                        $fdisplay(sincos_file,"stage8,sin[%d]=%b\tcos[%d]=%b\n",j,factory_sin[j],j,factory_cos[j]);
                                    `endif
                                end
                    end
                end
        OUTPUT:
            begin
                    if(cnt_output==N-1)
                        state<=IDLE;    
                end
    endcase
end

reg[1:0] cnt_stage=0;//主要用来控制en脉冲
always@(posedge clk or negedge rstn)
        if(!rstn)
            begin
                en_butterfly<=0;cnt_stage<=0;
            end
        else
             if(state==IDLE||state==INPUT||state==OUTPUT||state==STAGE0) begin en_butterfly<=0;cnt_stage<=0;end
             else begin
                if(en_butterfly==0&&cnt_stage==0)
                            begin 
                               en_butterfly<=1;
                               cnt_stage<=1;
                             end
                     else if(cnt_stage==1)
                            begin 
                                en_butterfly<=0;
                                cnt_stage<=2;
                            end
                     else if(cnt_stage==2&&vld_out_butterfly==1'b1) begin 
                                cnt_stage<=0; 
              end
             end
   
generate
    for (genvar i = 0;i<(N>>1) ;i=i+1 ) begin
        if(i==0)
            fix_butterfly #(.WIDTHa(WIDTHa),.WIDTHb(WIDTHb),.WIDTHr(WIDTHr),.WIDTH_I(WIDTH_I),.WIDTH_F(WIDTH_F)) butterfly_instance(.clk(clk),.rstn(rstn),.en(en_butterfly),.sinValue(factory_sin[i]),.cosValue(factory_cos[i]),.x1_r(x1_r_in[i]),.x1_i(x1_i_in[i]),.x2_r(x2_r_in[i]),.x2_i(x2_i_in[i]),.y1_r(x1_r_out[i]),.y1_i(x1_i_out[i]),.y2_r(x2_r_out[i]),.y2_i(x2_i_out[i]),.vld_out(vld_out_butterfly));
        else
            fix_butterfly #(.WIDTHa(WIDTHa),.WIDTHb(WIDTHb),.WIDTHr(WIDTHr),.WIDTH_I(WIDTH_I),.WIDTH_F(WIDTH_F)) butterfly_instance(.clk(clk),.rstn(rstn),.en(en_butterfly),.sinValue(factory_sin[i]),.cosValue(factory_cos[i]),.x1_r(x1_r_in[i]),.x1_i(x1_i_in[i]),.x2_r(x2_r_in[i]),.x2_i(x2_i_in[i]),.y1_r(x1_r_out[i]),.y1_i(x1_i_out[i]),.y2_r(x2_r_out[i]),.y2_i(x2_i_out[i]),.vld_out());
    end
endgenerate

//输出给y
reg[WIDTHr:0] y_r_reg,y_i_reg;
reg vld_out_reg;

always@(posedge clk or negedge rstn)
    if(!rstn)
        begin
            y_r_reg<=0;
            y_i_reg<=0;
            vld_out_reg<=0;
        end
     else if(state==OUTPUT)
        begin
            if(dir==1)
                begin 
                    y_r_reg<=x_r_store_e[cnt_output];
                    y_i_reg<=x_i_store_e[cnt_output];
                end 
            else
                begin
                    y_r_reg<=x_r_store_e[cnt_output]>>>8;
                    y_i_reg<=x_i_store_e[cnt_output]>>>8;
                end
            vld_out_reg<=1;
         end
      else begin
                vld_out_reg<=0;
            end

assign y_r=y_r_reg;
assign y_i=y_i_reg;
assign vld_out=vld_out_reg;

`ifdef Debug
integer file_i,file_r;

 always@(*)
  begin
        if (state==STAGE0) begin
            file_r = $fopen(fileID_Stage0_r, "w");
            file_i = $fopen(fileID_Stage0_i, "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_o[i]);
                $fwrite(file_i, "%b\n", x_i_store_o[i]);
            end
            $fclose(file_r);
            $fclose(file_i);
        end
        if (state==STAGE1) begin
            file_r = $fopen(fileID_Stage1_r, "w");
            file_i = $fopen(fileID_Stage1_i, "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_e[i]);
                $fwrite(file_i, "%b\n", x_i_store_e[i]);
            end
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==STAGE2) begin
            file_r = $fopen(fileID_Stage2_r, "w");
            file_i = $fopen(fileID_Stage2_i, "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_o[i]);
                $fwrite(file_i, "%b\n", x_i_store_o[i]);
            end
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==STAGE3) begin
            file_r = $fopen(fileID_Stage3_r, "w");
            file_i = $fopen(fileID_Stage3_i, "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_e[i]);
                $fwrite(file_i, "%b\n", x_i_store_e[i]);
            end
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==STAGE4) begin
            file_r = $fopen(fileID_Stage4_r, "w");
            file_i = $fopen(fileID_Stage4_i, "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_o[i]);
                $fwrite(file_i, "%b\n", x_i_store_o[i]);
            end
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==STAGE5) begin
            file_r = $fopen(fileID_Stage5_r, "w");
            file_i = $fopen(fileID_Stage5_i, "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_e[i]);
                $fwrite(file_i, "%b\n", x_i_store_e[i]);
            end        
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==STAGE6) begin
            file_r = $fopen(fileID_Stage6_r, "w");
            file_i = $fopen(fileID_Stage6_i, "w");
           
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_o[i]);
                $fwrite(file_i, "%b\n", x_i_store_o[i]);
            end
            
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==STAGE7) begin
       
            file_r = $fopen(fileID_Stage7_r, "w");
            file_i = $fopen(fileID_Stage7_i, "w");
       
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_e[i]);
                $fwrite(file_i, "%b\n", x_i_store_e[i]);
            end
         
            $fclose(file_r);
            $fclose(file_i);
        end
        else if (state==FinalSTAGE) begin
            file_r = $fopen(fileID_Stage8_r, "w");
            file_i = $fopen(fileID_Stage8_i, "w");
           
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_o[i]);
                $fwrite(file_i, "%b\n", x_i_store_o[i]);
            end
           
            $fclose(file_r);
            $fclose(file_i);
        end
        else if(state==OUTPUT) 
        begin
            file_r = $fopen(fileID_Output_r, "w");
            file_i = $fopen(fileID_Output_i, "w");
            
            for (i = 0; i < 256; i = i + 1) begin
                $fwrite(file_r, "%b\n", x_r_store_e[i]);
                $fwrite(file_i, "%b\n", x_i_store_e[i]);
            end
          
            $fclose(file_r);
            $fclose(file_i);
        end
    end
  `endif
endmodule