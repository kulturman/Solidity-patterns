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
        proxy = new Proxy(address(implementation));

        proxy.depositMoney(100);
        assertEq(proxy.totalBalance(), 100);

        proxy.depositMoney(100);
        assertEq(proxy.totalBalance(), 200);
    }

    function testProxyWithImplementation2() public {
        ProxyImplementationV2 implementation = new ProxyImplementationV2();
        proxy = new Proxy(address(implementation));

        vm.expectEmit();
        emit ProxyImplementationV2.DepositMade(200);
        proxy.depositMoney(100);
        assertEq(proxy.totalBalance(), 200);
    }

    function testProxyWithImplementation1And2() public {
        ProxyImplementation implementation1 = new ProxyImplementation();
        proxy = new Proxy(address(implementation1));

        proxy.depositMoney(100);
        assertEq(proxy.totalBalance(), 100);

        ProxyImplementationV2 implementation2 = new ProxyImplementationV2();
        proxy.updateImplementation(address(implementation2));

        vm.expectEmit();
        emit ProxyImplementationV2.DepositMade(200);
        proxy.depositMoney(100);
        assertEq(proxy.totalBalance(), 300);
    }
}
