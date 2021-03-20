// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface ISuperRare {
    function buy(address _sendTo, uint256 _amount) payable external;
}

contract SuperRareMarket {

    address public SUPERRARE = 0x65B49f7AEE40347f5A90b714be4eF086f3fe5E2C;
    address public SUPR = 0xb932a70A57673d89f4acfFBE830E8ed7f75Fb9e0;
    //0x2947f98c42597966a0ec25e92843c09ac17fbaa7

    function buyAssetsForEth(bytes memory data) public {
        uint256[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (uint256[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // TODO: Check how to fetch NFT price from SUPERRARE
            // _buyAssetForEth(tokenIds[i], _price);
        }
    }

    function estimateAssetPriceInEth(uint256 nftAddress) public view returns(uint256) {
        
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {

    }

    function _buyAssetForEth(uint256 _tokenId, uint256 _price, address _sendTo) internal {
        bytes memory _data = abi.encodeWithSelector(ISuperRare(SUPERRARE).buy.selector, SUPR, _tokenId);

        (bool success, ) = SUPERRARE.call{value:_price}(_data);
        require(success, "_buyAssetForEth: SuperRare buy failed.");
    }
}