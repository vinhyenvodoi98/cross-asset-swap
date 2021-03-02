// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
interface NFT20Swapper {
    struct ERC20Details {
        address[] tokenAddrs;
        uint256[] amounts;
    }

    function swapERC20ForERC721(
        ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        address changeIn
    ) external;
    
    function swapERC20ForERC1155(
        ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn
    ) external;

    function swapEthForERC721(
        address toNft,
        uint256[] calldata toIds,
        address changeIn      
    ) external payable;

    function swapEthForERC1155(
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn        
    ) external payable;
}

contract TestSwap is IERC721Receiver, IERC1155Receiver {

    function swapERC1155ForAnyAsset(
        address _swap, 
        address _fromERC1155,
        uint256[] calldata _fromIds, 
        uint256[] calldata _fromAmounts,
        uint256[] calldata _toIds, 
        uint256[] calldata _toAmounts,
        address[] calldata _addrs
    ) external {
        bytes memory _data = abi.encode(_addrs, _toIds, _toAmounts);
        IERC1155(_fromERC1155).safeBatchTransferFrom(
            address(this),
            _swap,
            _fromIds,
            _fromAmounts,
            _data
        );
    }

    function swapERC721ForAnyAsset(
        address _swap, 
        address _fromERC721,
        uint256 _fromId,
        uint256[] calldata _toIds, 
        uint256[] calldata _toAmounts,
        address[] calldata _addrs
    ) external {
        bytes memory _data = abi.encode(_addrs, _toIds, _toAmounts);
        IERC721(_fromERC721).safeTransferFrom(
            address(this),
            _swap,
            _fromId,
            _data
        );
    }

    function swapERC20ForERC1155(
        address _swap,
        NFT20Swapper.ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn
    ) external {
        NFT20Swapper(_swap).swapERC20ForERC1155(
            fromERC20s,
            toNft,
            toIds,
            toAmounts,
            changeIn
        );
    }

    function swapERC20ForERC721(
        address _swap,
        NFT20Swapper.ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        address changeIn
    ) external {
        NFT20Swapper(_swap).swapERC20ForERC721(
            fromERC20s, 
            toNft, 
            toIds, 
            changeIn
        );
    }

    function swapEthForERC721(
        address _swap,
        address toNft,
        uint256[] calldata toIds,
        address changeIn
    ) external payable {
        NFT20Swapper(_swap).swapEthForERC721(
            toNft, 
            toIds, 
            changeIn
        );
    }
    function swapEthForERC1155(
        address _swap,
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn
    ) external payable {
        NFT20Swapper(_swap).swapEthForERC1155(
            toNft,
            toIds, 
            toAmounts, 
            changeIn
        );
    }


    receive() external payable {}

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        override
        view
        returns (bool)
    {}
}