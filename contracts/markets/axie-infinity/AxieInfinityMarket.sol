// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IAxieInfinity {

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _tokenId - ID of token to bid on.
    function bid(
        address _nftAddress,
        uint256 _tokenId
    ) external payable;

    /// @dev Returns the current price of an auction.
    /// @param _nftAddress - Address of the NFT.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(
        address _nftAddress,
        uint256 _tokenId
    )
    external
    view
    returns (uint256);
}

contract AxieInfinityMarket {

    using SafeMath for uint256;

    address public AXIE_INFINITY = 0xF4985070Ce32b6B1994329DF787D1aCc9a2dd9e2;

    function buyAssetsForEth(bytes memory data) public {
        address[] memory nftAddresses;
        uint256[] memory tokenIds;
        (nftAddresses, tokenIds) = abi.decode(
            data,
            (address[], uint256[])
        );
        for (uint256 i = 0; i < nftAddresses.length; i++) {
            _buyAssetForEth(nftAddresses[i], tokenIds[i]);
        }
    }

    function estimateAssetPriceInEth(address nftAddress, uint256 tokenId) public view returns(uint256) {
        return IAxieInfinity(AXIE_INFINITY).getCurrentPrice(nftAddress, tokenId);
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {
        address[] memory nftAddresses;
        uint256[] memory tokenIds;
        (nftAddresses, tokenIds) = abi.decode(
            data,
            (address[], uint256[])
        );
        for (uint256 i = 0; i < nftAddresses.length; i++) {
            totalCost = totalCost.add(IAxieInfinity(AXIE_INFINITY).getCurrentPrice(nftAddresses[i], tokenIds[i]));
        }
    }

    function _buyAssetForEth(address _nftAddress, uint256 _tokenId) public {
        bytes memory _data = abi.encodeWithSelector(IAxieInfinity(AXIE_INFINITY).bid.selector, _nftAddress, _tokenId);

        (bool success, ) = AXIE_INFINITY.call{value:estimateAssetPriceInEth(_nftAddress,_tokenId)}(_data);
        require(success, "_buyAssetForEth: axie buy failed.");
    }

}