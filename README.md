# Hunts-Man: Reentrancy Exploit Templates

A collection of Foundry-based POC templates for various reentrancy attack patterns.

## Templates

### 01. Single-Function Reentrancy
Classic reentrancy where the same function is called recursively before state updates.

**Pattern**: External call → Reenter same function → State update

## Setup

```bash
forge install
forge build
Run Tests
# Test single-function reentrancy
forge test --match-path test/01-single-function-reentrancy/SingleFunctionReentrancy.t.sol -vvv

### 02. Cross-Function Reentrancy
Reentrancy across different functions sharing state, exploiting incomplete state updates.

**Pattern**: withdraw() → callback → transfer() → withdraw() again

**Run Test**:
```bash
forge test --match-path test/02-cross-function-reentrancy/CrossFunctionReentrancy.t.sol -vvv
