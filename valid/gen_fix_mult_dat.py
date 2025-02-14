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
def to_i_f_binary(value,inter,frac):
        fixed_point_value = int(value * (2**frac))
        if fixed_point_value < 0:
            fixed_point_value += 2**(inter+frac)
        return bin(fixed_point_value)[2:].zfill(inter+frac)



        
if __name__=="__main__":
    random.seed(10)
    factor = 10000  # 设置精度因子

    a_fix_double = [random.randint(-256 * factor, 255 * factor) / factor for _ in range(512)]
    b_fix_double = [ random.uniform(-1* factor, 1* factor) / factor for _ in range(512)]
    
    a_fix_bin = [to_i_f_binary(val,9,7) for val in a_fix_double]
    b_fix_bin = [to_i_f_binary(val,2,14) for val in b_fix_double]
    
    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid\\a_fix_bin.txt", "w") as f_a:
        for bin_val in a_fix_bin:
            f_a.write(bin_val + "\n")

    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid\\b_fix_bin.txt", "w") as f_b:
        for bin_val in b_fix_bin:
            f_b.write(bin_val + "\n")

    

        
        
