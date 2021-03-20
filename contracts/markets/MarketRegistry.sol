// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MarketRegistry is Ownable {
    
    enum MarketType {Buy, Sell, Both}
    enum CurrencySupported {Eth, Erc20, Both}

    struct Market {
        string name;
        MarketType marketType;
        CurrencySupported currencySupported;
        address proxy;
        bool isActive;
    }

    Market[] public markets;

    function addMarket(
        string memory name, 
        MarketType marketType, 
        CurrencySupported currencySupported, 
        address proxy
    ) external onlyOwner {
        markets.push(Market(name, marketType, currencySupported, proxy, true));
    }

    function setMarketStatus(uint256 marketId, bool newStatus) external onlyOwner {
        Market storage market = markets[marketId];
        market.isActive = newStatus;
    }

    function setMarketProxy(uint256 marketId, address newProxy) external onlyOwner {
        Market storage market = markets[marketId];
        market.proxy = newProxy;
    }
}