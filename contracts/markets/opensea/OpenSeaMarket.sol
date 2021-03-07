// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IOpenSea {
    /**
     * @dev Call atomicMatch - Solidity ABI encoding limitation workaround, hopefully temporary.
     */
    function atomicMatch_(
        address[14] memory addrs,
        uint[18] memory uints,
        uint8[8] memory feeMethodsSidesKindsHowToCalls,
        bytes memory calldataBuy,
        bytes memory calldataSell,
        bytes memory replacementPatternBuy,
        bytes memory replacementPatternSell,
        bytes memory staticExtradataBuy,
        bytes memory staticExtradataSell,
        uint8[2] memory vs,
        bytes32[5] memory rssMetadata)
        external
        payable;
}

contract OpenSeaMarket {

    address public OPENSEA = 0x7Be8076f4EA4A4AD08075C2508e481d6C946D12b;

    function buyERC721FromOpenSeaMarket() public {

    }

    function buyERC1155FromOpenSeaMarket() public {}

/*     function decode(bytes memory _data) public {
        address[14] memory addrs;
        uint[18] memory uints;
        uint8[8] memory feeMethodsSidesKindsHowToCalls;
        bytes memory calldataBuy;
        bytes memory calldataSell;
        bytes memory replacementPatternBuy;
        bytes memory replacementPatternSell;
        bytes memory staticExtradataBuy;
        bytes memory staticExtradataSell;
        uint8[2] memory vs;
        bytes32[5] memory rssMetadata;

        (addrs, uints, feeMethodsSidesKindsHowToCalls, calldataBuy, calldataSell, replacementPatternBuy, replacementPatternSell, staticExtradataBuy, staticExtradataSell, vs, rssMetadata) = abi.decode(
            _data,
            (address[14], uint[18], uint8[8], bytes, bytes, bytes, bytes, bytes, bytes, uint8[2], bytes32[5])
        );

        emit Addrs(addrs);
        emit Uints(uints);
        emit FeeMethodsSidesKindsHowToCalls(feeMethodsSidesKindsHowToCalls);
        emit CalldataBuy(calldataBuy);
        emit CalldataSell(calldataSell);
        emit ReplacementPatternBuy(replacementPatternBuy);
        emit ReplacementPatternSell(replacementPatternSell);
        emit StaticExtradataBuy(staticExtradataBuy);
        emit StaticExtradataSell(staticExtradataSell);
        emit Vs(vs);
        emit RssMetadata(rssMetadata);
    } */
}