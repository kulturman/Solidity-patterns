// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Oracle} from "../src/Oracle.sol";
import {OracleConsumer} from "../src/OracleConsumer.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        Oracle oracle = new Oracle();
        console.log("Oracle deployed at:", address(oracle));

        OracleConsumer consumer = new OracleConsumer(address(oracle));
        console.log("OracleConsumer deployed at:", address(consumer));

        vm.stopBroadcast();
    }
}