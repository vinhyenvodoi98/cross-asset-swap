// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IRarible {
        enum AssetType {ETH, ERC20, ERC1155, ERC721, ERC721Deprecated}

    struct Asset {
        address token;
        uint tokenId;
        AssetType assetType;
    }

    struct OrderKey {
        /* who signed the order */
        address owner;
        /* random number */
        uint salt;

        /* what has owner */
        Asset sellAsset;

        /* what wants owner */
        Asset buyAsset;
    }

    struct Order {
        OrderKey key;

        /* how much has owner (in wei, or UINT256_MAX if ERC-721) */
        uint selling;
        /* how much wants owner (in wei, or UINT256_MAX if ERC-721) */
        uint buying;

        /* fee for selling */
        uint sellerFee;
    }

    /* An ECDSA signature. */
    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    function exchange(
        Order calldata order,
        Sig calldata sig,
        uint buyerFee,
        Sig calldata buyerFeeSig,
        uint amount,
        address buyer
    ) payable external;
}

contract RaribleMarket {

    using SafeMath for uint256;

    address public RARIBLE = 0xcd4EC7b66fbc029C116BA9Ffb3e59351c20B5B06;

    function buyAssetsFromRaribleMarket(uint256[] memory punkIndexes) public {

    }

    function estimateBatchRaribleAssetPriceInEth(uint256[] memory punkIndexes) public view returns(uint256 totalCost) {

    }

    function estimateRaribleAssetPriceInEth(uint256 punkIndexes) public view returns(uint256 totalCost) {

    }

    function _buyAssetFromRaribleMarket(uint256 _index, uint256 _price) internal {

    }
}