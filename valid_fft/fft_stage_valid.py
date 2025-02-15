import struct
import math

def reversed_num():
    binary_to_decimal_0_255 = []

    for num in range(0, 256):
        binary_num = f"{num:08b}"[::-1]
        decimal_num = int(binary_num, 2)
        binary_to_decimal_0_255.append(decimal_num)

    return binary_to_decimal_0_255
def myfft_dit(x_r,x_i,dir):#256点的dit fft运算
   N=256
   index=reversed_num()
   x_r_level0=[None]*N;x_r_level1=[None]*N;x_r_level2=[None]*N;x_r_level3=[None]*N;x_r_level4=[None]*N;x_r_level5=[None]*N;x_r_level6=[None]*N;x_r_level7=[None]*N;x_r_level8=[None]*N
   x_i_level0=[None]*N;x_i_level1=[None]*N;x_i_level2=[None]*N;x_i_level3=[None]*N;x_i_level4=[None]*N;x_i_level5=[None]*N;x_i_level6=[None]*N;x_i_level7=[None]*N;x_i_level8=[None]*N
   for i in range (256):
        j=index[i]
        x_r_level0[i]=x_r[j]
        x_i_level0[i]=x_i[j]
   for level_num in range(1,9):
        if(level_num==1):
           for i in range(128):
                for j in range(2): 
                    if(j<1):
                        x_r_level1[2*i+j]=x_r_level0[2*i+j]+x_r_level0[2*i+j+1]
                        x_i_level1[2*i+j]=x_i_level0[2*i+j]+x_i_level0[2*i+j+1]
                        
                    else:
                        x_r_level1[2*i+j]=x_r_level0[2*i+j-1]-x_r_level0[2*i+j]
                        x_i_level1[2*i+j]=x_i_level0[2*i+j-1]-x_i_level0[2*i+j]
        if(level_num==2):
           for i in range(64):
               for j in range(4):
                   if(j<2):
                       x_r_level2[4*i+j]=x_r_level1[4*i+j]+math.cos(-2*math.pi*dir/N*j*64)*x_r_level1[4*i+j+2]-math.sin(-2*math.pi*dir/N*j*64)*x_i_level1[4*i+j+2]
                       x_i_level2[4*i+j]=x_i_level1[4*i+j]+(math.sin(-2*math.pi*dir/N*j*64)*x_r_level1[4*i+j+2]+math.cos(-2*math.pi*dir/N*j*64)*x_i_level1[4*i+j+2])
                   else:
                       x_r_level2[4*i+j]=x_r_level1[4*i+j-2]-(math.cos(-2*math.pi*dir/N*(j-2)*64)*x_r_level1[4*i+j]-math.sin(-2*math.pi*dir/N*(j-2)*64)*x_i_level1[4*i+j])
                       x_i_level2[4*i+j]=x_i_level1[4*i+j-2]-(math.sin(-2*math.pi*dir/N*(j-2)*64)*x_r_level1[4*i+j]+math.cos(-2*math.pi*dir/N*(j-2)*64)*x_i_level1[4*i+j])
        if(level_num==3):
           for i in range(32):
               for j in range(8):
                   if(j<4):
                       x_r_level3[8*i+j]=x_r_level2[8*i+j]+math.cos(-2*math.pi*dir/N*j*32)*x_r_level2[8*i+j+4]-math.sin(-2*math.pi*dir/N*j*32)*x_i_level2[8*i+j+4]
                       x_i_level3[8*i+j]=x_i_level2[8*i+j]+(math.sin(-2*math.pi*dir/N*j*32)*x_r_level2[8*i+j+4]+math.cos(-2*math.pi*dir/N*j*32)*x_i_level2[8*i+j+4])
                   else:
                       x_r_level3[8*i+j]=x_r_level2[8*i+j-4]-(math.cos(-2*math.pi*dir/N*(j-4)*32)*x_r_level2[8*i+j]-math.sin(-2*math.pi*dir/N*(j-4)*32)*x_i_level2[8*i+j])
                       x_i_level3[8*i+j]=x_i_level2[8*i+j-4]-(math.sin(-2*math.pi*dir/N*(j-4)*32)*x_r_level2[8*i+j]+math.cos(-2*math.pi*dir/N*(j-4)*32)*x_i_level2[8*i+j])

        if(level_num==4):
           for i in range(16):
               for j in range(16):
                   if(j<8):
                       x_r_level4[16*i+j]=x_r_level3[16*i+j]+math.cos(-2*math.pi*dir/N*j*16)*x_r_level3[16*i+j+8]-math.sin(-2*math.pi*dir/N*j*16)*x_i_level3[16*i+j+8]
                       x_i_level4[16*i+j]=x_i_level3[16*i+j]+(math.sin(-2*math.pi*dir/N*j*16)*x_r_level3[16*i+j+8]+math.cos(-2*math.pi*dir/N*j*16)*x_i_level3[16*i+j+8])
                   else:
                       x_r_level4[16*i+j]=x_r_level3[16*i+j-8]-(math.cos(-2*math.pi*dir/N*(j-8)*16)*x_r_level3[16*i+j]-math.sin(-2*math.pi*dir/N*(j-8)*16)*x_i_level3[16*i+j])
                       x_i_level4[16*i+j]=x_i_level3[16*i+j-8]-(math.sin(-2*math.pi*dir/N*(j-8)*16)*x_r_level3[16*i+j]+math.cos(-2*math.pi*dir/N*(j-8)*16)*x_i_level3[16*i+j])
                           
        if(level_num==5):
           for i in range(8):
               for j in range(32):
                   if(j<16):
                       x_r_level5[32*i+j]=x_r_level4[32*i+j]+math.cos(-2*math.pi*dir/N*j*8)*x_r_level4[32*i+j+16]-math.sin(-2*math.pi*dir/N*j*8)*x_i_level4[32*i+j+16]
                       x_i_level5[32*i+j]=x_i_level4[32*i+j]+(math.sin(-2*math.pi*dir/N*j*8)*x_r_level4[32*i+j+16]+math.cos(-2*math.pi*dir/N*j*8)*x_i_level4[32*i+j+16])
                   else:
                       x_r_level5[32*i+j]=x_r_level4[32*i+j-16]-(math.cos(-2*math.pi*dir/N*(j-16)*8)*x_r_level4[32*i+j]-math.sin(-2*math.pi*dir/N*(j-16)*8)*x_i_level4[32*i+j])
                       x_i_level5[32*i+j]=x_i_level4[32*i+j-16]-(math.sin(-2*math.pi*dir/N*(j-16)*8)*x_r_level4[32*i+j]+math.cos(-2*math.pi*dir/N*(j-16)*8)*x_i_level4[32*i+j])
        
        if(level_num==6):
           for i in range(4):
               for j in range(64):
                   if(j<32):
                       x_r_level6[64*i+j]=x_r_level5[64*i+j]+math.cos(-2*math.pi*dir/N*j*4)*x_r_level5[64*i+j+32]-math.sin(-2*math.pi*dir/N*j*4)*x_i_level5[64*i+j+32]
                       x_i_level6[64*i+j]=x_i_level5[64*i+j]+(math.sin(-2*math.pi*dir/N*j*4)*x_r_level5[64*i+j+32]+math.cos(-2*math.pi*dir/N*j*4)*x_i_level5[64*i+j+32])
                   else:
                       x_r_level6[64*i+j]=x_r_level5[64*i+j-32]-(math.cos(-2*math.pi*dir/N*(j-32)*4)*x_r_level5[64*i+j]-math.sin(-2*math.pi*dir/N*(j-32)*4)*x_i_level5[64*i+j])
                       x_i_level6[64*i+j]=x_i_level5[64*i+j-32]-(math.sin(-2*math.pi*dir/N*(j-32)*4)*x_r_level5[64*i+j]+math.cos(-2*math.pi*dir/N*(j-32)*4)*x_i_level5[64*i+j])

        if(level_num==7):
           for i in range(2):
               for j in range(128):
                   if(j<64):
                       x_r_level7[128*i+j]=x_r_level6[128*i+j]+math.cos(-2*math.pi*dir/N*j*2)*x_r_level6[128*i+j+64]-math.sin(-2*math.pi*dir/N*j*2)*x_i_level6[128*i+j+64]
                       x_i_level7[128*i+j]=x_i_level6[128*i+j]+(math.sin(-2*math.pi*dir/N*j*2)*x_r_level6[128*i+j+64]+math.cos(-2*math.pi*dir/N*j*2)*x_i_level6[128*i+j+64])
                   else:
                       x_r_level7[128*i+j]=x_r_level6[128*i+j-64]-(math.cos(-2*math.pi*dir/N*(j-64)*2)*x_r_level6[128*i+j]-math.sin(-2*math.pi*dir/N*(j-64)*2)*x_i_level6[128*i+j])
                       x_i_level7[128*i+j]=x_i_level6[128*i+j-64]-(math.sin(-2*math.pi*dir/N*(j-64)*2)*x_r_level6[128*i+j]+math.cos(-2*math.pi*dir/N*(j-64)*2)*x_i_level6[128*i+j])
        if(level_num==8):
            for j in range(256):
                if(j<128):
                    x_r_level8 [j]=x_r_level7 [j]+math.cos(-2*math.pi*dir/N*j)*x_r_level7 [j+128]-math.sin(-2*math.pi*dir/N*j)*x_i_level7 [j+128]
                    x_i_level8 [j]=x_i_level7 [j]+(math.sin(-2*math.pi*dir/N*j)*x_r_level7 [j+128]+math.cos(-2*math.pi*dir/N*j)*x_i_level7 [j+128])
                else:
                    x_r_level8 [j]=x_r_level7 [j-128]-(math.cos(-2*math.pi*dir/N*(j-128))*x_r_level7 [j]-math.sin(-2*math.pi*dir/N*(j-128))*x_i_level7 [j])
                    x_i_level8 [j]=x_i_level7 [j-128]-(math.sin(-2*math.pi*dir/N*(j-128))*x_r_level7 [j]+math.cos(-2*math.pi*dir/N*(j-128))*x_i_level7 [j])
   x_r_level8_ifft=[]
   x_i_level8_ifft=[]
   if dir==-1:
        for i in range(256):
            x_r_level8_ifft.append(x_r_level8[i]/256)
            x_i_level8_ifft.append(x_i_level8[i]/256)
        return [x_r,x_i,x_r_level0, x_i_level0, x_r_level1, x_i_level1, x_r_level2, x_i_level2, x_r_level3, x_i_level3, x_r_level4, x_i_level4, x_r_level5, x_i_level5, x_r_level6, x_i_level6, x_r_level7, x_i_level7, x_r_level8_ifft, x_i_level8_ifft]
   return [x_r,x_i,x_r_level0, x_i_level0, x_r_level1, x_i_level1, x_r_level2, x_i_level2, x_r_level3, x_i_level3, x_r_level4, x_i_level4, x_r_level5, x_i_level5, x_r_level6, x_i_level6, x_r_level7, x_i_level7, x_r_level8, x_i_level8]

