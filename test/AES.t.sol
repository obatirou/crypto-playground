// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AES} from "src/BlockBreakers/AES.sol";
import {Strings2} from "test/utils/Strings2.sol";

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract AESTest is Test {
    using {Strings2.toHexString} for bytes;

    AES aes;

    function setUp() public {
        aes = new AES();
    }

    function call_python(string memory func_name, bytes4 word) public returns (bytes4) {
        bytes memory word_input = abi.encode(word);
        string[] memory inputs = new string[](4);
        inputs[0] = "python";
        inputs[1] = "test/AES.py";
        inputs[2] = func_name;
        inputs[3] = word_input.toHexString();
        bytes memory result = vm.ffi(inputs);
        return abi.decode(result, (bytes4));
    }

    function call_rust(string memory func_name, bytes4 word) public returns (bytes4) {
        bytes memory word_input = abi.encode(word);
        string[] memory inputs = new string[](3);
        inputs[0] = "rust/target/release/rust";
        inputs[1] = func_name;
        inputs[2] = word_input.toHexString();
        bytes memory result = vm.ffi(inputs);
        return abi.decode(result, (bytes4));
    }

    function testFuzz_RotWord(bytes4 word) public {
        bytes4 solidity_rotword = aes.RotWord(word);
        bytes4 python_rotword = call_python("RotWord", word);
        bytes4 rust_rotword = call_rust("RotWord", word);

        assertEq(solidity_rotword, python_rotword);
        assertEq(solidity_rotword, rust_rotword);
    }
}
