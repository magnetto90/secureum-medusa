// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SignedWadMath} from "./SignedWadMath.sol";
import "./helper.sol";

// Run with medusa fuzz --target contracts/SignedWadMathTest.sol --deployment-order SignedWadMathTest

contract SignedWadMathTest is PropertiesAsserts {
    using SignedWadMath for uint256;
    using SignedWadMath for int256;

    // The following is an example of invariant
    // It test that if x < 1e18
    // Then x <= uint(toWadUnsafe(x))
    function testtoWadUnsafe(uint256 x) public {
        x = clampLte(x, 1e18);

        int256 y = x.toWadUnsafe();

        // Ensure that x <= uint(y)
        assertLte(x, uint256(y), "X should be less or equal to Y");
    }

    function testtoDaysWadUnsafe(uint256 sec) public {
        sec = clampBetween(sec, 1, 356 days);

        int256 _days = sec.toDaysWadUnsafe() / 1e18;

        assertLt(uint256(_days), sec, "Days should be less than seconds");
    }

    function testfromDaysWadUnsafe(int256 _days) public {
        _days = clampBetween(_days, 1e18, 356e18);

        uint256 sec = _days.fromDaysWadUnsafe() * 1e18;

        assertLt(uint256(_days), sec, "Seconds should be more than days");
    }

    function testunsafeWadMul(int256 x, int256 y) public {
        //clamping to avoid overflow
        x = clampBetween(x, 1e18, 100e18);
        y = clampBetween(y, 1e18, 100e18);

        int256 mul_one = x.unsafeWadMul(x) + x.unsafeWadMul(y);
        int256 mul_two = x.unsafeWadMul(x + y);

        //Deal with precision loss, +/- 1 tolerance.
        assertLte(abs(mul_one - mul_two), 1, "UnsafeWadMul should be distributive");

        //Positive number multiplied by negative number is negative or 0
        assertLte(x.unsafeWadMul(-y), 0, "UnsafeWadMul should be negative");
    }

    function testwadMul(int256 x, int256 y) public {
        //Known issue:
        // x = -1 && y = -57896044618658097711785492504343953926634992332820282019728792003956564819967
        // So...
        if (x == -1 && y == -57896044618658097711785492504343953926634992332820282019728792003956564819967) {
            return;
        }
        
        int256 mul_one = x.wadMul(x) + x.wadMul(y);
        int256 mul_two = x.wadMul(x + y);

        //Deal with precision loss, +/- 1 tolerance.
        assertLte(abs(mul_one - mul_two), 1, "WadMul should be distributive");

        //Positive number multiplied by negative number is negative or 0
        assertLte(x.wadMul(-x), 0, "WadMul should be negative");
    }

    function testunsafeWadDiv(int256 x) public {
        x = clampBetween(x, 1e18, 100e18);

        // x divided by 1 is x
        assertEq(x.unsafeWadDiv(1e18), x, "UnsafeWadDiv should be identity");

        // 0 divided by x is 0
        assertEq(int256(0).unsafeWadDiv(x), 0, "UnsafeWadDiv should be zero");

        // x divided by x is 1
        assertEq(x.unsafeWadDiv(x), 1e18, "UnsafeWadDiv should be one");
    }

    function testwadDiv(int256 x, int256 y) public {
        // x divided by 1 is x
        assertEq(x.wadDiv(1e18), x, "wadDiv should be identity");

        // 0 divided by x is 0
        assertEq(int256(0).wadDiv(x), 0, "wadDiv should be zero");

        // x divided by x is 1
        assertEq(x.wadDiv(x), 1e18, "wadDiv should be one");

        // when y >= 1, x / y <= |x|
        y = clampGte(y, 1e18);
        assertLte(x.wadDiv(y), abs(x), "wadDiv should be less or equal to the absolut value of x");
    }

    function testwadPow(int256 x) public {
        x = clampGte(x, 1e18);

        int256 pow = x.wadPow(3e18);
        int256 mul = x.wadMul(x.wadMul(x));

        //verify that the difference between pow and mul is less than 0.00001%
        assertLte(abs(pow - mul), pow / 1e7, "WadPow should be equal to the sucessive multiplication");

        // verify that x ** 1 = x, tolerance of 0.00001%
        assertLte(x.wadPow(1e18) - x, x / 1e7, "WadPow should be identity");
    }

    function testSquareOfABinomial(int256 x, int256 y) public {
        //clamping cause wadPow does not work with negative numbers
        x = clampGte(x, 1e18);
        y = clampGte(y, 1e18);

        // square of a binomial
        int256 sb = (x + y).wadPow(2e18);
        // expansion of a square of a binomial
        int256 esb = x.wadPow(2e18) + int256(2e18).wadMul(x.wadMul(y)) + y.wadPow(2e18);

        //verify that the difference between sb and esb is less than 0.00001%
        assertLte(abs(sb - esb), sb / 1e7, "Square of a binomial should be equal to its expansion");
    }

    function testwadExp(int256 x) public {
        x = clampLte(x, -42139678854452767551);

        // verify that e ** x is 0 due to contract design
        assertEq(x.wadExp(), 0, "WadExp should be zero");
    }

    function testwadLn(int256 x, int256 y) public {
        x = clampGt(x, 1e18);
        y = clampGt(y, 1e18);

        // verify that ln(x * y) = ln(x) + ln(y)
        int256 ln_one = x.wadMul(y).wadLn();
        int256 ln_two = x.wadLn() + y.wadLn();
        // tolerance of 2
        assertLte(abs(ln_one - ln_two), 2, "WadLn should be distributive");
    }

    //Aux functions
    function abs(int256 x) internal pure returns (int256) {
        return x >= 0 ? x : -x;
    }
}
