pragma solidity 0.8.19;

import {SignedWadMath} from "./SignedWadMath.sol";
import "./helper.sol";

// Run with medusa fuzz --target contracts/Failed.sol --deployment-order SignedWadMathTest

contract SignedWadMathTest is PropertiesAsserts {
    using SignedWadMath for int256;

    function testwadMul() public {
        int256 x = -1;
        int256 y = -57896044618658097711785492504343953926634992332820282019728792003956564819967;
        int256 mul_one = x.wadMul(x) + x.wadMul(y);
        int256 mul_two = x.wadMul(x + y);

        //Deal with precision loss, +/- 1 tolerance.
        assertLte(abs(mul_one - mul_two), 1, "WadMul should be distributive");

        // [Execution Trace]
        //  => [call] SignedWadMathTest.testwadMul(-1, -57896044618658097711785492504343953926634992332820282019728792003956564819967) (addr=0xA647ff3c36cFab592509E13860ab8c4F28781a66, value=0, sender=0x0000000000000000000000000000000000030000)
        //          => [event] AssertLteFail("Invalid: 115792089237316195423570985008687907853269984665640564039456>1 failed, reason: WadMul should be distributive")
        //          => [assertion failed]
    }

    //Aux functions
    function abs(int256 x) internal pure returns (int256) {
        return x >= 0 ? x : -x;
    }
}
