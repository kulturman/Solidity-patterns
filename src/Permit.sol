// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Permit is ERC20Permit {
    constructor() ERC20Permit("FAKE") ERC20("FAKE", "FAKE") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
