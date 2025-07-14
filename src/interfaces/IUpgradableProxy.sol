// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IUpgradableProxy {
    function updateImplementation(address newImplementation, bytes memory data) external;
}
