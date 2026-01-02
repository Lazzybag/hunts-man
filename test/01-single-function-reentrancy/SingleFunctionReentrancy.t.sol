// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/01-single-function-reentrancy/VulnerableBank.sol";
import "../../src/01-single-function-reentrancy/Attacker.sol";

contract SingleFunctionReentrancyTest is Test {
    VulnerableBank public bank;
    Attacker public attacker;
    address public user1;
    address public user2;

    function setUp() public {
        bank = new VulnerableBank();
        attacker = new Attacker(address(bank));
        
        user1 = address(0x1);
        user2 = address(0x2);
        
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(address(attacker), 10 ether);
    }

    function testReentrancyExploit() public {
        // Setup: Users deposit funds
        vm.prank(user1);
        bank.deposit{value: 5 ether}();
        
        vm.prank(user2);
        bank.deposit{value: 5 ether}();
        
        uint256 bankBalanceBefore = address(bank).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        
        console.log("=== Before Attack ===");
        console.log("Bank balance:", bankBalanceBefore);
        console.log("Attacker balance:", attackerBalanceBefore);
        
        // Execute attack
        attacker.attack{value: 1 ether}();
        
        uint256 bankBalanceAfter = address(bank).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        
        console.log("\n=== After Attack ===");
        console.log("Bank balance:", bankBalanceAfter);
        console.log("Attacker balance:", attackerBalanceAfter);
        console.log("Attack count:", attacker.attackCount());
        console.log("Stolen amount:", attackerBalanceAfter - attackerBalanceBefore);
        
        // Assertions
        assertTrue(bankBalanceAfter < bankBalanceBefore, "Bank should lose funds");
        assertTrue(attackerBalanceAfter > attackerBalanceBefore, "Attacker should gain funds");
        assertGt(attacker.attackCount(), 0, "Reentrancy should occur");
    }
}
