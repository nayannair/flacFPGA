FIXED = 0
PRED_ORD = 4

from math import log2, log, ceil

bin2hex = {'0000':'0', '0001':'1', '0010':'2', '0011':'3', '0100':'4',
           '0101':'5', '0110':'6', '0111':'7', '1000':'8', '1001':'9',
           '1010':'a', '1011':'b', '1100':'c', '1101':'d', '1110':'e', '1111':'f'}

def lpc_resids(samples):
    resids = [0] * (len(samples) - 4)
    for ind in range(4, len(samples)):
        pred = (4 * samples[ind - 1]) - (6 * samples[ind - 2]) + (4 * samples[ind - 3]) - samples[ind - 4]
        resids[ind - 4] = samples[ind] - pred
    return resids

def hexify_num(num, len_bits=16):
    if (len_bits % 4):
        raise ValueError("The total number of bits should be a multiple of 4")
    if type(num) == str:
        len_num = len(num)
        padding = 4 - (len_num % 4) if (len_num % 4) else 0
        complete_num = num + ('0' * padding)
        len_list_hex = (len_num + padding) // 4
        list_hex = ['0'] * len_list_hex
        for i in range(0, len_num + padding, 4):
            list_hex[i//4] = bin2hex[complete_num[i : i + 4]]
        hex_rep = ''.join(list_hex)
        return hex_rep
    else:
        map_num = num + (2**(len_bits)) if (num < 0) else num
        temp = hex(map_num)[2:].upper()
        if ((len_bits // 4) < len(temp)):
            raise ValueError("Cannot represent {0} in {1} bits".format(num, len_bits))
        hex_rep = temp if (num < 0) else ('0' * ((len_bits // 4) - len(temp))) + temp
        return hex_rep

def hexify(samples, len_bits=16):
    if (type(samples) == int) or (type(samples) == str):
        return hexify_num(samples, len_bits)
    else:
        hex_samples = [hexify_num(sample, len_bits) for sample in samples]
        return hex_samples

def binify_num(num, len_bits=16):
    if (len_bits <= 0):
        raise ValueError("The total number of bits should be greater than 0")
    map_num = num + (2**(len_bits)) if (num < 0) else num
    temp = bin(map_num)[2:]
    if (len_bits < len(temp)):
        raise ValueError("Cannot represent {0} in {1} bits".format(num, len_bits))
    bin_rep = temp if (num < 0) else ('0' * (len_bits - len(temp))) + temp
    return bin_rep

def binify(samples, len_bits=16):
    if type(samples) == int:
        return binify_num(samples, len_bits)
    else:
        bin_samples = [binify_num(sample, len_bits) for sample in samples]
        return bin_samples

def rice_encode_num(num, rice_param):
    map_num = (2*abs(num))-1 if (num<0) else (2*num)
    if (rice_param < 0):
        raise ValueError("The rice parameter must be >= 0")
    elif (rice_param == 0):
        msb = hex(map_num)[2:]
        lsb = '1'
    else:
        msb = hex(map_num>>rice_param)[2:]
        lsb = hex(int('1'+binify(map_num & ((1<<rice_param)-1), rice_param), 2))[2:]
    return (msb, lsb)

def rice_encode(samples, rice_param):
    if type(samples) == int:
        return rice_encode_num(samples, rice_param)
    else:
        encoded_samples = [rice_encode_num(sample, rice_param) for sample in samples]
        return encoded_samples

def dec2bin(num, length=0):
    bin_rep = bin(num)[2:]  # to get rid of the '0b'
    bin_rep_l = len(bin_rep)
    if length != 0:
        if bin_rep_l == length:
            return bin_rep
        elif bin_rep_l < length:
            return '0'*(length-bin_rep_l) + bin_rep
        else:
            raise ValueError('Cannot represent value in {0} bits'.format(length))
    else:
        return bin_rep

def fixed_lpc(channel, num_samples, pred_ord):
    fixed_coeffs = [[0], [1], [2, -1], [3, -3, 1], [4, -6, 4, -1]]
    residuals = [0 for i in range(num_samples - pred_ord)]
    chan_ind = pred_ord - 1
    resid_ind = 0
    while resid_ind < num_samples - pred_ord:
        pred = 0
        count = 0
        while count < pred_ord:
            pred += fixed_coeffs[pred_ord][count] * channel[chan_ind - count]
            count += 1
        chan_ind += 1
        residuals[resid_ind] = channel[chan_ind] - pred
        resid_ind += 1
    return residuals   

def get_residuals(channel, num_samples, LPC_TYPE=FIXED, pred_ord=PRED_ORD):
    if LPC_TYPE == FIXED:
        residuals = fixed_lpc(channel, num_samples, pred_ord)
    return residuals

def get_rice_param(residuals, length):
    e_x = ceil(sum(map(abs, residuals)) / length)
    ln_2 = log(2)
    return ceil(log2(ln_2 * e_x)) if e_x > 0.0 else 0

def get_enc_residuals(residuals, len_resids, rice_param):
    # check http://lists.xiph.org/pipermail/flac-dev/2005-April/001788.html
    enc_residuals = [0 for i in range(len_resids)]
    ind = 0
    while ind < len_resids:
        map_sample = (-2 * residuals[ind]) - 1 if residuals[ind] < 0 else 2 * residuals[ind]
        mask = (1 << rice_param) - 1
        low_order_bits = map_sample & mask
        high_order_bits = map_sample >> rice_param
        # added 'rice_param; as argument to dec2bin in case 'k' bits  . # of bits of 'low_order_bits'
        enc_residuals[ind] = '0' * high_order_bits + '1' + (dec2bin(low_order_bits, rice_param) if rice_param != 0 else '')
        ind += 1
    return ''.join(enc_residuals)

def make_reg_ready(bitstream, reg_width=16):
    if (reg_width <= 0):
        raise ValueError("Register width cannot be lesser than 1!")
    remainder = len(bitstream) % reg_width
    padding = reg_width - remainder if (remainder != 0) else 0
    return bitstream + ('0' * padding)

def check_equal(stream1, stream2):
    len_stream1 = len(stream1)
    print("Length of stream 1: {0}".format(len_stream1))
    len_stream2 = len(stream2)
    print("Length of stream 2: {0}".format(len_stream2))
    unequals = []
    for i in range(min(len_stream1, len_stream2)):
        if stream1[i] != stream2[i]:
            unequals.append((i, (i // 8) + 1, i % 8))
    return unequals

def testbench(samples, num_samples, rice_param, order=4, block_size=16):
    if (num_samples <= order):
        bitstream = ''.join(binify(samples[0:num_samples]))
        return bitstream
    elif (num_samples <= block_size):
        warm_up = testbench(samples, order, rice_param, order, block_size)
        rice_param_rep = dec2bin(rice_param, 4)
        enc_resids = get_enc_residuals(get_residuals(samples, num_samples, 0, order), num_samples-order, rice_param)
        return warm_up + rice_param_rep + enc_resids
    else:
        remaining_samples = num_samples % block_size
        num_blocks = num_samples // block_size
        bitstream_list = [''] * ((num_samples // block_size) + (1 if (remaining_samples != 0) else 0))
        offset = 0
        ind = 0
        while ind < num_blocks:
            bitstream_list[ind] = testbench(samples[offset : offset + block_size], block_size, rice_param, order, block_size)
            ind += 1
            offset += block_size
        if (remaining_samples != 0):
            bitstream_list[-1] = testbench(samples[num_samples - remaining_samples : num_samples], remaining_samples, rice_param, order, block_size)
        return ''.join(bitstream_list)
