// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IUpgradableProxy} from "./interfaces/IUpgradableProxy.sol";

contract ProxyAdmin {
    address public owner;

    error MustBeOwner();
    error InvalidOwnerAddress();
    error InvalidImplementationAddress();
    error ImplementationNotContract();

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

    function updateImplementation(address proxy, address newImplementation, bytes memory data) external onlyOwner {
        require(newImplementation != address(0), InvalidImplementationAddress());
        require(newImplementation.code.length > 0, ImplementationNotContract());
        IUpgradableProxy(proxy).updateImplementation(newImplementation, data);
    }
}
