# Warroom ETHCC 2023

Repository for the Warroom ETHCC 2023. The goal of this project is to create four tasks to be solved by the participants of the Warroom.

## Rules

Each team starts with 0 WAR tokens, at the end WAR tokens will count for points, the goal of most problems is to score as much points as possible. The team with the most points wins. (the proxy capture task is an exception, the winner is the last owner of the proxy, and is worth X points)

- Each task, except the first one, will have WAR tokens that can be withdraw after solving the task.
- For proxy, we will send the WAR tokens the last owner.
- After the team decides they are finished and they completed the task, they will get additional WAR tokens depending on order of completion, the first one gets more points. First place gets 13 points bonus, second place 8 points, third place 5 points, and the rest 3 points.

## Tasks

### Task 1 - Proxy capture 15 points

The goal of the task to have all participant tackling the same deployed contract. This a unique task that will be the same for every team, the winner will be the last owner of the proxy, either by having an implementation that cant be taken over or implementation having a self destruct. Goal is for users to compete who will recognize on chain that the proxy can be reinitialized. Additional, everybody should be able to take over the contract after initialization by call the same function initialize, so its a race between all the teams to take over the contract and avoid others to take it over. The end game for the user is to deploy new implementation of the proxy which will not allow new initialization and will be the final owner. To authorize upgrade, user must withdraw some funds and also whitelisted the owner. Check out test [Proxy.t.sol](./test/proxy/Proxy.t.sol#L35) for more details.

### Task 2 - Flash loan 35 points

The participant should understand the flash loan logic. Recognize that the contract is connected to Aave v3. Find on Aave v3 that he can mint for himself some tokens and send to the contract so it can execute successfully by paying the flash loan premium. The function [`addUsingFlashLoan()`](./src/flashloan/Loan.sol#L33) in Loan contract is added to misguide the user. It will increase totalLoan but not for the user as needed for task but instead to called Loan contract.

The user should use flash loan function by himself and set Loan contract as the receiver address to solve the task. Now the user has enough totalLoan to withdraw reward token from the contract by calling function [`removeLoan`](./src/flashloan/Loan.sol#L37). In flash loan function, [there is require that the contract must contain the double amount of the flash loan](./src/flashloan/Loan.sol#L47). This can be achieved by creating a contract that will take flash loan, send the amount to Loan contract and then call again pool flash loan function and set Loan contract as receiver this time. It's important that new contract calls [`removeLoan`](./src/flashloan/Loan.sol#L37) function for loaned token so it can pay off its flash loan.

To see solution, check out test [FlashLoan.t.sol](./test/flashloan/Loan.t.sol). To successfully execute the attack, the user must create additional contract that will also call flash loan. This is done in [AttackLoan.sol](./test/flashloan/AttackLoan.sol).

### Task 3 - Signature malleability 35 points

There is a contract [`WhitelistedRewards`](./src/signature/WhitelistedRewards.sol) that allows whitelisted users to withdraw rewards funds. The contract has one transaction that claimed rewards by providing the correct signature from a whitelisted address. The goal of this task is to recognize that you can provide different signature from the same address. The valid signature can be extracted by using a signature that already signed the transaction. Now the attacker can generate a new signature for the whitelisted address that signed the transaction. With a valid signature, the attacker can claim rewards from the contract. Check out test [WhitelistedRewards.t.sol](./test/signature/WhitelistedRewards.t.sol) for more details.

For more info on this read section "Signature malleability" in [RareSkills blog](https://www.rareskills.io/post/smart-contract-security). Get more info about [math on signature malleability](https://medium.com/coinmonks/ethereum-signature-malleability-explained-463f7d8d3f3f).

### Bonus Task - Metamorphic 20 points

The goal of this task is to see if the users can recognize that `Multiply` contract is deployed using `Factory`. The user will see the verified `Multiply.sol` contract on Etherscan that has some funds. The idea is to trick the user to approve `Multiply` contract to spend their tokens for a small multiplication of tokens he gets in return. After the user has approved the tokens, we can destroy the current contract and deploy a new one with a different logic, `Multiply2.sol`, but it will still have an allowance from the user. With the new logic, we can steal all allowed tokens from the user. Check out test [MultiplierRug.t.sol](./test/metamorphic/MultiplerRug.t.sol) for more details.

One thing to mention is that this should be the last task, so we can put on a bit of show, and steal funds after the time is up. Also, the final score should be counted in `ERC20` token, not in ETH because we need allowance on the token. We could create ERC20 Warroom token and see top holders for the final score.

More info about metamorphic contracts: https://proxies.yacademy.dev/pages/proxies-list/#metamorphic-contracts

## Deployment

Create `.env` file, see `.env.example` for reference. Then run:

```bash
source .env
```

### Proxy capture

To deploy proxy capture task run script:

```bash
forge script script/Proxy.s.sol:ProxyScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

### Flash loan

To deploy flash loan task run script:

```bash
forge script script/Loan.s.sol:LoanScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

### Signature malleability

To deploy Signature malleability task run script:

```bash
forge script script/Signature.s.sol:SignatureScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
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
