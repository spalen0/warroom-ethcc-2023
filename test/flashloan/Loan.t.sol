pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Loan} from "../../src/flashloan/Loan.sol";
import {IPool} from "../../src/flashloan/IPool.sol";

contract LoanTest is Test {
    ERC20 public weth;
    Loan public loan;
    ERC20 public constant DAI = ERC20(0x8a0E31de20651fe58A369fD6f76c21A8FF7f8d42);
    uint256 public rewardAmount = 1e18;

    function setUp() public {
        weth = new ERC20("Wrapped Ether", "WETH");
        loan = new Loan(address(weth));
        deal(address(weth), address(loan), rewardAmount);
    }

    function testFlashLoan() public {
        uint256 minFlashLoan = 1e23;
        address user = address(123);
        deal(address(DAI), address(loan), minFlashLoan / 1e3);
        IPool iPool = IPool(loan.POOL());

        vm.startPrank(user);
        iPool.flashLoanSimple(address(loan), address(DAI), minFlashLoan, "", 0);

        assertGt(loan.totalLoans(user), 0);
        loan.removeLoan(address(weth), rewardAmount);
        assertEq(weth.balanceOf(user), rewardAmount);
    }

    // function testDoubleFlashLoan() public {
        // uint256 minFlashLoan = 1e23;
        // address user = address(123);
        // deal(address(DAI), address(loan), minFlashLoan / 1e3);
        // IPool iPool = IPool(loan.POOL());
        // DoubleLoan doubleLoan = new DoubleLoan(address(loan));
        // deal(address(DAI), address(doubleLoan), 10e18);

        // loan.addUsingFlashLoan(address(DAI), rewardAmount);
        // DAI.approve(address(iPool), 1e18);
        // iPool.supply(address(DAI), 1e18, user, 0);
        // iPool.flashLoanSimple(address(loan), address(DAI), rewardAmount, "", 0);
    // }

}

