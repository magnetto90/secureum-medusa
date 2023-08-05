// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./ERC20Burn.sol";
import "./helper.sol";

// Run with medusa fuzz --target contracts/ERC20Test.sol --deployment-order MyToken

contract MyToken is ERC20Burn, PropertiesAsserts {
    // Test that the total supply is always below or equal to 10**18
    function fuzz_Supply() public view returns (bool) {
        return totalSupply <= 10 ** 18;
    }

    function fuzz_UserBalance() public view returns (bool) {
        return balanceOf[msg.sender] <= 10 ** 18;
    }

    function test_transferBalance(uint256 amount) public {
        uint256 balanceBefore = balanceOf[msg.sender];
        amount = clampLte(amount, balanceBefore);
        transfer(address(4), amount);
        assert(balanceOf[msg.sender] == balanceBefore - amount);
    }
}
