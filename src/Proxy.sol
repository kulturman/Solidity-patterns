// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IUpgradableProxy} from "./interfaces/IUpgradableProxy.sol";
import {console} from "../lib/forge-std/src/console.sol";

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

    fallback() external {
        if (msg.sender == owner) {
            if (msg.sig != IUpgradableProxy.updateImplementation.selector) {
                revert("You are not supposed to do that");
            } else {
                (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
                _setImplementation(newImplementation);

                console.logBytes(data);
                console.logBytes(msg.data);

                if (msg.data.length > 0) {
                    _delegateCall(
                        newImplementation,
                        abi.encodePacked(data)
                    );
                }
            }
        } else {
            _delegateCall(_getImplementation(), msg.data);
        }
    }

    function _getImplementation() private view returns (address implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            implementation := sload(slot)
        }
    }

    function _delegateCall(address implementation, bytes memory data) private {
        (bool success,) = implementation.delegatecall(data);
        require(success, DelegateCallFailed());
    }

    function _setImplementation(address newImplementation) private {
        require(newImplementation != address(0), InvalidImplementationAddress());

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}
