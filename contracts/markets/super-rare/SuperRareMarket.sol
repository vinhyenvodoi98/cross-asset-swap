// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IMakersPlace {
    function buy(address _sendTo, uint256 _amount) payable external;
}

contract MakersPlaceMarket {

    address public SUPERRARE = 0x65B49f7AEE40347f5A90b714be4eF086f3fe5E2C;
    //0x2947f98c42597966a0ec25e92843c09ac17fbaa7
    
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