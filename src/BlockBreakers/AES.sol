// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

// https://davidwong.fr/blockbreakers/aes.html

contract AES {
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
}
