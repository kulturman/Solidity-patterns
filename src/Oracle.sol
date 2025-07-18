// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IOracle} from "./interfaces/IOracle.sol";

contract Oracle is IOracle {
    address public owner;

    struct ExchangeRate {
        uint256 rate;
        uint256 timestamp;
    }

    mapping(Currency => ExchangeRate) public exchangeRates;

    event RateUpdated(Currency currency, uint256 rate, uint256 timestamp);

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updateRate(Currency currency, uint256 rate) external onlyOwner {
        exchangeRates[currency] = ExchangeRate({rate: rate, timestamp: block.timestamp});

        emit RateUpdated(currency, rate, block.timestamp);
    }

    function getRate(Currency currency) external view returns (uint256, uint256) {
        ExchangeRate memory exchangeRate = exchangeRates[currency];
        if (exchangeRate.timestamp == 0) revert RateNotAvailable();

        return (exchangeRate.rate, exchangeRate.timestamp);
    }
}
