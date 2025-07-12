// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IOracle} from "./interfaces/IOracle.sol";

contract OracleConsumer {
    IOracle public oracle;
    uint256 public constant MAX_RATE_AGE = 3600;

    error StaleRate();

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    function getUSDToXOFRate() public view returns (uint256 rate, uint256 timestamp) {
        (rate, timestamp) = oracle.getRate(IOracle.Currency.USD);
        if (block.timestamp - timestamp > MAX_RATE_AGE) revert StaleRate();
    }

    function getEURToXOFRate() public view returns (uint256 rate, uint256 timestamp) {
        (rate, timestamp) = oracle.getRate(IOracle.Currency.EUR);
        if (block.timestamp - timestamp > MAX_RATE_AGE) revert StaleRate();
    }

    function convertUSDToXOF(uint256 usdAmount) external view returns (uint256) {
        (uint256 rate,) = getUSDToXOFRate();
        return (usdAmount * rate) / 1e18;
    }

    function convertEURToXOF(uint256 eurAmount) external view returns (uint256) {
        (uint256 rate,) = getEURToXOFRate();
        return (eurAmount * rate) / 1e18;
    }
}
