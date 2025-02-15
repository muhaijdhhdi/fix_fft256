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
import numpy as np
if __name__=="__main__":
    random.seed(1000)
    factor = 10000  # 设置精度因子
    inter=9
    all_dig=16
    
    N=256

    x_r=[random.randint(-1 * factor, 1 * factor) / factor for _ in range(N)]
    x_i=[random.randint(-1 * factor, 1 * factor) / factor for _ in range(N)]

    sinx=[math.sin(-2*math.pi*i/N) for i in range(N)]
    cosx=[math.cos(-2*math.pi/N*i) for  i in range(N)]

    comp_x=[x_r[i]+1j*x_i[i] for i in range(N)]
    comp_y= np.fft.fft(comp_x)
    y_r_real_double = np.real(comp_y)
    y_i_real_double = np.imag(comp_y)
    
    Path=[
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\y_r_fix_bin.txt",
        "C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_fft\\y_i_fix_bin.txt"
    ]

    lines=[]
    real_double=[y_r_real_double,y_i_real_double]
    model_double=[]
    delta=[]
    for i in range(2):
        with open(Path[i],'r') as f:
              lines.append(f.readlines())
        model_double_ele=[]
        for line in lines[i]:
            model_double_ele.append(bin2dec(line.strip(),inter))
        model_double.append(model_double_ele)
    
    for i in range(2):
        delta_ele=[]
        for j in range(N):
              delta_ele.append(real_double[i][j]-model_double[i][j])
        delta.append(delta_ele)
    error_sqr=[]
    for i in range(2):
        s=0
        for j in range(N):
                s=s+delta[i][j]**2
        error_sqr.append(s)

    for i in range(2):
         print(error_sqr[i])

    # for i in range(N):
    #      print(delta[0][i])