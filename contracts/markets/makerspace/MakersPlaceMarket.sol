// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IMakersPlace {
    function purchase(uint256 _tokenId, address _referredBy) payable external;
}

contract MakersPlaceMarket {

    address public MAKERSPLACE = 0x7e3abdE9D9E80fA2d1A02c89E0eae91b233CDE35;

    function buyAssetsForEth(bytes memory data) public {
        uint256[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (uint256[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // TODO: Check how to fetch NFT price from MAKERSPLACE
            //_buyAssetForEth(tokenIds[i], _price);
        }
    }

    function estimateAssetPriceInEth(uint256 nftAddress) public view returns(uint256) {
        
    }

    function estimateBatchAssetPriceInEth(uint256[] memory nftAddresses) public view returns(uint256 totalCost) {
    }

    function _buyAssetForEth(uint256 _tokenId, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(IMakersPlace(MAKERSPLACE).purchase.selector, _tokenId, address(this));

        (bool success, ) = MAKERSPLACE.call{value:_price}(_data);
        require(success, "_buyAssetForEth: makersPlace buy failed.");
    }
}