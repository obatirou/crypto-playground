import sys


def RotWord(word: bytes) -> bytes:
    return word[1:] + word[:1]


def hex_to_bytes(hex_str: str) -> bytes:
    # remove the 0x prefix
    return bytes.fromhex(hex_str[2:])


if __name__ == "__main__":
    func_to_call = sys.argv[1]
    # Should do something more robust here and also use a web3 library but will do for now
    if func_to_call == "RotWord":
        word = sys.argv[2]
        print(
            "0x"
            + RotWord(hex_to_bytes(word[:10])).hex()
            + "00000000000000000000000000000000000000000000000000000000"
        )
