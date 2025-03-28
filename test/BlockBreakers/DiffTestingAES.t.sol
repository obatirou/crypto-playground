// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AES} from "src/BlockBreakers/AES.sol";
import {Strings2} from "test/BlockBreakers/utils/Strings2.sol";

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract DiffTestingAES is Test {
    using {Strings2.toHexString} for bytes;

    AES aes;

    function setUp() public {
        aes = new AES();
    }

    function call_python(string memory func_name, bytes memory input) public returns (bytes memory) {
        string[] memory inputs = new string[](4);
        inputs[0] = "python";
        inputs[1] = "test/BlockBreakers/AES.py";
        inputs[2] = func_name;
        inputs[3] = input.toHexString();
        bytes memory result = vm.ffi(inputs);
        return result;
    }

    function call_rust(string memory func_name, bytes memory input) public returns (bytes memory) {
        string[] memory inputs = new string[](3);
        inputs[0] = "rust/target/release/rust";
        inputs[1] = func_name;
        inputs[2] = input.toHexString();
        bytes memory result = vm.ffi(inputs);
        return result;
    }

    function testFuzz_RotWord(bytes4 word) public {
        bytes4 solidity_RotWord = aes.RotWord(word);
        bytes memory python_RotWord = call_python("RotWord", abi.encode(word));
        bytes memory rust_RotWord = call_rust("RotWord", abi.encode(word));

        assertEq(solidity_RotWord, abi.decode(python_RotWord, (bytes4)));
        assertEq(solidity_RotWord, abi.decode(rust_RotWord, (bytes4)));
    }

    function testFuzz_SubWord(bytes4 word) public {
        bytes4 solidity_SubWord = aes.SubWord(word);
        bytes memory python_SubWord = call_python("SubWord", abi.encode(word));
        bytes memory rust_SubWord = call_rust("SubWord", abi.encode(word));

        assertEq(solidity_SubWord, abi.decode(python_SubWord, (bytes4)));
        assertEq(solidity_SubWord, abi.decode(rust_SubWord, (bytes4)));
    }

    function testFuzz_RCon(uint256 round) public {
        round = bound(round, 0, 255);
        bytes4 solidity_RCon = aes.RCon(round);
        for (uint256 i = 1; i < 4; i++) {
            assertEq(solidity_RCon[i], 0);
        }

        bytes memory python_RCon = call_python("RCon", abi.encode(round));
        bytes memory rust_RCon = call_rust("RCon", abi.encode(round));

        uint256 solidity_res = uint256(uint8(solidity_RCon[0]));
        assertEq(solidity_res, abi.decode(python_RCon, (uint256)));
        assertEq(solidity_res, abi.decode(rust_RCon, (uint256)));
    }
}
