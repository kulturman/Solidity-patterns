// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

error StaleRate();

interface IOracle {
    function getRate(string memory currency) external view returns (uint256, uint256);
    function isRateStale(string memory currency, uint256 maxAge) external view returns (bool);
}

contract OracleConsumer {
    IOracle public oracle;
    uint256 public constant MAX_RATE_AGE = 3600;

    event RateRequested(string currency, uint256 rate, uint256 timestamp);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    function getUSDToXOFRate() external view returns (uint256 rate, uint256 timestamp) {
        if (oracle.isRateStale("USD", MAX_RATE_AGE)) revert StaleRate();
        return oracle.getRate("USD");
    }

    function getEURToXOFRate() external view returns (uint256 rate, uint256 timestamp) {
        if (oracle.isRateStale("EUR", MAX_RATE_AGE)) revert StaleRate();
        return oracle.getRate("EUR");
    }

    function convertUSDToXOF(uint256 usdAmount) external view returns (uint256) {
        (uint256 rate,) = this.getUSDToXOFRate();
        return (usdAmount * rate) / 1e18;
    }

    function convertEURToXOF(uint256 eurAmount) external view returns (uint256) {
        (uint256 rate,) = this.getEURToXOFRate();
        return (eurAmount * rate) / 1e18;
    }

    function requestAndLogRate(string memory currency) external {
        if (oracle.isRateStale(currency, MAX_RATE_AGE)) revert StaleRate();
        (uint256 rate, uint256 timestamp) = oracle.getRate(currency);
        emit RateRequested(currency, rate, timestamp);
    }
}
