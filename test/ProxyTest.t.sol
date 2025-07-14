// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {Proxy} from "../src/Proxy.sol";
import {ProxyImplementation} from "../src/ProxyImplementation.sol";
import {ProxyImplementationV2} from "../src/ProxyImplementationV2.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract ProxyTest is Test {
    Proxy public proxy;

    function testProxyWithImplementation1() public {
        ProxyImplementation implementation = new ProxyImplementation();
        proxy = new Proxy(address(implementation), address(this));

        vm.startPrank(address(1));
        address(proxy).call(abi.encodeWithSignature("depositMoney(uint256)", 100));
        assertEq(proxy.totalBalance(), 100);
        address(proxy).call(abi.encodeWithSignature("depositMoney(uint256)", 100));
        assertEq(proxy.totalBalance(), 200);
        vm.stopPrank();
    }

    function testProxyWithImplementation2() public {
        ProxyImplementationV2 implementation = new ProxyImplementationV2();
        proxy = new Proxy(address(implementation), address(this));

        vm.startPrank(address(1));
        vm.expectEmit();
        emit ProxyImplementationV2.DepositMade(200);
        address(proxy).call(abi.encodeWithSignature("depositMoney(uint256)", 100));
        assertEq(proxy.totalBalance(), 200);
        vm.stopPrank();
    }

    function testProxyWithImplementation1And2() public {
        ProxyImplementation implementation1 = new ProxyImplementation();
        proxy = new Proxy(address(implementation1), address(this));

        vm.startPrank(address(1));
        address(proxy).call(abi.encodeWithSignature("depositMoney(uint256)", 100));
        assertEq(proxy.totalBalance(), 100);
        vm.stopPrank();

        //Update to implementation 2, need to be admin to do that, so no prank
        ProxyImplementationV2 implementation2 = new ProxyImplementationV2();
        vm.expectEmit();
        emit Proxy.ImplementationUpdated(address(implementation2));
        address(proxy).call(abi.encode((address(implementation2))));

        vm.startPrank(address(1));
        vm.expectEmit();
        emit ProxyImplementationV2.DepositMade(200);
        address(proxy).call(abi.encodeWithSignature("depositMoney(uint256)", 100));
        assertEq(proxy.totalBalance(), 300);

    }
}
