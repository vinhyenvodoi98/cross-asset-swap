// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelinV2/contracts/math/SafeMath.sol";

interface ICryptoPunks {

    struct Offer {
        bool isForSale;
        uint punkIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    function buyPunk(uint punkIndex) external payable;

    function punksOfferedForSale(uint punkIndex) external view returns(Offer memory offer);
}

contract CryptoPunksMarket {

    using SafeMath for uint256;

    address public CRYPTOPUNKS = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;

    function buyAssetsFromCryptoPunkMarket(uint256[] memory punkIndexes) public {
        for (uint256 i = 0; i < punkIndexes.length; i++) {
            if(offer.isForSale) {
                _buyPunk(punkIndexes[i], estimateCryptoPunkAssetPriceInEth(punkIndexes[i]));
            }
        }
    }

    function estimateCryptoPunkAssetPriceInEth(uint256 punkIndex) public view returns(uint256) {
        return ICryptoPunks(CRYPTOPUNKS).punksOfferedForSale(punkIndex).minValue;
    }

    function estimateBatchCryptoPunkAssetPriceInEth(uint256[] memory punkIndexes) public view returns(uint256 totalCost) {
        ICryptoPunks.Offer memory offer;
        for (uint256 i = 0; i < punkIndexes.length; i++) {
            offer = ICryptoPunks(CRYPTOPUNKS).punksOfferedForSale(punkIndexes[i]);
            if(offer.isForSale) {
                totalCost = totalCost.add(offer.minValue);
            }
        }
    }

    function _buyAssetFromCryptoPunkMarket(uint256 _index, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(ICryptoPunks(CRYPTOPUNKS).buyPunk.selector, _index);

        (bool success, ) = CRYPTOPUNKS.call{value:_price}(_data);
        require(success, "_buyAssetFromCryptoPunkMarket: cryptopunk buy failed.");
    }

}