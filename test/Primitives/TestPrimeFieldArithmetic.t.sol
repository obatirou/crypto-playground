// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PrimeFieldArithmetic} from "src/Primitives/PrimeFIeldArithmetic.sol";
import {Test} from "forge-std/Test.sol";

contract TestPrimeFIeldArithmetic is Test {
    PrimeFieldArithmetic primeFieldArithmetic;
    uint256[] public primes = [5, 71];

    function call_python(string memory func_name, uint256 a, uint256 b, uint256 p)
        public
        returns (bytes memory)
    {
        string[] memory inputs = new string[](6);
        inputs[0] = "python";
        inputs[1] = "test/Primitives/PrimeFIeldArithmetic.py";
        inputs[2] = func_name;
        inputs[3] = vm.toString(a);
        inputs[4] = vm.toString(b);
        inputs[5] = vm.toString(p);
        bytes memory result = vm.ffi(inputs);
        return result;
    }

    function test_isPrime() public {
        for (uint256 i = 0; i < primes.length; i++) {
            uint256 p = primes[i];
            primeFieldArithmetic = new PrimeFieldArithmetic(p);
            assertEq(
                primeFieldArithmetic.isPrime(p), abi.decode(call_python("isPrime", p, 0, 0), (bool))
            );
        }
    }

    function test_isNotPrime() public {
        vm.expectRevert();
        primeFieldArithmetic = new PrimeFieldArithmetic(4);

        vm.expectRevert();
        primeFieldArithmetic = new PrimeFieldArithmetic(6);

        vm.expectRevert();
        primeFieldArithmetic = new PrimeFieldArithmetic(10);

        vm.expectRevert();
        primeFieldArithmetic = new PrimeFieldArithmetic(15);
    }

    function testDiff_add(uint256 a, uint256 b) public {
        for (uint256 i = 0; i < primes.length; i++) {
            uint256 p = primes[i];
            uint256 a_ = bound(a, 0, p);
            uint256 b_ = bound(b, 0, p);
            primeFieldArithmetic = new PrimeFieldArithmetic(p);
            bytes memory python_result = call_python("add", a_, b_, p);
            assertEq(primeFieldArithmetic.add(a_, b_), abi.decode(python_result, (uint256)));
        }
    }

    function testDiff_mul(uint256 a, uint256 b) public {
        for (uint256 i = 0; i < primes.length; i++) {
            uint256 p = primes[i];
            a = bound(a, 0, p);
            b = bound(b, 0, p);
            primeFieldArithmetic = new PrimeFieldArithmetic(p);
            bytes memory python_result = call_python("mul", a, b, p);
            assertEq(primeFieldArithmetic.mul(a, b), abi.decode(python_result, (uint256)));
        }
    }

    function testDiff_sub(uint256 a, uint256 b) public {
        for (uint256 i = 0; i < primes.length; i++) {
            uint256 p = primes[i];
            a = bound(a, 0, p);
            b = bound(b, 0, p);
            primeFieldArithmetic = new PrimeFieldArithmetic(p);
            bytes memory python_result = call_python("sub", a, b, p);
            assertEq(primeFieldArithmetic.sub(a, b), abi.decode(python_result, (uint256)));
        }
    }

    function testDiff_mulInv(uint256 a) public {
        for (uint256 i = 0; i < primes.length; i++) {
            uint256 p = primes[i];
            a = bound(a, 1, p - 1);
            primeFieldArithmetic = new PrimeFieldArithmetic(p);
            bytes memory python_result = call_python("mulInv", a, 0, p);
            assertEq(primeFieldArithmetic.mulInv(a), abi.decode(python_result, (uint256)));
        }
    }

    function testDiff_div(uint256 a, uint256 b) public {
        for (uint256 i = 0; i < primes.length; i++) {
            uint256 p = primes[i];
            a = bound(a, 0, p - 1);
            b = bound(b, 1, p - 1);
            primeFieldArithmetic = new PrimeFieldArithmetic(p);
            bytes memory python_result = call_python("div", a, b, p);
            assertEq(primeFieldArithmetic.div(a, b), abi.decode(python_result, (uint256)));
        }
    }
}
