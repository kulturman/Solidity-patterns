// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

contract ProxyImplementationV2 {
    uint256 public totalBalance;

    event DepositMade(uint256 amount);

    function depositMoney(uint256 amount) external {
        totalBalance += amount * 2;
        emit DepositMade(amount * 2);
    }
}
