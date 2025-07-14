// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

contract Proxy {
    uint256 public totalBalance;
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    address public immutable owner;

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


    fallback() external {
        if (msg.sender == owner) {
            address newImplementation = msg.data.length > 0 ? abi.decode(msg.data, (address)) : address(0);
            bytes32 slot = IMPLEMENTATION_SLOT;

            assembly {
                sstore(slot, newImplementation)
            }

            emit ImplementationUpdated(newImplementation);
        }

        else {
            (bool success,) = getImplementation().delegatecall(msg.data);
            require(success, DelegateCallFailed());
        }
    }
}
