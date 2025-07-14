// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {console} from "../lib/forge-std/src/console.sol";
import {IUpgradableProxy} from "./interfaces/IUpgradableProxy.sol";

contract Proxy {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    address public immutable owner;

    uint256 public totalBalance;

    event ImplementationUpdated(address);

    error MustBeOwner();
    error InvalidImplementationAddress();
    error DelegateCallFailed();

    constructor(address _implementation, address _owner) {
        owner = _owner;
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, _implementation)
        }
    }

    function getImplementation() public view returns (address implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            implementation := sload(slot)
        }
    }

    function __fallback() public {}

    fallback() external {
        if (msg.sender == owner) {
            console.logBytes(msg.data);
            console.log(msg.data.length);
            abi.decode(msg.data, (address, bytes));
            //address newImplementation = msg.data.length > 0 ? abi.decode(msg.data, (address)) : address(0);
            //require(newImplementation != address(0), InvalidImplementationAddress());

            /*bytes32 slot = IMPLEMENTATION_SLOT;

            assembly {
                sstore(slot, newImplementation)
            }*/

            //emit ImplementationUpdated(newImplementation);
        } else {
            console.log("I am not owner, delegate call to implementation");
            (bool success,) = getImplementation().delegatecall(msg.data);
            require(success, DelegateCallFailed());
        }
    }
}
