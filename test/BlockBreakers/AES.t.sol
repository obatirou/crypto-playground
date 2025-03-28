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

    function test_RotWord() public {
        bytes4 word = bytes4(0x12345678);
        bytes4 rotWord = aes.RotWord(word);
        assertEq(rotWord, bytes4(0x34567812));
    }

    function test_SubWord() public {
        bytes4 word = bytes4(0x68d6a2a8);
        bytes4 subWord = aes.SubWord(word);
        assertEq(subWord, bytes4(0x45f63ac2));
    }

    function test_Rcon() public {
        bytes4 rcon = aes.RCon(3);
        assertEq(rcon, bytes4(0x04000000));
    }
}
