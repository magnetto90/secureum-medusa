// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";
import "./helper.sol";

// Run with medusa fuzz --target contracts/FixedPointMathLibTest.sol --deployment-order FixedPointMathLibTest

contract FixedPointMathLibTest is PropertiesAsserts {
    using FixedPointMathLib for uint256;

    // The following is an example of invariant
    // It test that if z = x / y, then z <= x
    // For any x and y greater than 1 unit
    function testmulDivDown(uint256 x, uint256 y) public {
        // We work with a decimals of 18
        uint256 decimals = 1e18;

        // Ensure x and y are geater than 1
        x = clampGte(x, decimals);
        y = clampGte(y, decimals);

        // compute z = x / y
        uint256 z = x.mulDivDown(y, decimals);

        // Ensure that z <= x
        assertLte(z, x, "Z should be less or equal to X");

        // Ensure that x / 1 = x
        assertEq(x.mulDivDown(1e18, decimals), x, "X / 1 should be X");

        // Ensure that x / x = 1
        assertEq(x.mulDivDown(x, decimals), 1e18, "X / X should be 1");
    }

    function testmulDivUp(uint256 x, uint256 y) public {
        // We work with a decimals of 18
        uint256 decimals = 1e18;

        // Ensure x and y are geater than 1
        x = clampGte(x, decimals);
        y = clampGte(y, decimals);

        // compute z = x / y
        uint256 z = x.mulDivUp(y, decimals);

        // Ensure that z <= x
        assertLte(z, x, "Z should be less or equal to X");

        // Ensure that x / 1 = x
        assertEq(x.mulDivUp(1e18, decimals), x, "X / 1 should be X");

        // Ensure that x / x = 1
        assertEq(x.mulDivUp(x, decimals), 1e18, "X / X should be 1");
    }
}
