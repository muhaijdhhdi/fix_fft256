import random
import math

def cmp(n, bin):
    c='0'
    if len(bin) != n:
        raise ValueError("Input binary string length doesn't match specified N")
    cmp=''
    for i in range(n-1,-1,-1):
        if i==n-1:
            if bin[i]=='1':
                c='0';cmp=cmp+'1'
            else:
                c='1';cmp=cmp+'0'
        else:
            if bin[i]=='1' and c=='0':
                cmp=cmp+'0';c='0'
            else:
                if (bin[i]=='1' and c=='1') or (bin[i]=='0' and c=='0'):
                    cmp=cmp+'1';c='0'
                else:
                     if bin[i]=='0'and c=='1':
                        cmp=cmp+'0';c='1'
    return cmp[: : -1]
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


        
if __name__=="__main__":
    random.seed(1000)
    factor = 10000  # 设置精度因子
    N=20
    int1=11;int2=2;frac1=9;frac2=18

    x1_r=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    x1_i=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    x2_r=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    x2_i=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    sinx=[math.sin(-2*math.pi*i/N) for i in range(N)]
    cosx=[math.cos(-2*math.pi*i/N) for i in range(N)]
    
    #转换为定点数bin形式
    x1_r_fix_bin = [to_i_f_binary(val,int1,frac1) for val in x1_r]
    x2_r_fix_bin = [to_i_f_binary(val,int1,frac1) for val in x2_r]
    x1_i_fix_bin = [to_i_f_binary(val,int1,frac1) for val in x1_i]
    x2_i_fix_bin = [to_i_f_binary(val,int1,frac1) for val in x2_i]
    sinx_fix_bin=[to_i_f_binary(val,int2,frac2) for val in sinx]
    cosx_fix_bin=[to_i_f_binary(val,int2,frac2) for val in cosx]

    # for i in range(N):
    #     print(bin2dec(x1_r_fix_bin[i],int1)-x1_r[i])
    Path=[
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x1_r_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x1_i_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x2_r_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\x2_i_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\sinx_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\cosx_fix_bin.txt"
        ]
    bins=[x1_r_fix_bin,x1_i_fix_bin,x2_r_fix_bin,x2_i_fix_bin,sinx_fix_bin,cosx_fix_bin]
    #写入文件.fix_bin.txt文件中
    for i in range(6):
        with open(Path[i], "w") as f_a:
            for bin_val in bins[i]:
                f_a.write(bin_val + "\n")

    

        
        
