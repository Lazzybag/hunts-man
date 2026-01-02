// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");

        // VULNERABILITY: External call before state update
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // State update happens AFTER external call
        balances[msg.sender] = 0;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
