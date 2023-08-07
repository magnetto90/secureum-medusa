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

    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

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

    function test_divWad_reverse(uint256 a, uint256 b) public {
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

        uint256 tolerance = q1 / 1e18 == 0 ? 1 : q1 / 1e18;

        if (q1 > q2) {
            assertLte(q1 - q2, tolerance, "q1 should be equal to q2, more or less");
        } else {
            assertLte(q2 - q1, tolerance, "q1 should be equal to q2, more or less");
        }
    }

    function test_mulWadDown(uint256 x, uint256 y) public {
        uint256 mul_one = x.mulWadDown(x) + x.mulWadDown(y);
        uint256 mul_two = x.mulWadDown(x + y);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "WadMul should be distributive");
        } else {
            assertLte(mul_two - mul_one, 1, "WadMul should be distributive");
        }
    }

    function test_mulWadUp(uint256 x, uint256 y) public {
        //Distributive property
        uint256 mul_one = x.mulWadUp(x) + x.mulWadUp(y);
        uint256 mul_two = x.mulWadUp(x + y);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "WadMul should be distributive");
        } else {
            assertLte(mul_two - mul_one, 1, "WadMul should be distributive");
        }

        //Commutative property
        mul_one = x.mulWadUp(y);
        mul_two = y.mulWadUp(x);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "WadMul should be commutative");
        } else {
            assertLte(mul_two - mul_one, 1, "WadMul should be commutative");
        }

        //Associative property
        mul_one = x.mulWadUp(y).mulWadUp(x);
        mul_two = x.mulWadUp(y.mulWadUp(x));

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "WadMul should be associative");
        } else {
            assertLte(mul_two - mul_one, 1, "WadMul should be associative");
        }
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function test_mulDivDown(uint256 x, uint256 y, uint256 denominator) public {
        //Commutative property
        uint256 mul_one = x.mulDivDown(y, denominator);
        uint256 mul_two = y.mulDivDown(x, denominator);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "mulDivDown should be commutative");
        } else {
            assertLte(mul_two - mul_one, 1, "mulDivDown should be commutative");
        }

        //Distributive property
        mul_one = x.mulDivDown(y, denominator) + x.mulDivDown(y, denominator);
        mul_two = x.mulDivDown(y + y, denominator);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "mulDivDown should be distributive");
        } else {
            assertLte(mul_two - mul_one, 1, "mulDivDown should be distributive");
        }
    }

    function test_mulDivUp(uint256 x, uint256 y, uint256 denominator) public {
        //Commutative property
        uint256 mul_one = x.mulDivUp(y, denominator);
        uint256 mul_two = y.mulDivUp(x, denominator);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "mulDivUp should be commutative");
        } else {
            assertLte(mul_two - mul_one, 1, "mulDivUp should be commutative");
        }

        //Distributive property
        mul_one = x.mulDivUp(y, denominator) + x.mulDivUp(y, denominator);
        mul_two = x.mulDivUp(y + y, denominator);

        //Deal with precision loss, +/- 1 tolerance.
        if (mul_one > mul_two) {
            assertLte(mul_one - mul_two, 1, "mulDivUp should be distributive");
        } else {
            assertLte(mul_two - mul_one, 1, "mulDivUp should be distributive");
        }
    }

    function test_rpow(uint256 x, uint256 scalar) public {
        //Verify that x^2 = x*x when n != 0
        uint256 rpow = x.rpow(2, scalar);
        uint256 mul = x.mulDivDown(x, scalar);

        if (rpow > mul) {
            assertLte(rpow - mul, 1, "x^2 should be equal to x*x, more or less");
        } else {
            assertLte(mul - rpow, 1, "x^2 should be equal to x*x, more or less");
        }
    }

    function test_rpow_xis0(uint256 n, uint256 scalar) public {
        //Verify that 0^2 = 0
        n = clampGt(n, 0);
        uint256 x = 0;
        uint256 rpow = x.rpow(n, scalar);

        assertEq(rpow, 0, "0^n should be equal to 0");
    }

    // function test_rpow_nis0(uint256 x) public {
    //     //Verify that X^0 = 1
    //     x = clampGt(x, 0);
    //     uint256 scalar = 1e18;
    //     uint256 n = 0;
    //     uint256 rpow = x.rpow(n, scalar);

    //     assertEq(rpow, 1, "x^0 should be equal to 1");
    // }

    function test_rpow_nplusm(uint256 x, uint256 n, uint256 m, uint256 scalar) public {
        x = clampGt(x, 0);
        uint256 rpow1 = x.rpow(n + m, scalar);
        uint256 rpow2 = (x.rpow(n, scalar)).mulDivUp(x.rpow(m, scalar), scalar);

        //Deal with precision loss, +/- 10% tolerance.
        if (rpow1 > rpow2) {
            assertLte(rpow1 - rpow2, (rpow1 / 10) + 1, "x^(n+m) should be equal to x^n * x^m");
        } else {
            assertLte(rpow2 - rpow1, (rpow1 / 10) + 1, "x^(n+m) should be equal to x^n * x^m");
        }
    }

    function test_sqrt(uint256 x) public {
        assertEq((x * x).sqrt(), x, "(x^2).sqrt() should be equal to x");
    }
}
