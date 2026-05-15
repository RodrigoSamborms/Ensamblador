def emulate_original(s):
    src = list(s) + ['$']
    SI = 0
    DI = 0
    BL = 0
    dest = []
    while True:
        BL += 1
        AL = src[SI]
        dest.append(AL)
        SI += 1
        DI += 1
        if AL == '$':
            break
    return BL, ''.join(dest)


def emulate_fixed(s):
    src = list(s) + ['$']
    SI = 0
    DI = 0
    BL = 0
    dest = []
    while True:
        AL = src[SI]
        if AL == '$':
            break
        dest.append(AL)
        SI += 1
        DI += 1
        BL += 1
    return BL, ''.join(dest)

cases = ["", "A", "HELLO", "1234567890"]
for c in cases:
    o_count, o_dest = emulate_original(c)
    f_count, f_dest = emulate_fixed(c)
    print(f"input='{c}' => original_count={o_count}, fixed_count={f_count}, dest_fixed='{f_dest}'")
