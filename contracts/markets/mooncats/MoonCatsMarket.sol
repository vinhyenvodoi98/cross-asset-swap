// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IMoonCats {

    struct AdoptionOffer {
        bool exists;
        bytes5 catId;
        address seller;
        uint price;
        address onlyOfferTo;
    }

    /* accepts an adoption offer  */
    function acceptAdoptionOffer(bytes5 catId) payable external;

    function adoptionOffers(bytes5 catId) external view returns(AdoptionOffer memory offer);
}

contract MoonCatsMarket {

    address public MOONCATS = 0x60cd862c9C687A9dE49aecdC3A99b74A4fc54aB6;

    function buyAssetsForEth(bytes memory data) public {
        bytes5[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (bytes5[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _buyAssetForEth(tokenIds[i], estimateAssetPriceInEth(tokenIds[i]));
        }
    }

    function estimateAssetPriceInEth(bytes5 tokenId) public view returns(uint256) {
        return IMoonCats(MOONCATS).adoptionOffers(tokenId).price;
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {
        bytes5[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (bytes5[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalCost += IMoonCats(MOONCATS).adoptionOffers(tokenIds[0]).price;
        }
    }

    function _buyAssetForEth(bytes5 _tokenId, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(IMoonCats(MOONCATS).acceptAdoptionOffer.selector, _tokenId);

        (bool success, ) = MOONCATS.call{value:_price}(_data);
        require(success, "_buyAssetForEth: moonCats buy failed.");
    }
}