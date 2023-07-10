# Warroom ETHCC 2023

Repository for the Warroom ETHCC 2023. The goal of this project is to create four task to be solved by the participants of the Warroom.

## Tasks

### Task 4 - Metamorphic

The goal of this task is to see if the users can recognize that Multiply contract is deployed using Metamorphic factory. The user will see the verified contract on Etherscan of `Multiply.sol` contract and some funds on the contract. The idea is to trick the user to approve Multiply contract to spend their tokens for small multiplication of tokens he gets in return. After the user has approved tokens, we can destroy the current contract and deploy a new one with different logic, Multiply2.sol, but it will still have an allowance from the user. With new logic we can steal all allowed tokens from the user. Check out test [MultiplierRug.t.sol](./test/metamorphic/MultiplerRug.t.sol) for more details.

One thing to mention is that this should be the last task, so we can put on a bit of show, and steal funds after the time is up. Also, the final score should be counted in ERC20 token, not in ETH because we need allowance on token.

## Deploy

Create `.env` file, see `.env.example` for reference. Then run:

```bash
source .env
```

### Metamorphic

To deploy Metamorphic factory and initial Multiply contract run script:

```bash
forge script script/Metamorphic.s.sol:Metamorphic --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

To destroy Multiply contract run script:

```bash
forge script script/Metamorphic.s.sol:MetamorphicDestroy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

To deploy new Multiply contract run script:

```bash
forge script script/Metamorphic.s.sol:MetamorphicDeployNew --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```
