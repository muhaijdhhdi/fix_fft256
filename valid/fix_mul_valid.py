import random

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
def to_q9_7_binary(value):
        fixed_point_value = int(value * (2**7))
        if fixed_point_value < 0:
            fixed_point_value += 2**16
        return bin(fixed_point_value)[2:].zfill(16)
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
    random.seed(10)
    factor = 10000  # 设置精度因子
    inter=9
    all_dig=16

    a_fix_double = [random.randint(-256 * factor, 255 * factor) / factor for _ in range(512)]
    b_fix_double = [ random.uniform(-1* factor, 1* factor) / factor for _ in range(512)]
    
    

    r_fix_real_double=[a_fix_double[i]*b_fix_double[i] for i in range(512)]
    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid\\r_fix_bin.txt", "r") as f_r:
        r_fix_model_str = f_r.readlines()  # 读取文件的每一行
    r_fix_model_double=[]
    for line in r_fix_model_str:
        # print(line.strip())  # 使用strip()去除每行的换行符
        r_fix_model_double.append(bin2dec(line.strip(),inter))
    delta=0
    for i in range(512):
        delta=((r_fix_model_double[i]-r_fix_real_double[i])/r_fix_real_double[i])**2+delta
    print(f"{inter}.{all_dig-inter}_error:{delta}")