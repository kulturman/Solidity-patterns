// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {console} from "../lib/forge-std/src/console.sol";


contract Oracle {
    error OnlyOwner();
    error EmptyCurrency();
    error InvalidRate();
    error RateNotAvailable();

    address public owner;
    
    struct ExchangeRate {
        uint256 rate;
        uint256 timestamp;
    }
    
    mapping(string => ExchangeRate) public exchangeRates;
    
    event RateUpdated(string currency, uint256 rate, uint256 timestamp);
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function updateRate(string memory currency, uint256 rate) external onlyOwner {
        if (bytes(currency).length == 0) revert EmptyCurrency();
        if (rate == 0) revert InvalidRate();
        
        exchangeRates[currency] = ExchangeRate({
            rate: rate,
            timestamp: block.timestamp
        });

        console.log("Rate has been updated for %s: %d at %d", currency, rate, block.timestamp);
        emit RateUpdated(currency, rate, block.timestamp);
    }
    
    function getRate(string memory currency) external view returns (uint256, uint256) {
        ExchangeRate memory exchangeRate = exchangeRates[currency];
        if (exchangeRate.timestamp == 0) revert RateNotAvailable();

        return (exchangeRate.rate, exchangeRate.timestamp);
    }
    
    function isRateStale(string memory currency, uint256 maxAge) external view returns (bool) {
        ExchangeRate memory exchangeRate = exchangeRates[currency];
        if (exchangeRate.timestamp == 0) return true;
        
        return (block.timestamp - exchangeRate.timestamp) > maxAge;
    }
}
