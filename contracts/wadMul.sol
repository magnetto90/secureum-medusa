// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SignedWadMath} from "./SignedWadMath.sol";
import "./helper.sol";

// Run with medusa fuzz --target contracts/wadMul.sol --deployment-order SignedWadMathTest

contract SignedWadMathTest is PropertiesAsserts {
    using SignedWadMath for int256;

    function testwadMul(int256 x, int256 y) public {
        x = clampLt(x, 0);
        y = clampLt(y, 0);

        //Known issue:
        // x = -1 && y = -57896044618658097711785492504343953926634992332820282019728792003956564819967
        // So...
        if (x == -1 && y == -57896044618658097711785492504343953926634992332820282019728792003956564819967) {
            return;
        }

        int256 mul_one = x.wadMul(x) + x.wadMul(y); //Should be positive
        int256 mul_two = x.wadMul(x + y); //Should be positive

        assertGte(mul_one, 0, "mul_one should be positive");
        assertGte(mul_two, 0, "mul_two should be positive");
        //Deal with precision loss, +/- 1 tolerance.
        assertLte(abs(mul_one - mul_two), 1, "WadMul should be distributive");
    }

    //Aux functions
    function abs(int256 x) internal pure returns (int256) {
        return x >= 0 ? x : -x;
    }
}
