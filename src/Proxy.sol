// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

contract Proxy {
    uint256 public totalBalance;
    address public implementation;
    address public owner;

    event ImplementationUpdated(address newImplementation);

    error MustBeOwner();
    error InvalidImplementationAddress();
    error DelegateCallFailed();

    modifier onlyOwner() {
        require(msg.sender == owner, MustBeOwner());
        _;
    }

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    //I could have used a fallback function, but just wanted to show how to use delegatecall explicitly, Alexandre
    function depositMoney(uint256 amount) external {
        (bool success,) = implementation.delegatecall(abi.encodeWithSignature("depositMoney(uint256)", amount));
        require(success, DelegateCallFailed());
    }

    function updateImplementation(address newImplementation) external onlyOwner {
        require(newImplementation != address(0) && implementation.code.length > 0, InvalidImplementationAddress());
        implementation = newImplementation;
        emit ImplementationUpdated(newImplementation);
    }
}
