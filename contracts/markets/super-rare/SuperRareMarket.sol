// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface ISuperRare {
    /**
     * @dev Purchases the token if it is for sale.
     * @param _originContract address of the contract storing the token.
     * @param _tokenId uint256 ID of the token.
     */
    function buy(address _originContract, uint256 _tokenId) external payable;

    /**
     * @dev Gets the sale price of the token including the marketplace fee.
     * @param _originContract address of the contract storing the token.
     * @param _tokenId uint256 ID of the token
     * @return uint256 sale price of the token including the fee.
     */
    function tokenPriceFeeIncluded(address _originContract, uint256 _tokenId)
    external
    view
    returns (uint256);
}

contract SuperRareMarket {

    address public SUPERRARE = 0x65B49f7AEE40347f5A90b714be4eF086f3fe5E2C;
    address public SUPR = 0xb932a70A57673d89f4acfFBE830E8ed7f75Fb9e0;

    function buyAssetsForEth(bytes memory data) public payable {
        uint256[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (uint256[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _buyAssetForEth(tokenIds[i], estimateAssetPriceInEth(tokenIds[i]));
        }
    }

    function estimateAssetPriceInEth(uint256 tokenId) public view returns(uint256) {
        return ISuperRare(SUPERRARE).tokenPriceFeeIncluded(SUPR, tokenId);
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {
        uint256[] memory tokenIds;
        (tokenIds) = abi.decode(
            data,
            (uint256[])
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            totalCost += ISuperRare(SUPERRARE).tokenPriceFeeIncluded(SUPR, tokenIds[i]);
        }
    }

    function _buyAssetForEth(uint256 _tokenId, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(ISuperRare(SUPERRARE).buy.selector, SUPR, _tokenId);

        (bool success, ) = SUPERRARE.call{value:_price}(_data);
        require(success, "_buyAssetForEth: SuperRare buy failed.");
    }
}