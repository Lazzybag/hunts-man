// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableVault {
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasWithdrawn;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "Insufficient balance");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");

        // VULNERABILITY: External call before state update
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // State update happens AFTER external call
        balances[msg.sender] = 0;
        hasWithdrawn[msg.sender] = true;
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // VULNERABILITY: Updates sender but not hasWithdrawn flag
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
