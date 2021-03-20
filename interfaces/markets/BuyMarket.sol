// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface BuyMarket {
    function buyAssetsForEth(bytes memory data) external;
    function estimateBatchAssetPriceInEth(bytes memory data) external view returns(uint256 totalCost);
}