def to_i_f_binary(value,inter,frac):
        fixed_point_value = int(value * (2**frac))
        if fixed_point_value < 0:
            fixed_point_value += 2**(inter+frac)
        return bin(fixed_point_value)[2:].zfill(inter+frac)

def bin2dec(bin,inter):
        n=len(bin)
        dec=0
        for i in range(n):
            if i==0:
                if bin[i]=='1':
                    dec=-2**(inter-1)
            else:
                if bin[i]=='1':
                    dec=dec+2**(inter-1-i)
        return dec

import random
# import numpy as np
if __name__=="__main__":
    random.seed(1000)
    factor = 10000  # 设置精度因子
    inter=16
    all_dig=32
    dir=1
    N=256


    x_r=[random.randint(-1 * factor, 1 * factor) / factor for _ in range(N)]
    x_i=[random.randint(-1* factor, 1 * factor) / factor for _ in range(N)]

    sinx=[math.sin(-2*dir*math.pi*i/N) for i in range(N)]
    cosx=[math.cos(-2*dir*math.pi/N*i) for  i in range(N)]


    file_paths= [
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage0_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage0_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage1_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage1_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage2_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage2_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage3_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage3_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage4_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage4_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage5_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage5_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage6_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage6_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage7_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage7_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage8_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\stage8_i.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\Output_r.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\debug\\Output_i.txt"
    ]

    data_vivado_s = []
    data_vivado_double=[]

    for file_path in file_paths:
        with open(file_path, 'r') as file:
            file_content = [line.strip() for line in file.readlines()]  # 读取每一行并去除换行符
            data_vivado_s.append(file_content)

    data_python_double=myfft_dit(x_r,x_i,dir)
    data_vivado_double=data_vivado_s

    for num_file in range(20):
        for num_data in range(256):
            data_vivado_double[num_file][num_data]=bin2dec(data_vivado_s[num_file][num_data],inter)
    
    delta=[]
    for file in range(20):
        delta_ele=0
        for i in range(256):
            # print(f"data_python_double[{file}][{i}]={data_python_double[file][i]},while data_vivado_double[{file}][{i}]={data_vivado_double[file][i]}\n")
            delta_ele=(data_vivado_double[file][i]-data_python_double[file][i])**2
        delta.append(delta_ele)
    #打印各级的误差
    for i in range(len(delta)):
        print(f"delta_file[{i}]={delta[i]}\n")




    
