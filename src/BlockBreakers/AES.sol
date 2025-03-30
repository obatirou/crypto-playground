// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import "forge-std/console.sol";

contract AES {
    // @notice The s-box is a lookup table that maps each byte to its corresponding value
    bytes constant s_box =
        hex"637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b27509832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cfd0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdbe0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9ee1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16";

    // @notice The round constant is a lookup table that maps each round to its corresponding value
    // See AESUtils.py for explanation: calculate_r_con(256)
    bytes constant r_con =
        hex"8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d";

    // @notice The state of the AES cipher is represented as 4 bytes4
    // Each byte4 represents a column of the state
    struct AESState {
        bytes4 column_0;
        bytes4 column_1;
        bytes4 column_2;
        bytes4 column_3;
    }

    /// @notice Rotate a 4-byte word left by 8 bits
    /// @param word The word to rotate
    /// @return The rotated word
    function RotWord(bytes4 word) public pure returns (bytes4) {
        uint32 w = uint32(word);
        // OR the word shifted left by 8 bits and the word shifted right by 24 bits
        // Ex:
        // 0x34567800 | 0x00000012 -> 0x34567812
        uint32 rotated = (w << 8) | (w >> 24);
        return bytes4(rotated);
    }

    /// @notice Substitute each byte of the word with the corresponding value in the s-box
    /// @param word The word to substitute
    /// @return The substituted word
    /// @dev The s-box is a lookup table that maps each byte to its corresponding value
    /// In this case, the s-box was flattened to a single bytes constant
    function SubWord(bytes4 word) public pure returns (bytes4) {
        uint32 result;
        for (uint8 i = 0; i < 4; i++) {
            uint8 value = uint8(s_box[uint8(word[i])]);
            result = (result << 8) | value;
        }
        return bytes4(result);
    }

    /// @notice Generate the round constant for the given round
    /// @param round The round number
    /// @return The round constant
    function RCon(uint256 round) public pure returns (bytes4) {
        uint32 rcon_byte = uint32(uint8(r_con[round]));
        return bytes4(rcon_byte << 24);
    }

    /// @notice Expand the key into a list of round keys
    /// @dev There are 11 rounds in total. Each round key is represented as 4 bytes4
    /// The first round key is the original key.
    /// @param key The key to expand
    /// @return The list of round keys
    function KeyExpansion(bytes16 key) public pure returns (bytes4[] memory) {
        bytes4[] memory round_keys = new bytes4[](44);
        round_keys[0] = bytes1ToBytes4(key[0], key[1], key[2], key[3]);
        round_keys[1] = bytes1ToBytes4(key[4], key[5], key[6], key[7]);
        round_keys[2] = bytes1ToBytes4(key[8], key[9], key[10], key[11]);
        round_keys[3] = bytes1ToBytes4(key[12], key[13], key[14], key[15]);
        uint256 round_number = 1;
        for (uint8 i = 4; i < 41; i += 4) {
            bytes4 temp = round_keys[i - 1];
            temp = RotWord(temp);
            temp = SubWord(temp);
            temp = temp ^ round_keys[i - 4];
            temp = temp ^ RCon(round_number);
            round_keys[i] = temp;
            // To obtain the other (3) columns of a round key, XOR the previous
            // column with the previous round key's column of the same index
            //         ⊕--------------⊕-----
            //         |              |    |
            //         |              |    v
            // +----+----+----+----+----+----+
            // | 00 | 04 | 08 | 0c | fe |    |
            // +----+----+----+----+----+----+
            // | 01 | 05 | 09 | 0d | af |    |
            // +----+----+----+----+----+----+
            // | 02 | 06 | 0a | 0e | 01 |    |
            // +----+----+----+----+----+----+
            // | 03 | 07 | 0b | 0f | b7 |    |
            // +----+----+----+----+----+----+
            round_keys[i + 1] = round_keys[i] ^ round_keys[i - 3];
            round_keys[i + 2] = round_keys[i + 1] ^ round_keys[i - 2];
            round_keys[i + 3] = round_keys[i + 2] ^ round_keys[i - 1];
            round_number++;
        }
        return round_keys;
    }

    function bytes1ToBytes4(bytes1 a, bytes1 b, bytes1 c, bytes1 d) internal pure returns (bytes4) {
        return bytes4((uint32(uint8(a)) << 24) | (uint32(uint8(b)) << 16) | (uint32(uint8(c)) << 8) | uint32(uint8(d)));
    }

    function subBytes(AESState memory state) public pure returns (AESState memory) {
        state.column_0 = SubWord(state.column_0);
        state.column_1 = SubWord(state.column_1);
        state.column_2 = SubWord(state.column_2);
        state.column_3 = SubWord(state.column_3);
        return state;
    }
}
