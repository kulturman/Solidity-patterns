// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

contract ProxyImplementation {
    uint256 public totalBalance;

    function depositMoney(uint256 amount) external {
        totalBalance += amount;
    }
}
