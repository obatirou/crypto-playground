// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

// https://davidwong.fr/blockbreakers/aes.html

contract AES {
    // @notice The s-box is a lookup table that maps each byte to its corresponding value
    bytes constant s_box =
        hex"637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b27509832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cfd0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdbe0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9ee1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16";

    // @notice The round constant is a lookup table that maps each round to its corresponding value
    // See AESUtils.py for explanation
    bytes constant rcon =
        hex"8D01020408102040801B366CD8AB4D9A2F5EBC63C697356AD4B37DFAEFC591372E4D3BD61C29F254A943366CC831D374E8CB8D01020408102040801B366CDAB4D9A2F5EBC63C697356AD4B37DFAEC5913972E4D3BD61C29F254A943366C831D3A74E8CB8D01020408102040801366CD8AB4D9A2F5EBC63C697356AD4B7DFAEFC5913972E4D3BD61C29F254A93366CC831D3A74E8CB8D0102040810240801B366CD8AB4D9A2F5EBC63C69736AD4B37DFAEFC5913972E4D3BD61C29254A943366CC831D3A74E8CB8D0102008102040801B366CD8AB4D9A2F5EBC6C697356AD4B37DFAEFC5913972E4D3B61C29F254A943366CC831D3A74E8CB";

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
        return bytes4(uint32(uint8(rcon[round])) << 24);
    }
}
