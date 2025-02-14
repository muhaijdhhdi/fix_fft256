import random
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
    inter=10
    all_dig=16

    a_fix_double = [random.randint(-256 * factor, 255 * factor) / factor for _ in range(512)]
    b_fix_double = [random.randint(-256 * factor, 255 * factor) / factor for _ in range(512)] 
    

    adder_fix_real_double=[a_fix_double[i]+b_fix_double[i] for i in range(512)]
    sub_fix_real_double=[a_fix_double[i]-b_fix_double[i] for i in range(512)]

    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\adder_fix_bin.txt", "r") as f_r:
        adder_fix_model_str = f_r.readlines()  # 读取文件的每一行
    adder_fix_model_double=[]
    for line in adder_fix_model_str:
        adder_fix_model_double.append(bin2dec(line.strip(),inter))
    delta_adder=0
    # for i in range(512):
    #     delta_adder=((adder_fix_model_double[i]-adder_fix_real_double[i])/adder_fix_real_double[i])**2+delta_adder
    # print(f"{inter}.{all_dig-inter}_error:{delta_adder}")

    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\sub_fix_bin.txt", "r") as f_r:
        sub_fix_model_str = f_r.readlines()  # 读取文件的每一行
    sub_fix_model_double=[]
    for line in sub_fix_model_str:
        sub_fix_model_double.append(bin2dec(line.strip(),inter))
    delta_sub=0
    for i in range(512):
        print(f'delta_adder[{i}]={adder_fix_model_double[i]-adder_fix_real_double[i]}')
        print(f'delta_sub[{i}]={sub_fix_model_double[i]-sub_fix_real_double[i]}')

        # delta_sub=((sub_fix_model_double[i]-sub_fix_real_double[i])/sub_fix_real_double[i])**2+delta_sub
    # print(f"{inter}.{all_dig-inter}_error:{delta_sub}")