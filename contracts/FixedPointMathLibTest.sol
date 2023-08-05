// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";
import "./helper.sol";
import "./IVM.sol";

// Run with medusa fuzz --target contracts/FixedPointMathLibTest.sol --deployment-order FixedPointMathLibTest

contract FixedPointMathLibTest is PropertiesAsserts {
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    uint256 constant WAD = 1e18;
    uint256 constant ZERO = 0;

    using FixedPointMathLib for uint256;

    function test_divWad_properties(uint256 a) public {
        // Ensure that x / 1 = x
        assertEq(a.divWadDown(WAD), a, "a / 1 should be a");
        assertEq(a.divWadUp(WAD), a, "a / 1 should be a");

        // Ensure that x / x = 1
        assertEq(a.divWadDown(a), WAD, "a / a should be 1");
        assertEq(a.divWadUp(a), WAD, "a / a should be 1");

        // Ensure that 0 / x = 0
        assertEq(ZERO.divWadDown(a), 0, "0 / a should be 0");
        assertEq(ZERO.divWadUp(a), 0, "0 / a should be 0");
    }

    function test_divWadUp_gte_divWadDown(uint256 a, uint256 b) public {
        assertGte(a.divWadUp(b), a.divWadDown(b), "a / b should be >= a / b");
    }

    function test_divWadDown_equivalentFractions(uint256 a, uint256 b) public {
        assertEq(a.divWadDown(b), (a * 2).divWadDown(b * 2), "a / b should be (a * WAD) / (b * WAD)");
    }
}
