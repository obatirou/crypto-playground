// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AES} from "src/BlockBreakers/AES.sol";
import {Strings2} from "test/BlockBreakers/utils/Strings2.sol";

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract TestAES is Test {
    AES aes;

    function setUp() public {
        aes = new AES();
    }

    function test_rotWord() public {
        bytes4 word = bytes4(0x12345678);
        bytes4 rotWord = aes.rotWord(word);
        assertEq(rotWord, bytes4(0x34567812));
    }

    function test_subWord() public {
        bytes4 word = bytes4(0x68d6a2a8);
        bytes4 subWord = aes.subWord(word);
        assertEq(subWord, bytes4(0x45f63ac2));
    }

    function test_rcon() public {
        bytes4 rcon = aes.rcon(3);
        assertEq(rcon, bytes4(0x04000000));
    }

    function test_KeyExpansion() public {
        bytes16 key = bytes16(0x2b7e151628aed2a6abf7158809cf4f3c);
        bytes4[] memory round_keys = aes.KeyExpansion(key);
        assertEq(round_keys.length, 44);
        assertEq(round_keys[0], bytes4(0x2b7e1516));
        assertEq(round_keys[1], bytes4(0x28aed2a6));
        assertEq(round_keys[2], bytes4(0xabf71588));
        assertEq(round_keys[3], bytes4(0x09cf4f3c));
        assertEq(round_keys[4], bytes4(0xa0fafe17));
        assertEq(round_keys[5], bytes4(0x88542cb1));
        assertEq(round_keys[6], bytes4(0x23a33939));
        assertEq(round_keys[7], bytes4(0x2a6c7605));
        assertEq(round_keys[8], bytes4(0xf2c295f2));
        assertEq(round_keys[9], bytes4(0x7a96b943));
        assertEq(round_keys[10], bytes4(0x5935807a));
        assertEq(round_keys[11], bytes4(0x7359f67f));
        assertEq(round_keys[12], bytes4(0x3d80477d));
        assertEq(round_keys[13], bytes4(0x4716fe3e));
        assertEq(round_keys[14], bytes4(0x1e237e44));
        assertEq(round_keys[15], bytes4(0x6d7a883b));
        assertEq(round_keys[16], bytes4(0xef44a541));
        assertEq(round_keys[17], bytes4(0xa8525b7f));
        assertEq(round_keys[18], bytes4(0xb671253b));
        assertEq(round_keys[19], bytes4(0xdb0bad00));
        assertEq(round_keys[20], bytes4(0xd4d1c6f8));
        assertEq(round_keys[21], bytes4(0x7c839d87));
        assertEq(round_keys[22], bytes4(0xcaf2b8bc));
        assertEq(round_keys[23], bytes4(0x11f915bc));
        assertEq(round_keys[24], bytes4(0x6d88a37a));
        assertEq(round_keys[25], bytes4(0x110b3efd));
        assertEq(round_keys[26], bytes4(0xdbf98641));
        assertEq(round_keys[27], bytes4(0xca0093fd));
        assertEq(round_keys[28], bytes4(0x4e54f70e));
        assertEq(round_keys[29], bytes4(0x5f5fc9f3));
        assertEq(round_keys[30], bytes4(0x84a64fb2));
        assertEq(round_keys[31], bytes4(0x4ea6dc4f));
        assertEq(round_keys[32], bytes4(0xead27321));
        assertEq(round_keys[33], bytes4(0xb58dbad2));
        assertEq(round_keys[34], bytes4(0x312bf560));
        assertEq(round_keys[35], bytes4(0x7f8d292f));
        assertEq(round_keys[36], bytes4(0xac7766f3));
        assertEq(round_keys[37], bytes4(0x19fadc21));
        assertEq(round_keys[38], bytes4(0x28d12941));
        assertEq(round_keys[39], bytes4(0x575c006e));
        assertEq(round_keys[40], bytes4(0xd014f9a8));
        assertEq(round_keys[41], bytes4(0xc9ee2589));
        assertEq(round_keys[42], bytes4(0xe13f0cc8));
        assertEq(round_keys[43], bytes4(0xb6630ca6));
    }

    function test_subBytes() public {
        AES.AESState memory state = AES.AESState({
            column_0: bytes4(0x00010203),
            column_1: bytes4(0x04050607),
            column_2: bytes4(0x08090a0b),
            column_3: bytes4(0x0c0d0e0f)
        });
        AES.AESState memory aesState = aes.subBytes(state);
        assertEq(aesState.column_0, bytes4(0x637c777b));
        assertEq(aesState.column_1, bytes4(0xf26b6fc5));
        assertEq(aesState.column_2, bytes4(0x3001672b));
        assertEq(aesState.column_3, bytes4(0xfed7ab76));
    }

    function test_shiftRows() public {
        AES.AESState memory state = AES.AESState({
            column_0: bytes4(0x637c777b),
            column_1: bytes4(0xf26b6fc5),
            column_2: bytes4(0x3001672b),
            column_3: bytes4(0xfed7ab76)
        });
        state = aes.shiftRows(state);
        assertEq(state.column_0, bytes4(0x636b6776));
        assertEq(state.column_1, bytes4(0xf201ab7b));
        assertEq(state.column_2, bytes4(0x30d777c5));
        assertEq(state.column_3, bytes4(0xfe7c6f2b));
    }

    function test_mixColumns() public {
        AES.AESState memory state = AES.AESState({
            column_0: bytes4(0x636b6776),
            column_1: bytes4(0xf201ab7b),
            column_2: bytes4(0x30d777c5),
            column_3: bytes4(0xfe7c6f2b)
        });
        state = aes.mixColumns(state);
        assertEq(state.column_0, bytes4(0x6a6a5c45));
        assertEq(state.column_1, bytes4(0x2c6d3351));
        assertEq(state.column_2, bytes4(0xb0d95d61));
        assertEq(state.column_3, bytes4(0x279c215c));
    }

    function test_addRoundKey() public {
        AES.AESState memory state = AES.AESState({
            column_0: bytes4(0x6a6a5c45),
            column_1: bytes4(0x2c6d3351),
            column_2: bytes4(0xb0d95d61),
            column_3: bytes4(0x279c215c)
        });
        bytes16 round_key = bytes16(0xd6aa74fdd2af72fadaa678f1d6ab76fe);
        state = aes.addRoundKey(state, round_key);
        assertEq(state.column_0, bytes4(0xbcc028b8));
        assertEq(state.column_1, bytes4(0xfec241ab));
        assertEq(state.column_2, bytes4(0x6a7f2590));
        assertEq(state.column_3, bytes4(0xf13757a2));
    }

    function test_encrypt() public {
        bytes16 plaintext = bytes16(0x746865626c6f636b627265616b657273);
        bytes16 key = bytes16(0x2b7e151628aed2a6abf7158809cf4f3c);
        bytes memory ciphertext = aes.encrypt(key, plaintext);
        bytes memory expected = hex"c69f25d0025a9ef32393f63e2f05b747";
        assertEq(ciphertext, expected);
    }
}
