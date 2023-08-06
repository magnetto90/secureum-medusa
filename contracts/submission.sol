// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

//medusa fuzz --target contracts/submission.sol --deployment-order FixedPointMathLibTest,SignedWadMathTest,MyToken,ExternalTestingToken

import "./SignedWadMathTest.sol";
import "./FixedPointMathLibTest.sol";
import "./ERC20Test.sol";
import "./ERC20TestAdvanced.sol";
