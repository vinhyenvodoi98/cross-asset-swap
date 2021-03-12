// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketRegistry is Ownable {
    struct Market {
        string name;
        address proxy;
        bool isActive;
    }

    Market[] public markets;

    function addMarket(string name, address proxy) external onlyOwner {
        markets.push(Market(name, proxy, true));
    }

    function setMarketStatus(uint256 marketId, bool newStatus) external onlyOwner {
        Market storage market = markets[marketId];
        market.isActive = newStatus;
    }

    function setMarketProxy(uint256 marketId, address newProxy) external onlyOwner {
        Market storage market = markets[marketId];
        market.newProxy = newProxy;
    }
}