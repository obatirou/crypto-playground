// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Prime Field Arithmetic
// Order of the prime field, the order is a prime number
// Addition identity: any element added to P is the element itself, (a + p) % p = a
// Addition inverse: the inverse of any element a is b such that (a + b) % p = 0
// Multiplicative inverse: the inverse of any element a is b such that (a * b) % p = 1
// Finite field operations are:
//  - associative: (a + b) + c = a + (b + c)
//  - commutative: a + b = b + a / a * b = b * a
//  - distributive: a * (b + c) = a * b + a * c
contract PrimeFieldArithmetic {
    uint256 public immutable p;

    constructor(uint256 p_) {
        require(isPrime(p_), "p must be a prime number");
        p = p_;
    }

    function isPrime(uint256 p_) public pure returns (bool) {
        if (p_ < 2) return false;
        if (p_ % 2 == 0) return p_ == 2;
        for (uint256 i = 3; i <= p_ / i; i += 2) {
            if (p_ % i == 0) return false;
        }
        return true;
    }

    function add(uint256 a, uint256 b) public view returns (uint256) {
        return addmod(a, b, p);
    }

    function mul(uint256 a, uint256 b) public view returns (uint256) {
        return mulmod(a, b, p);
    }

    function sub(uint256 a, uint256 b) public view returns (uint256) {
        return addmod(a, p - b, p);
    }

    // Multiplicative inverse
    // Uses Fermat's little theorem
    // a^(p-1) % p = 1
    // a^(p-2) % p = a^-1
    // Fermat's little theorem is only valid for prime fields
    // a^-1 is the multiplicative inverse of a
    function mulInv(uint256 a) public view returns (uint256) {
        require(a % p != 0, "Division by zero");
        return exp(a, p - 2);
    }

    // square-and-multiply algorithm for exponentiation
    function exp(uint256 base, uint256 exponent) public view returns (uint256) {
        uint256 result = 1;
        while (exponent > 0) {
            if (exponent % 2 == 1) {
                result = mul(result, base);
            }
            base = mul(base, base);
            exponent = exponent / 2;
        }
        return result;
    }

    function div(uint256 a, uint256 b) public view returns (uint256) {
        return mul(a, mulInv(b));
    }
}
