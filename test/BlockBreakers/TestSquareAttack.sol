// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {SquareAttack} from "src/BlockBreakers/SquareAttack.sol";
import {Test} from "forge-std/Test.sol";

contract TestSquareAttack is Test {
    SquareAttack squareAttack;

    function setUp() public {
        squareAttack = new SquareAttack();
    }

    function test_setup_round_3() public {
        bytes16 key = 0x000000000000000000000000000000aa;
        bytes16[] memory ciphertexts = squareAttack.setup(key, 3);
        bytes16 result = 0x00000000000000000000000000000000;
        for (uint256 i = 0; i < 256; i++) {
            result = bytes16(uint128(result) ^ uint128(ciphertexts[i]));
        }
        assertEq(result, 0x00000000000000000000000000000000);
    }
}
