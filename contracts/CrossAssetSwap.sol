// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract CrossAssetSwap {
    // bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
    // bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    /* struct ERC20Details {
        address[] tokenAddrs;
        uint256[] amounts;
    }

    struct ERC721Details {
        address[] tokenAddrs;
        uint256[] ids;
    }

    struct ERC1155Details {
        address[] tokenAddrs;
        uint256[] ids;
        uint256[] amounts;
    } */

    // swaps any combination of ERC-20/721/1155
    // User needs to approve assets before invoking swap
    /* function swap(
        ERC20Details calldata inputERC20s,
        ERC721Details calldata inputERC721s,
        ERC1155Details calldata inputERC1155s,
        ERC20Details calldata outputERC20s,
        ERC721Details calldata outputERC721s,
        ERC1155Details calldata outputERC1155s
    ) external {
        // transfer ERC20 tokens from the sender to this contract
        // WARNING: It is assumed that the ERC20 token addresses are NOT malicious
        for (uint256 i = 0; i < inputERC20s.tokenAddrs.length; i++) {
            IERC20(inputERC20s.tokenAddrs[i]).transferFrom(
                msg.sender,
                address(this),
                inputERC20s.amounts[i]
            );
        }
        // transfer ERC721 tokens from the sender to this contract
        // WARNING: It is assumed that the ERC721 token addresses are NOT malicious
        for (uint256 i = 0; i < inputERC721s.tokenAddrs.length; i++) {
            IERC721(inputERC721s.tokenAddrs[i]).transferFrom(
                msg.sender,
                address(this),
                inputERC721s.ids[i]
            );
        }
        // transfer ERC1155 tokens from the sender to this contract
        // WARNING: It is assumed that the ERC1155 token addresses are NOT malicious
        for (uint256 i = 0; i < inputERC1155s.tokenAddrs.length; i++) {
            IERC1155(inputERC1155s.tokenAddrs[i]).safeBatchTransferFrom(
                msg.sender,
                address(this),
                inputERC1155s.ids[i],
                inputERC1155s.amounts[i],
                ""
            );
        }
    } */
}
