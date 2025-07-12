// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface IOracle {
    function getRate(Currency currency) external view returns (uint256, uint256);

    enum Currency {
        EUR,
        USD
    }

    error OnlyOwner();
    error RateNotAvailable();
}
