// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

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

    address public CRYPTOPUNKS = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;

    function buyPunksFromMarket(uint256[] memory punkIndexes) public {
        for (uint256 i = 0; i < punkIndexes.length; i++) {
            ICryptoPunks.Offer memory offer = ICryptoPunks(CRYPTOPUNKS).punksOfferedForSale(punkIndexes[i]);
            if(offer.isForSale) {
                _buyPunk(punkIndexes[i], offer.minValue);
            }
        } 
    }

    function estimeTotalCostInEth(uint256[] memory punkIndexes) public view returns(uint256 totalCost) {
        for (uint256 i = 0; i < punkIndexes.length; i++) {
            ICryptoPunks.Offer memory offer = ICryptoPunks(CRYPTOPUNKS).punksOfferedForSale(punkIndexes[i]);
            if(offer.isForSale) {
                totalCost += offer.minValue;
            }
        }
    }

    function estimeTotalCostInERC20(uint256[] memory punkIndexes, address asset) public view {

    }

    function _buyPunk(uint256 _index, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(ICryptoPunks(CRYPTOPUNKS).buyPunk.selector, _index);

        (bool success, ) = CRYPTOPUNKS.call{value:_price}(_data);
        require(success, "_buyPunk: cryptopunk buy failed.");
    }

}