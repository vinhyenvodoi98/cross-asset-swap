// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IMakersPlace {
    function purchase(uint256 _tokenId, address _referredBy) payable external;
}

contract MakersPlaceMarket {

    address public MAKERSPLACE = 0x7e3abdE9D9E80fA2d1A02c89E0eae91b233CDE35;

    function buyAssetsFromMakersPlaceMarket(uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // TODO: Check how to fetch NFT price from MAKERSPLACE
            //_buyAssetFromMakersPlaceMarket(tokenIds[i], _price);
        }
    }

    function estimateMakersPlaceAssetPriceInEth(uint256 nftAddress) public view returns(uint256) {
        
    }

    function estimateBatchMakersPlaceAssetPriceInEth(uint256[] memory nftAddresses) public view returns(uint256 totalCost) {
    }

    function _buyAssetFromMakersPlaceMarket(uint256 _tokenId, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(IMakersPlace(MAKERSPLACE).purchase.selector, _tokenId, address(this));

        (bool success, ) = MAKERSPLACE.call{value:_price}(_data);
        require(success, "_buyAssetFromMakersPlaceMarket: makersPlace buy failed.");
    }
}