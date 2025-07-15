// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IProxyImplementation} from "./interfaces/IProxyImplementation.sol";

contract ProxyImplementation is IProxyImplementation {
    uint256 public totalBalance;

    function depositMoney(uint256 amount) external {
        totalBalance += amount;
    }
}
