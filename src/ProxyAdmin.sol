// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IUpgradableProxy} from "./interfaces/IUpgradableProxy.sol";

contract ProxyAdmin {
    address public owner;

    error MustBeOwner();
    error InvalidOwnerAddress();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, MustBeOwner());
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), InvalidOwnerAddress());
        owner = newOwner;
    }

    function updateImplementation(address proxy, address newImplementation, bytes calldata data) external onlyOwner {
        IUpgradableProxy(proxy).updateImplementation(newImplementation, data);
    }
}
