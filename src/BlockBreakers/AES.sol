// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

contract AES {
    // @notice The s-box is a lookup table that maps each byte to its corresponding value
    bytes constant s_box =
        hex"637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b27509832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cfd0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdbe0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9ee1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16";

    // @notice The round constant is a lookup table that maps each round to its corresponding value
    // See AESUtils.py for explanation: calculate_r_con(256)
    bytes constant r_con =
        hex"8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d";

    // @notice The multiplication by 2 lookup table on the Galois field GF(2^8)
    bytes constant mul_by_2 =
        hex"00020406080a0c0e10121416181a1c1e20222426282a2c2e30323436383a3c3e40424446484a4c4e50525456585a5c5e60626466686a6c6e70727476787a7c7e80828486888a8c8e90929496989a9c9ea0a2a4a6a8aaacaeb0b2b4b6b8babcbec0c2c4c6c8caccced0d2d4d6d8dadcdee0e2e4e6e8eaeceef0f2f4f6f8fafcfe1b191f1d131117150b090f0d030107053b393f3d333137352b292f2d232127255b595f5d535157554b494f4d434147457b797f7d737177756b696f6d636167659b999f9d939197958b898f8d83818785bbb9bfbdb3b1b7b5aba9afada3a1a7a5dbd9dfddd3d1d7d5cbc9cfcdc3c1c7c5fbf9fffdf3f1f7f5ebe9efede3e1e7e5";

    // @notice The multiplication by 3 lookup table on the Galois field GF(2^8)
    bytes constant mul_by_3 =
        hex"000306050c0f0a09181b1e1d14171211303336353c3f3a39282b2e2d24272221606366656c6f6a69787b7e7d74777271505356555c5f5a59484b4e4d44474241c0c3c6c5cccfcac9d8dbdeddd4d7d2d1f0f3f6f5fcfffaf9e8ebeeede4e7e2e1a0a3a6a5acafaaa9b8bbbebdb4b7b2b1909396959c9f9a99888b8e8d848782819b989d9e97949192838085868f8c898aaba8adaea7a4a1a2b3b0b5b6bfbcb9bafbf8fdfef7f4f1f2e3e0e5e6efece9eacbc8cdcec7c4c1c2d3d0d5d6dfdcd9da5b585d5e57545152434045464f4c494a6b686d6e67646162737075767f7c797a3b383d3e37343132232025262f2c292a0b080d0e07040102131015161f1c191a";

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
    function rotWord(bytes4 word) public pure returns (bytes4) {
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
    function subWord(bytes4 word) public pure returns (bytes4) {
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
    function rcon(uint256 round) public pure returns (bytes4) {
        uint32 rcon_byte = uint32(uint8(r_con[round]));
        return bytes4(rcon_byte << 24);
    }

    /// @notice Expand the key into a list of round keys
    /// @dev There are 11 rounds in total. Each round key is represented as 4 bytes4
    /// The first round key is the original key.
    /// @param key The key to expand
    /// @return The list of round keys
    function keyExpansion(bytes16 key) public pure returns (bytes4[] memory) {
        bytes4[] memory round_keys = new bytes4[](44);
        round_keys[0] = _bytes1ToBytes4(key[0], key[1], key[2], key[3]);
        round_keys[1] = _bytes1ToBytes4(key[4], key[5], key[6], key[7]);
        round_keys[2] = _bytes1ToBytes4(key[8], key[9], key[10], key[11]);
        round_keys[3] = _bytes1ToBytes4(key[12], key[13], key[14], key[15]);
        uint256 round_number = 1;
        for (uint8 i = 4; i < 41; i += 4) {
            bytes4 temp = round_keys[i - 1];
            temp = rotWord(temp);
            temp = subWord(temp);
            temp = temp ^ round_keys[i - 4];
            temp = temp ^ rcon(round_number);
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

    function _bytes1ToBytes4(bytes1 a, bytes1 b, bytes1 c, bytes1 d) internal pure returns (bytes4) {
        return bytes4((uint32(uint8(a)) << 24) | (uint32(uint8(b)) << 16) | (uint32(uint8(c)) << 8) | uint32(uint8(d)));
    }

    /// @notice Substitute each byte of the state with the corresponding value in the s-box
    /// @param state The state to substitute
    /// @return The substituted state
    function subBytes(AESState memory state) public pure returns (AESState memory) {
        state.column_0 = subWord(state.column_0);
        state.column_1 = subWord(state.column_1);
        state.column_2 = subWord(state.column_2);
        state.column_3 = subWord(state.column_3);
        return state;
    }

    /// @notice Shift the rows of the state
    /// @param state The state to shift
    /// @return The shifted state
    ///
    /// 0 1 2 3    0 1 2 3
    /// 4 5 6 7 -> 5 6 7 4
    /// 8 9 a b    a b 8 9
    /// c d e f    f c d e
    function shiftRows(AESState memory state) public pure returns (AESState memory) {
        bytes4[] memory rows = new bytes4[](4);
        rows[0] = _bytes1ToBytes4(state.column_0[0], state.column_1[0], state.column_2[0], state.column_3[0]);
        rows[1] = _bytes1ToBytes4(state.column_1[1], state.column_2[1], state.column_3[1], state.column_0[1]);
        rows[2] = _bytes1ToBytes4(state.column_2[2], state.column_3[2], state.column_0[2], state.column_1[2]);
        rows[3] = _bytes1ToBytes4(state.column_3[3], state.column_0[3], state.column_1[3], state.column_2[3]);
        state.column_0 = _bytes1ToBytes4(rows[0][0], rows[1][0], rows[2][0], rows[3][0]);
        state.column_1 = _bytes1ToBytes4(rows[0][1], rows[1][1], rows[2][1], rows[3][1]);
        state.column_2 = _bytes1ToBytes4(rows[0][2], rows[1][2], rows[2][2], rows[3][2]);
        state.column_3 = _bytes1ToBytes4(rows[0][3], rows[1][3], rows[2][3], rows[3][3]);
        return state;
    }

    /// @notice Mix the columns of the state
    /// @param state The state to mix
    /// @return The mixed state
    function mixColumns(AESState memory state) public pure returns (AESState memory) {
        state.column_0 = _mixColumn(state.column_0);
        state.column_1 = _mixColumn(state.column_1);
        state.column_2 = _mixColumn(state.column_2);
        state.column_3 = _mixColumn(state.column_3);
        return state;
    }

    /// @notice Mix the column of the state
    /// @param column The column to mix
    /// @return The mixed column
    /// ┌                       ┐
    /// │ 2a₀ + 3a₁ + 1a₂ + 1a₃ │
    /// │ 1a₀ + 2a₁ + 3a₂ + 1a₃ │
    /// │ 1a₀ + 1a₁ + 2a₂ + 3a₃ │
    /// │ 3a₀ + 1a₁ + 1a₂ + 2a₃ │
    /// └                       ┘
    function _mixColumn(bytes4 column) internal pure returns (bytes4) {
        bytes1 a0 = mul_by_2[uint8(column[0])] ^ mul_by_3[uint8(column[1])] ^ column[2] ^ column[3];
        bytes1 a1 = column[0] ^ mul_by_2[uint8(column[1])] ^ mul_by_3[uint8(column[2])] ^ column[3];
        bytes1 a2 = column[0] ^ column[1] ^ mul_by_2[uint8(column[2])] ^ mul_by_3[uint8(column[3])];
        bytes1 a3 = mul_by_3[uint8(column[0])] ^ column[1] ^ column[2] ^ mul_by_2[uint8(column[3])];
        return _bytes1ToBytes4(a0, a1, a2, a3);
    }

    /// @notice Add the round key to the state
    /// @param state The state to add the round key to
    /// @param round_key The round key to add
    /// @return The state with the round key added
    function addRoundKey(AESState memory state, bytes16 round_key) public pure returns (AESState memory) {
        bytes4 round_key_col_0 = bytes4(round_key);
        bytes4 round_key_col_1 = bytes4(round_key << 32);
        bytes4 round_key_col_2 = bytes4(round_key << 64);
        bytes4 round_key_col_3 = bytes4(round_key << 96);
        state.column_0 = state.column_0 ^ round_key_col_0;
        state.column_1 = state.column_1 ^ round_key_col_1;
        state.column_2 = state.column_2 ^ round_key_col_2;
        state.column_3 = state.column_3 ^ round_key_col_3;
        return state;
    }

    /// @notice Encrypt the plaintext using the key
    /// @param key The key to encrypt the plaintext with
    /// @param plaintext The plaintext to encrypt
    /// @return The encrypted plaintext
    /// Step 1: Add the round key to the plaintext
    /// Step 2: 9 times do the following:
    ///     Step 2.1: SubBytes
    ///     Step 2.2: ShiftRows
    ///     Step 2.3: MixColumns
    ///     Step 2.4: AddRoundKey (with the corresponding round key)
    /// Step 3: Like step 2 but without MixColumns
    function encrypt(bytes16 key, bytes16 plaintext) public pure returns (bytes memory) {
        // Step 1
        AESState memory state = AESState(
            _bytes1ToBytes4(plaintext[0], plaintext[1], plaintext[2], plaintext[3]),
            _bytes1ToBytes4(plaintext[4], plaintext[5], plaintext[6], plaintext[7]),
            _bytes1ToBytes4(plaintext[8], plaintext[9], plaintext[10], plaintext[11]),
            _bytes1ToBytes4(plaintext[12], plaintext[13], plaintext[14], plaintext[15])
        );
        bytes4[] memory round_keys = keyExpansion(key);
        bytes16 round_key = _bytes4ToBytes16(round_keys[0], round_keys[1], round_keys[2], round_keys[3]);
        state = addRoundKey(state, round_key);

        // Step 2
        for (uint8 i = 1; i < 10; i++) {
            state = subBytes(state);
            state = shiftRows(state);
            state = mixColumns(state);
            round_key =
                _bytes4ToBytes16(round_keys[i * 4], round_keys[i * 4 + 1], round_keys[i * 4 + 2], round_keys[i * 4 + 3]);
            state = addRoundKey(state, round_key);
        }

        // Step 3
        state = subBytes(state);
        state = shiftRows(state);
        round_key = _bytes4ToBytes16(round_keys[40], round_keys[41], round_keys[42], round_keys[43]);
        state = addRoundKey(state, round_key);
        return abi.encodePacked(state.column_0, state.column_1, state.column_2, state.column_3);
    }

    function _bytes4ToBytes16(bytes4 key0, bytes4 key1, bytes4 key2, bytes4 key3) public pure returns (bytes16) {
        return bytes16(
            (uint128(uint32(key0)) << 96) | (uint128(uint32(key1)) << 64) | (uint128(uint32(key2)) << 32)
                | uint128(uint32(key3))
        );
    }
}
