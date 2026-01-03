// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/02-cross-function-reentrancy/VulnerableVault.sol";
import "../../src/02-cross-function-reentrancy/Attacker.sol";

contract CrossFunctionReentrancyTest is Test {
    VulnerableVault public vault;
    Attacker public attacker;
    address public accomplice;
    address public user1;
    address public user2;

    function setUp() public {
        vault = new VulnerableVault();
        accomplice = address(0x999);
        attacker = new Attacker(address(vault), accomplice);
        
        user1 = address(0x1);
        user2 = address(0x2);
        
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(address(attacker), 10 ether);
    }

    function testCrossFunctionReentrancy() public {
        // Setup: Users deposit funds
        vm.prank(user1);
        vault.deposit{value: 5 ether}();
        
        vm.prank(user2);
        vault.deposit{value: 5 ether}();
        
        uint256 vaultBalanceBefore = address(vault).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 accompliceBalanceBefore = accomplice.balance;
        
        console.log("=== Before Attack ===");
        console.log("Vault balance:", vaultBalanceBefore);
        console.log("Attacker balance:", attackerBalanceBefore);
        console.log("Accomplice balance:", accompliceBalanceBefore);
        
        // Execute attack
        attacker.attack{value: 1 ether}();
        
        uint256 vaultBalanceAfter = address(vault).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 accompliceBalanceAfter = accomplice.balance;
        
        console.log("\n=== After Attack ===");
        console.log("Vault balance:", vaultBalanceAfter);
        console.log("Attacker balance:", attackerBalanceAfter);
        console.log("Accomplice balance:", accompliceBalanceAfter);
        console.log("Total stolen:", (attackerBalanceAfter - attackerBalanceBefore) + accompliceBalanceAfter);
        
        // Assertions
        assertTrue(vaultBalanceAfter < vaultBalanceBefore, "Vault should lose funds");
        assertTrue(attackerBalanceAfter > attackerBalanceBefore, "Attacker should gain funds");
        assertGt(accompliceBalanceAfter, 0, "Accomplice should receive transferred funds");
        assertEq(attacker.attackStep(), 1, "Attack should progress through steps");
    }
}
