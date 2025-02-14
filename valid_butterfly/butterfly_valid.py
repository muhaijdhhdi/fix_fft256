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
import math

if __name__=="__main__":
    random.seed(1000)
    factor = 10000  # 设置精度因子
    inter=11
    all_dig=20
    
    N=20

    x1_r=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    x1_i=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    x2_r=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    x2_i=[random.randint(-256 * factor, 255 * factor) / factor for _ in range(N)]
    sinx=[math.sin(-2*math.pi*i/N) for i in range(N)]
    cosx=[math.cos(-2*math.pi/N*i) for  i in range(N)]

    ac_real_double=[cosx[i]*x2_r[i]for i in range(N)]  
    bd_real_double=[sinx[i]*x2_i[i]for i in range(N)]  
    ad_real_double=[sinx[i]*x2_r[i]for i in range(N)]  
    bc_real_double=[cosx[i]*x2_i[i]for i in range(N)]
    
    temp_r_real_double=[ac_real_double[i]-bd_real_double[i] for i in range(N)]
    temp_i_real_double=[ad_real_double[i]+bc_real_double[i] for i in range(N)]

    
    y1_r_real_double=[x1_r[i]+cosx[i]*x2_r[i]-sinx[i]*x2_i[i] for i in range(N)]
    y1_i_real_double=[x1_i[i]+cosx[i]*x2_i[i]+sinx[i]*x2_r[i] for i in range(N)]
    y2_r_real_double=[x1_r[i]-(cosx[i]*x2_r[i]-sinx[i]*x2_i[i]) for i in range(N)]
    y2_i_real_double=[x1_i[i]-(cosx[i]*x2_i[i]+sinx[i]*x2_r[i]) for i in range(N)]
    
    Path=[
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\ac_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\bd_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\ad_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\bc_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\temp_r_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\temp_i_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y1_r_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y1_i_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y2_r_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_butterfly\\y2_i_fix_bin.txt"
    ]

    lines=[]
    real_double=[ac_real_double,bd_real_double,ad_real_double,bc_real_double,temp_r_real_double,temp_i_real_double,y1_r_real_double,y1_i_real_double,y2_r_real_double,y2_i_real_double]
    model_double=[]
    delta=[]
    for i in range(10):
        with open(Path[i],'r') as f:
              lines.append(f.readlines())
        model_double_ele=[]
        for line in lines[i]:
            model_double_ele.append(bin2dec(line.strip(),inter))
        model_double.append(model_double_ele)
    
    for i in range(10):
        delta_ele=[]
        for j in range(N):
              delta_ele.append(real_double[i][j]-model_double[i][j])
        delta.append(delta_ele)
    error_sqr=[]
    for i in range(10):
        s=0
        for j in range(N):
              if model_double[i][j]!=0:
                s=s+delta[i][j]/model_double[i][j]
        error_sqr.append(s)

    for i in range(10):
         print(error_sqr[i])