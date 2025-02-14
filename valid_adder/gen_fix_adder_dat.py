import random
def to_i_f_binary(value,inter,frac):
        fixed_point_value = int(value * (2**frac))
        if fixed_point_value < 0:
            fixed_point_value += 2**(inter+frac)
        return bin(fixed_point_value)[2:].zfill(inter+frac)
if __name__=="__main__":
    random.seed(10)
    factor = 10000  # 设置精度因子

    a_fix_double = [random.randint(-256 * factor, 255 * factor) / factor for _ in range(512)]
    b_fix_double = [random.randint(-256 * factor, 255 * factor) / factor for _ in range(512)] 
    
    a_fix_bin = [to_i_f_binary(val,10,6) for val in a_fix_double]
    b_fix_bin = [to_i_f_binary(val,10,6) for val in b_fix_double]
    
    
    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\a_fix_bin.txt", "w") as f_a:
        for bin_val in a_fix_bin:
            f_a.write(bin_val + "\n")

    with open("C:\\Users\\32172\\Desktop\\fft_fix\\scr\\valid_adder\\b_fix_bin.txt", "w") as f_b:
        for bin_val in b_fix_bin:
            f_b.write(bin_val + "\n")