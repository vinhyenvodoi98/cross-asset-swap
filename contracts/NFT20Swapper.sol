// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./dexes/nft20/Nft20Router.sol";
import "./dexes/uniswap/UniswapRouter.sol";

contract NFT20Swapper is
    IERC721Receiver,
    IERC1155Receiver,
    Ownable,
    UniswapRouter,
    Nft20Router
{
    struct ERC20Details {
        address[] tokenAddrs;
        uint256[] amounts;
    }

    function _swapExactERC20ForETH(
        address _from,
        address _recipient,
        uint256 _amountIn
    )
    internal virtual returns (uint256[] memory amount)
    {
        return _swapExactERC20ForETHViaUniswap(_from, _recipient, _amountIn);
    }

    function _swapETHForExactERC20(
        address _to,
        address _recipient,
        uint256 _amountOut
    )
    internal virtual returns (uint256[] memory amount)
    {
        return _swapETHForExactERC20ViaUniswap(_to, _recipient, _amountOut);
    }

    function _swapExactETHForERC20(
        address _to,
        address _recipient,
        uint256 _amountOutMin
    )
    internal virtual returns (uint256[] memory amount)
    {
        return _swapExactETHForERC20ViaUniswap(_to, _recipient, _amountOutMin);
    }

    function _swapExactERC20ForERC20(address _from, address _to, address _recipient)
        internal
        virtual
        returns (uint256[] memory amount)
    {
        return _swapExactERC20ForERC20ViaUniswap(_from, _to, _recipient);
    }

    function _swapERC20ForExactERC20(address _from, address _to, address _recipient, uint256 _amountOut)
        internal
        virtual
        returns (uint256[] memory amount)
    {
        return _swapERC20ForExactERC20ViaUniswap(_from, _to, _recipient, _amountOut);
    }

    // converts ETH to ERC721(s) and returns change in changeIn ERC20
    function swapEthForERC721(
        address toNft,
        uint256[] calldata toIds,
        address changeIn      
    ) virtual external payable {
        // ETH -> eq. ERC20 -> ERC721(s)
        // Convert ETH to eq. ERC20
        _swapETHForExactERC20(
            nftToErc20[toNft],
            address(this),
            toIds.length*NFT20_NFT_VALUE
        );

        uint256[] memory amounts;

        // Convert eq. ERC20 to ERC721(s)
        _swapERC20EquivalentForNFTViaNft20(nftToErc20[toNft], toIds, amounts, msg.sender);
        
        // check if the user wants the change in ETH
        if(changeIn == ETH) {
            // Return the change ETH back
            (bool success, ) = msg.sender.call{value:address(this).balance}("");
            require(success, "swapEthForERC721: ETH dust transfer failed.");
        }
        else {
            // Return the change in desired ERC20 back
            _swapExactETHForERC20(changeIn, msg.sender, 0);
        }
    }

    // converts ETH to ERC1155(s) and returns change in changeIn ERC20
    function swapEthForERC1155(
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn        
    ) virtual external payable {
        // ETH -> eq. ERC20 -> ERC1155(s) 
        // Calculate the total amount needed
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < toAmounts.length; i++) {
            totalAmount = totalAmount.add(toAmounts[i]);
        }

        // ETH -> Eq. ERC20
        _swapETHForExactERC20(nftToErc20[toNft], address(this), totalAmount*NFT20_NFT_VALUE);

        // Convert eq. ERC20 to ERC721(s)
        _swapERC20EquivalentForNFTViaNft20(nftToErc20[toNft], toIds, toAmounts, msg.sender);
        
        // check if the user wants the change in ETH
        if(changeIn == ETH) {
            // Return the change ETH back
            (bool success, ) = msg.sender.call{value:address(this).balance}("");
            require(success, "swapEthForERC721: ETH dust transfer failed.");
        }
        else {
            // Return the change in desired ERC20 back
            _swapExactETHForERC20(changeIn, msg.sender, 0);
        }
    }

    // User needs to approve ERC20 tokens
    function swapERC20ForERC721(
        ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        address changeIn
    ) virtual external {
        // ERC20 -> ETH -> Eq. ERC20 -> ERC721
        // Transfer the ERC20s to this contract
        for(uint256 i = 0; i < fromERC20s.tokenAddrs.length; i++) {
            IERC20(fromERC20s.tokenAddrs[i]).transferFrom(msg.sender, address(this), fromERC20s.amounts[i]);
            // ERC20 -> ETH
            _swapExactERC20ForETH(fromERC20s.tokenAddrs[i], address(this), fromERC20s.amounts[i]);
        }

        // ETH -> Eq. ERC20
        _swapETHForExactERC20(nftToErc20[toNft], address(this), toIds.length*NFT20_NFT_VALUE);

        uint256[] memory amounts;

        // Eq. ERC20 -> ERC721
        _swapERC20EquivalentForNFTViaNft20(
            nftToErc20[toNft],
            toIds,
            amounts,
            msg.sender
        );

        // Return the dust in changeIn asset if ETH balance is greater than 0
        if(address(this).balance > 0) {
            if(changeIn != ETH) {
                _swapExactETHForERC20ViaUniswap(changeIn, msg.sender, 0);
            }
            else {
                // Transfer remaining ETH to the msg.sender
                (bool success, ) = msg.sender.call{value:address(this).balance}("");
                require(success, "swapERC20ForERC721: ETH dust transfer failed.");
            }
        }
    }

    function swapERC20ForERC1155(
        ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn
        //uint256[] calldata toVaultIds,
    ) virtual external {
        // ERC20 -> WETH -> Eq. ERC20 -> ERC1155
        // Transfer the ERC20s to this contract
        for(uint256 i = 0; i < fromERC20s.tokenAddrs.length; i++) {
            IERC20(fromERC20s.tokenAddrs[i]).transferFrom(msg.sender, address(this), fromERC20s.amounts[i]);
            // ERC20 -> WETH
            _swapExactERC20ForETH(fromERC20s.tokenAddrs[i], address(this), fromERC20s.amounts[i]);
        }

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < toAmounts.length; i++) {
            totalAmount = totalAmount.add(toAmounts[i]);
        }

        // WETH -> Eq. ERC20
        _swapETHForExactERC20(nftToErc20[toNft], address(this), totalAmount*NFT20_NFT_VALUE);

        // Eq. ERC20 -> ERC1155
        _swapERC20EquivalentForNFTViaNft20(
            nftToErc20[toNft],
            toIds,
            toAmounts,
            msg.sender
        );

        // Return the dust in changeIn asset if ETH balance is greater than 0
        if(address(this).balance > 0) {
            if(changeIn != ETH) {
                _swapExactETHForERC20ViaUniswap(changeIn, msg.sender, 0);
            }
            else {
                // Transfer remaining ETH to the msg.sender
                (bool success, ) = msg.sender.call{value:address(this).balance}("");
                require(success, "swapERC20ForERC1155: ETH dust transfer failed.");
            }
        }
    }

    function onERC1155Received(
        address,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data // (address[] _decodedAddrs, uint256[] _toIds, uint256[] _toAmounts)
    ) public virtual override returns (bytes4) {
        // return with function selector if data is empty
        if(keccak256(abi.encodePacked((_data))) == keccak256(abi.encodePacked(("")))) {
            return this.onERC1155BatchReceived.selector;
        }

        // decode the swap details
        address[] memory _decodedAddrs; // [toNft, changeIn]
        uint256[] memory _toIds;
        uint256[] memory _toAmounts;

        (_decodedAddrs, _toIds, _toAmounts) = abi.decode(
            _data,
            (address[], uint256[], uint256[])
        );

        // Convert ERC1155 to its ERC20 equivalent
        (address _erc20Address,) = _swapERC1155BatchForERC20EquivalentViaNft20(
            msg.sender,
            _ids,
            _values
        );

        // Check we want to convert to another NFT
        if (_decodedAddrs[0] == address(0)) {
            if (_erc20Address != _decodedAddrs[1]) {
                if(_decodedAddrs[1] == ETH) {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForETH(_erc20Address, _from, IERC20(_erc20Address).balanceOf(address(this)));
                }
                else {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForERC20(_erc20Address, _decodedAddrs[1], _from);
                }
            }
            else {
                IERC20(_decodedAddrs[1]).transfer(_from, IERC20(_decodedAddrs[1]).balanceOf(address(this)));
            }
        } else {
            // convert ERC20 equivalent to desired ERC20 equivalent
            _swapExactERC20ForERC20(_erc20Address, nftToErc20[_decodedAddrs[0]], address(this));

            // convert desired ERC20 equivalent to desired NFTs
            _swapERC20EquivalentForNFTViaNft20(
                nftToErc20[_decodedAddrs[0]],
                _toIds,
                _toAmounts,
                _from
            );

            // Handle special cases where we cannot directly send NFTs to the recipient
            if(
                _decodedAddrs[0] == 0x7CdC0421469398e0F3aA8890693d86c840Ac8931 || // Doki Doki
                _decodedAddrs[0] == 0x89eE76cC25Fcbf1714ed575FAa6A10202B71c26A || // Node Runners
                _decodedAddrs[0] == 0xC805658931f959abc01133aa13fF173769133512    // Chonker Finance
            ) {
                IERC1155(_decodedAddrs[0]).safeBatchTransferFrom(address(this), _from, _toIds, _toAmounts, "");
            }

            // convert remaining desired ERC20 equivalent to desired change
            if (nftToErc20[_decodedAddrs[0]] != _decodedAddrs[1]) {
                if(_decodedAddrs[1] == ETH) {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForETH(nftToErc20[_decodedAddrs[0]], _from, IERC20(nftToErc20[_decodedAddrs[0]]).balanceOf(address(this)));
                }
                else {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForERC20(nftToErc20[_decodedAddrs[0]], _decodedAddrs[1], _from);
                }
            }
            else {
                IERC20(_decodedAddrs[1]).transfer(_from, IERC20(_decodedAddrs[1]).balanceOf(address(this)));
            }
        }

        // return with function selector
        return this.onERC1155BatchReceived.selector;
    }

    function onERC721Received(
        address,
        address _from,
        uint256 _tokenId,
        bytes calldata _data // (address[] _decodedAddrs, uint256[] _toIds, uint256[] _toAmounts)
    ) external virtual override returns (bytes4) {
        // return with function selector if data is empty        
        if(keccak256(abi.encodePacked((_data))) == keccak256(abi.encodePacked(("")))) {
            return this.onERC721Received.selector;
        }
        // decode the swap details
        address[] memory _decodedAddrs; // [toNft, changeIn]
        uint256[] memory _toIds;
        uint256[] memory _toAmounts;

        (
            _decodedAddrs,
            _toIds,
            _toAmounts
        ) = abi.decode(
            _data,
            (address[], uint256[], uint256[])
        );

        uint256[] memory _fromIds = new uint256[](1);
        _fromIds[0] = _tokenId;

        // Convert ERC721 to its ERC20 equivalent
        (address _erc20Address, ) = _swapERC721ForERC20EquivalentViaNft20(
            msg.sender,
            _fromIds
        );

        // Check we want to convert to another NFT
        if (_decodedAddrs[0] == address(0)) {
            if (_erc20Address != _decodedAddrs[1]) {
                if(_decodedAddrs[1] == ETH) {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForETH(_erc20Address, _from, IERC20(_erc20Address).balanceOf(address(this)));
                }
                else {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForERC20(_erc20Address, _decodedAddrs[1], _from);
                }
            }
            else {
                IERC20(_decodedAddrs[1]).transfer(_from, IERC20(_decodedAddrs[1]).balanceOf(address(this)));
            }
        } else {
            // convert ERC20 equivalent to desired ERC20 equivalent
            _swapExactERC20ForERC20(_erc20Address, nftToErc20[_decodedAddrs[0]], address(this));

            // convert desired ERC20 equivalent to desired NFTs
            _swapERC20EquivalentForNFTViaNft20(
                nftToErc20[_decodedAddrs[0]],
                _toIds,
                _toAmounts,
                _from
            );

            // Handle special cases where we cannot directly send NFTs to the recipient
            if(
                _decodedAddrs[0] == 0x7CdC0421469398e0F3aA8890693d86c840Ac8931 || // Doki Doki
                _decodedAddrs[0] == 0x89eE76cC25Fcbf1714ed575FAa6A10202B71c26A || // Node Runners
                _decodedAddrs[0] == 0xC805658931f959abc01133aa13fF173769133512    // Chonker Finance
            ) {
                IERC1155(_decodedAddrs[0]).safeBatchTransferFrom(address(this), _from, _toIds, _toAmounts, "");
            }

            // convert remaining desired ERC20 equivalent to desired change
            if (nftToErc20[_decodedAddrs[0]] != _decodedAddrs[1]) {
                if(_decodedAddrs[1] == ETH) {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForETH(nftToErc20[_decodedAddrs[0]], _from, IERC20(nftToErc20[_decodedAddrs[0]]).balanceOf(address(this)));
                }
                else {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForERC20(nftToErc20[_decodedAddrs[0]], _decodedAddrs[1], _from);
                }
            }
            else {
                IERC20(_decodedAddrs[1]).transfer(_from, IERC20(_decodedAddrs[1]).balanceOf(address(this)));
            }
        }

        // return with function selector
        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        virtual
        override
        view
        returns (bool)
    {
        return interfaceId == this.supportsInterface.selector;
    }

    // Emergency function: In case any ERC20 tokens get stuck in the contract unintentionally
    // Only owner can retrieve the asset balance to a recipient address
    function rescueERC20(address asset, address recipient) onlyOwner external returns(uint256 amountRescued) {
        amountRescued = IERC20(asset).balanceOf(address(this)); 
        IERC20(asset).transfer(recipient, amountRescued);
    }

    // Emergency function: In case any ERC721 tokens get stuck in the contract unintentionally
    // Only owner can retrieve the asset balance to a recipient address
    function rescueERC721(address asset, uint256[] calldata ids, address recipient) onlyOwner external {
        for (uint256 i = 0; i < ids.length; i++) {
            IERC721(asset).transferFrom(address(this), recipient, ids[i]);
        }
    }

    // Emergency function: In case any ERC1155 tokens get stuck in the contract unintentionally
    // Only owner can retrieve the asset balance to a recipient address
    function rescueERC1155(address asset, uint256[] calldata ids, uint256[] calldata amounts, address recipient) onlyOwner external {
        for (uint256 i = 0; i < ids.length; i++) {
            IERC1155(asset).safeTransferFrom(address(this), recipient, ids[i], amounts[i], "");
        }
    }

    receive() external payable {}
}
