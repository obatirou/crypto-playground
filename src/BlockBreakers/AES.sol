// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

// https://davidwong.fr/blockbreakers/aes.html

import "forge-std/console.sol";

contract AES {
    // @notice The s-box is a lookup table that maps each byte to its corresponding value
    bytes constant s_box =
        hex"637c777bf26b6fc53001672bfed7ab76ca82c97dfa5947f0add4a2af9ca472c0b7fd9326363ff7cc34a5e5f171d8311504c723c31896059a071280e2eb27b27509832c1a1b6e5aa0523bd6b329e32f8453d100ed20fcb15b6acbbe394a4c58cfd0efaafb434d338545f9027f503c9fa851a3408f929d38f5bcb6da2110fff3d2cd0c13ec5f974417c4a77e3d645d197360814fdc222a908846eeb814de5e0bdbe0323a0a4906245cc2d3ac629195e479e7c8376d8dd54ea96c56f4ea657aae08ba78252e1ca6b4c6e8dd741f4bbd8b8a703eb5664803f60e613557b986c11d9ee1f8981169d98e949b1e87e9ce5528df8ca1890dbfe6426841992d0fb054bb16";

    // @notice The round constant is a lookup table that maps each round to its corresponding value
    // See AESUtils.py for explanation: calculate_r_con(256)
    bytes constant r_con =
        hex"8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d01020408102040801b366cd8ab4d9a2f5ebc63c697356ad4b37dfaefc5913972e4d3bd61c29f254a943366cc831d3a74e8cb8d";

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
}
