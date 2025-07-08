// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Permit} from "../src/Permit.sol";

contract PermitTest is Test {
    Permit public permitContract;

    function setUp() public {
        permitContract = new Permit();
    }

    function testTransferFromFailsWithNoPermit() public {
        permitContract.approve(address(this), 1000);
        vm.startPrank(address(1));
        vm.expectRevert();
        permitContract.transferFrom(address(this), address(2), 1000);
        vm.stopPrank();
    }

    function testTransferFromSucceedsWithPermit() public {
        uint256 privateKey = 0xA11CE;
        address owner = vm.addr(privateKey);
        //We first transfer from contract to owner to ensure the owner has tokens to spend
        permitContract.transfer(owner, 1000);

        vm.startPrank(owner);
        permitContract.approve(address(this), 1000);
        vm.stopPrank();

        address spender = address(1);
        uint256 value = 1000;
        uint256 deadline = block.timestamp + 1 days;
        uint256 nonce = permitContract.nonces(owner);

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", permitContract.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        permitContract.permit(owner, spender, value, deadline, v, r, s);

        vm.startPrank(spender);
        permitContract.transferFrom(owner, address(2), value);
        vm.stopPrank();
    }
}
