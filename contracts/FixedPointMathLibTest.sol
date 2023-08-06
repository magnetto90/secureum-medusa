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

    function test_divWad_equivalentFractions(uint256 a, uint256 b) public {
        assertEq(a.divWadDown(b), (a * 2).divWadDown(b * 2), "a / b should be (a * WAD) / (b * WAD)");
        assertEq(a.divWadUp(b), (a * 2).divWadUp(b * 2), "a / b should be (a * WAD) / (b * WAD)");
    }

    function test_divWad_Inverse(uint256 a, uint256 b) public {
        //Verify that a = bq
        b = clampGte(b, 1e18);
        a = clampGte(a, b); //To avoid q = 0
        uint256 q = a.divWadDown(b);
        //Verify that the precision loss is less than 0.0001%
        assertLte(a - b.mulWadDown(q), a / 10000, "a should be b * q");
    }

    function test_rationalNumbersDivition(uint256 a, uint256 b, uint256 c, uint256 d) public {
        //Verify that (a/b)/(c/d) = (a*d)/(b*c)
        b = clampGte(b, 1e18);
        d = clampGte(d, 1e18);
        a = clampGte(a, b); //To avoid quotient = 0
        c = clampGte(c, d); //To avoid quotient = 0

        uint256 qab = a.divWadDown(b);
        uint256 qcd = c.divWadDown(d);
        uint256 q1 = qab.divWadDown(qcd);

        uint256 pad = a.mulWadDown(d);
        uint256 pbc = b.mulWadDown(c);
        uint256 q2 = pad.divWadDown(pbc);

        uint256 tolerance = q1 / 1e18;

        if (q1 > q2) {
            assertLte(q1 - q2, tolerance, "q1 should be equal to q2, more or less");
        } else {
            assertLte(q2 - q1, tolerance, "q1 should be equal to q2, more or less");
        }
    }
}
