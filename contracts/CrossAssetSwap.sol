// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./dexes/nft20/Nft20Router.sol";
import "./dexes/nftx/NftxRouter.sol";
import "./dexes/uniswap/UniswapRouter.sol";

contract CrossAssetSwap is
    IERC721Receiver,
    IERC1155Receiver,
    UniswapRouter,
    Nft20Router,
    NftxRouter
{
    struct ERC20Details {
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
    }

    // bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;
    // bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

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

    function _swapExactERC20ForWETH(
        address _from,
        address _recipient,
        uint256 _amountIn
    )
    internal
        returns (uint256[] memory amount)
    {
        return _swapExactERC20ForWETHViaUniswap(_from, _recipient, _amountIn);
    }

    function _swapWETHForExactERC20(
        address _to,
        address _recipient,
        uint256 _amountOut
    )
    internal
        returns (uint256[] memory amount)
    {
        return _swapWETHForExactERC20ViaUniswap(_to, _recipient, _amountOut);
    }

    function _swapExactERC20ForERC20(address _from, address _to, address _recipient)
        internal
        returns (uint256[] memory amount)
    {
        return _swapExactERC20ForERC20ViaUniswap(_from, _to, _recipient);
    }

    function _swapERC20ForExactERC20(address _from, address _to, address _recipient, uint256 _amountOut)
        internal
        returns (uint256[] memory amount)
    {
        return _swapERC20ForExactERC20ViaUniswap(_from, _to, _recipient, _amountOut);
    }

    // User needs to approve ERC20 tokens
    function swapERC20ForERC721(
        ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        address changeIn
    ) external {
        // ERC20 -> WETH -> Eq. ERC20 -> ERC721
        // Transfer the ERC20s to this contract
        for(uint256 i = 0; i < fromERC20s.tokenAddrs.length; i++) {
            IERC20(fromERC20s.tokenAddrs[i]).transferFrom(msg.sender, address(this), fromERC20s.amounts[i]);
            // ERC20 -> WETH
            _swapExactERC20ForWETH(fromERC20s.tokenAddrs[i], address(this), fromERC20s.amounts[i]);
        }

        // WETH -> Eq. ERC20
        _swapWETHForExactERC20(nftToErc20[toNft], address(this), toIds.length*NFT20_NFT_VALUE);

        uint256[] memory amounts;

         // Eq. ERC20 -> ERC721
        _swapERC20EquivalentForNFTViaNft20(
            nftToErc20[toNft],
            toIds,
            amounts,
            msg.sender
        );

        // Return the dust in changeIn asset if WETH balance is greater than 0
        uint256 _amount = IERC20(WETH).balanceOf(address(this));
        if((changeIn != WETH) && (_amount > 0)) {
            _swapExactERC20ForERC20(WETH, changeIn, msg.sender);
        }
    }

    function swapERC20ForERC1155(
        ERC20Details calldata fromERC20s,
        address toNft,
        uint256[] calldata toIds,
        uint256[] calldata toAmounts,
        address changeIn
        //uint256[] calldata toVaultIds,
    ) external {
        // ERC20 -> WETH -> Eq. ERC20 -> ERC1155
        // Transfer the ERC20s to this contract
        for(uint256 i = 0; i < fromERC20s.tokenAddrs.length; i++) {
            IERC20(fromERC20s.tokenAddrs[i]).transferFrom(msg.sender, address(this), fromERC20s.amounts[i]);
            // ERC20 -> WETH
            _swapExactERC20ForWETH(fromERC20s.tokenAddrs[i], address(this), fromERC20s.amounts[i]);
        }

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < toAmounts.length; i++) {
            totalAmount = totalAmount.add(toAmounts[i]);
        }
        require(totalAmount > 0, "swapERC20ForERC1155: all toAmounts cannot be 0");

        // WETH -> Eq. ERC20
        _swapWETHForExactERC20(nftToErc20[toNft], address(this), totalAmount*NFT20_NFT_VALUE);

        // Eq. ERC20 -> ERC1155
        _swapERC20EquivalentForNFTViaNft20(
            nftToErc20[toNft],
            toIds,
            toAmounts,
            msg.sender
        );

        // Return the dust in changeIn asset if WETH balance is greater than 0
        totalAmount = IERC20(WETH).balanceOf(address(this));
        if((changeIn != WETH) && (totalAmount > 0)) {
            _swapExactERC20ForERC20(WETH, changeIn, msg.sender);
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
        bytes calldata _data // (address _toNft, uint256[] _toIds, uint256[] _toAmounts, address _changeIn)
    ) public virtual override returns (bytes4) {
        // return with function selector if data is empty
        if(keccak256(abi.encodePacked((_data))) == keccak256(abi.encodePacked(("")))) {
            return this.onERC1155BatchReceived.selector;
        }

        // decode the swap details
        address[] memory _decodedAddrs;
        uint256[] memory _toIds;
        uint256[] memory _toAmounts;

        (_decodedAddrs, _toIds, _toAmounts) = abi.decode(
            _data,
            (address[], uint256[], uint256[])
        );

        // _changeIn should not be a 0 address
        // WARNING: It is assumed that _changeIn implements ERC20 standard
        //          Possible exploit vector: pass malicious _changeIn
        //          Possible exploit vector: call this function from a malicious address
        require(
            _decodedAddrs[1] != address(0),
            "onERC1155BatchReceived: empty _changeIn address"
        );

        // Convert ERC1155 to its ERC20 equivalent
        (address _erc20Address, ) = _swapERC1155BatchForERC20EquivalentViaNft20(
            msg.sender,
            _ids,
            _values
        );

        // Check we want to convert to another NFT
        if (_decodedAddrs[0] == address(0)) {
            if (_erc20Address != _decodedAddrs[1]) {
                // Convert all the _erc20Amount to _changeIn ERC20
                _swapExactERC20ForERC20(_erc20Address, _decodedAddrs[1], _from);
            }
        } else {
            // Check if we support conversion to the desired NFT
            require(
                nftToErc20[_decodedAddrs[0]] != address(0),
                "onERC1155BatchReceived: cannot convert to desired NFT"
            );

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
                _swapExactERC20ForERC20(nftToErc20[_decodedAddrs[0]], _decodedAddrs[1], _from);
            }
        }

        // return with function selector
        return this.onERC1155BatchReceived.selector;
    }

    //event Bal(string name, uint256 value);

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata data // (address _toNft, uint256 _inputVault, uint256[] _outputVaults, uint256[] _toIds, uint256[] _toAmounts, address _changeIn)
    ) external override returns (bytes4) {
        // return with function selector if data is empty        
        if(keccak256(abi.encodePacked((data))) == keccak256(abi.encodePacked(("")))) {
            return this.onERC721Received.selector;
        }
        // decode the swap details
        address _toNft;
        address _changeIn;
        uint256 _inputVaultId;
        uint256[] memory _outputVaultIds;
        uint256[] memory _toIds;
        uint256[] memory _toAmounts;

        (
            _toNft,
            _inputVaultId,
            _outputVaultIds,
            _toIds,
            _toAmounts,
            _changeIn
        ) = abi.decode(
            data,
            (address, uint256, uint256[], uint256[], uint256[], address)
        );

        require(
            _toIds.length == _toAmounts.length,
            "onERC721Received: invalid data param"
        );

        // _changeIn should not be a 0 address
        // WARNING: It is assumed that _changeIn implements ERC20 standard
        //          Possible exploit vector: pass malicious _changeIn
        //          Possible exploit vector: call this function from a malicious address
        require(
            _changeIn != address(0),
            "onERC1155BatchReceived: empty _changeIn address"
        );

        // Swap via NFTX 
        if(_outputVaultIds.length > 0) {
            // NFT -> eq. ERC20
            _swapERC721ForERC20ViaNFTX(_inputVaultId, tokenId);
            
            // eq. ERC20 -> desired eq. ERC20(s)
            // eq. ERC20 -> ETH -> desired eq. ERC20(s)
            // Try to calculate the exact desired eq. ERC20(s) 
            // to reduce number of desired eq. ERC20 -> change ERC20 swaps
            // IERC20(IXStore(XStore).xTokenAddress(_inputVaultId)).safeApprove(DEX, _bal);
            /**
            loop through all _outputVaultIds
            for (uint256 i=0; i < _outputVaultIds.length; i++) {
                _swapERC20ForExactERC20(
                    IXStore(XStore).xTokenAddress(_inputVaultId),
                    IXStore(XStore).xTokenAddress(_outputVaultIds[i]),
                    from
                    _toAmounts[i]
                );
            }
             */
            
            // desired eq. ERC20 -> NFT(s)
            // FEAT: redeem(uint256[] vaultId, uint256[] amount, address recipient)
            /**
            loop through all _outputVaultIds
            for (i=0; i < _outputVaultIds.length; i++) {
                _swapERC20ForERC721ViaNFTX(_outputVaultIds[i], _toIds[i], recipient);
            }
            */
            
            // desired eq. ERC20 -> change ERC20
            // eq. ERC20(s) -> ETH -> desired eq. ERC20(s)
            /**
            loop through all _outputVaultIds
            _swapExactERC20ForERC20(_outputVaultIds[i], _changeIn, _from);
            */
        }
        // Swap via NFT20
        else {
            _outputVaultIds = new uint256[](1);
            _outputVaultIds[0] = tokenId;

            // Convert ERC1155 to its ERC20 equivalent
            (address _erc20Address, ) = _swapERC721ForERC20EquivalentViaNft20(
                msg.sender,
                _outputVaultIds
            );

            // Check we want to convert to another NFT
            if (_toNft == address(0)) {
                if (_erc20Address != _changeIn) {
                    // Convert all the _erc20Amount to _changeIn ERC20
                    _swapExactERC20ForERC20(_erc20Address, _changeIn, from);
                }
            } else {
                // Check if we support conversion to the desired NFT
                require(
                    nftToErc20[_toNft] != address(0),
                    "onERC1155BatchReceived: cannot convert to desired NFT"
                );

                // convert ERC20 equivalent to desired ERC20 equivalent
                _swapExactERC20ForERC20(_erc20Address, nftToErc20[_toNft], address(this));

                // convert desired ERC20 equivalent to desired NFTs
                _swapERC20EquivalentForNFTViaNft20(
                    nftToErc20[_toNft],
                    _toIds,
                    _toAmounts,
                    from
                );

                // convert remaining desired ERC20 equivalent to desired change
                if (nftToErc20[_toNft] != _changeIn) {
                    _swapExactERC20ForERC20(nftToErc20[_toNft], _changeIn, from);
                }
            }
        }
        // return with function selector
        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        override
        view
        returns (bool)
    {
        return interfaceId == this.supportsInterface.selector;
    }
}
