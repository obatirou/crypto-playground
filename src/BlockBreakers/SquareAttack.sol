// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AES} from "src/BlockBreakers/AES.sol";
import {console} from "forge-std/console.sol";

contract SquareAttack is AES {
    function encrypt(bytes16 key, bytes16 plaintext, uint256 round)
        public
        pure
        returns (bytes memory)
    {
        // Step 1
        AESState memory state = AESState(
            _bytes1ToBytes4(plaintext[0], plaintext[1], plaintext[2], plaintext[3]),
            _bytes1ToBytes4(plaintext[4], plaintext[5], plaintext[6], plaintext[7]),
            _bytes1ToBytes4(plaintext[8], plaintext[9], plaintext[10], plaintext[11]),
            _bytes1ToBytes4(plaintext[12], plaintext[13], plaintext[14], plaintext[15])
        );
        bytes4[] memory round_keys = keyExpansion(key);
        bytes16 round_key =
            _bytes4ToBytes16(round_keys[0], round_keys[1], round_keys[2], round_keys[3]);
        state = addRoundKey(state, round_key);

        // Step 2
        for (uint8 i = 1; i < round; i++) {
            state = subBytes(state);
            state = shiftRows(state);
            state = mixColumns(state);
            round_key = _bytes4ToBytes16(
                round_keys[round * 4],
                round_keys[round * 4 + 1],
                round_keys[round * 4 + 2],
                round_keys[round * 4 + 3]
            );
            state = addRoundKey(state, round_key);
        }

        // Step 3
        state = subBytes(state);
        state = shiftRows(state);
        round_key = _bytes4ToBytes16(
            round_keys[round * 4],
            round_keys[round * 4 + 1],
            round_keys[round * 4 + 2],
            round_keys[round * 4 + 3]
        );
        state = addRoundKey(state, round_key);
        return abi.encodePacked(state.col0, state.col1, state.col2, state.col3);
    }

    function setup(bytes16 key, uint256 round) public pure returns (bytes16[] memory) {
        bytes16[] memory ciphertexts = new bytes16[](256);
        for (uint256 i = 0; i < 256; i++) {
            bytes16 plaintext = bytes16(bytes1(uint8(i)));
            bytes memory ciphertext = encrypt(key, plaintext, round);
            ciphertexts[i] = bytes16(bytes32(ciphertext));
        }
        return ciphertexts;
    }
}
