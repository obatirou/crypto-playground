// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {AES} from "src/BlockBreakers/AES.sol";
import {Strings2} from "test/utils/Strings2.sol";

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

contract DiffTestingAES is Test {
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
        bytes4 solidity_RotWord = aes.RotWord(word);
        bytes4 python_RotWord = call_python("RotWord", word);
        bytes4 rust_RotWord = call_rust("RotWord", word);

        assertEq(solidity_RotWord, python_RotWord);
        assertEq(solidity_RotWord, rust_RotWord);
    }

    function testFuzz_SubWord(bytes4 word) public {
        bytes4 solidity_SubWord = aes.SubWord(word);
        bytes4 python_SubWord = call_python("SubWord", word);
        bytes4 rust_SubWord = call_rust("SubWord", word);

        assertEq(solidity_SubWord, python_SubWord);
        assertEq(solidity_SubWord, rust_SubWord);
    }
}
