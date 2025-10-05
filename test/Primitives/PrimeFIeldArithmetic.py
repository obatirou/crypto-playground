import sys

def add(a, b, p):
    return (a + b) % p

def mul(a, b, p):
    return (a * b) % p

def sub(a, b, p):
    return (a + p - b) % p

def mulInv(a, p):
    return pow(a, -1, p)

def div(a, b, p):
    if b % p == 0:
        raise ValueError("Division by zero")
    return (a * mulInv(b, p)) % p


def isPrime(p):
    for i in range(2, p):
        if p % i == 0:
            return False
    return True


if __name__ == "__main__":
    func_to_call = sys.argv[1]
    if func_to_call == "isPrime":
        p = int(sys.argv[2])
        print("0x" + format(int(isPrime(p)), "064x"))
    if func_to_call == "add":
        a = int(sys.argv[2])
        b = int(sys.argv[3])
        p = int(sys.argv[4])
        print("0x" + format(add(a, b, p), '064x'))
    elif func_to_call == "mul":
        a = int(sys.argv[2])
        b = int(sys.argv[3])
        p = int(sys.argv[4])
        print("0x" + format(mul(a, b, p), '064x'))
    elif func_to_call == "sub":
        a = int(sys.argv[2])
        b = int(sys.argv[3])
        p = int(sys.argv[4])
        print("0x" + format(sub(a, b, p), '064x'))
    elif func_to_call == "mulInv":
        a = int(sys.argv[2])
        p = int(sys.argv[4])
        print("0x" + format(mulInv(a, p), '064x'))
    elif func_to_call == "div":
        a = int(sys.argv[2])
        b = int(sys.argv[3])
        p = int(sys.argv[4])
        print("0x" + format(div(a, b, p), '064x'))
