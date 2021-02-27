// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFTX {
    function mint(
        uint256 vaultId,
        uint256[] memory nftIds,
        uint256 d2Amount
    ) external payable;

    function redeem(
        uint256 vaultId,
        uint256 amount,
        address recipient
    ) external payable;
}

interface IXStore {
    function xTokenAddress(uint256 vaultId) external view returns (address);

    function nftAddress(uint256 vaultId) external view returns (address);
}

contract NftxRouter is Ownable {
    address public constant NFTX = 0xAf93fCce0548D3124A5fC3045adAf1ddE4e8Bf7e;
    address public constant XStore = 0xBe54738723cea167a76ad5421b50cAa49692E7B7;

    function _swapERC721ForERC20ViaNFTX(uint256 _vaultId, uint256 _tokenId)
        internal
        returns (address _erc20Address, uint256 _erc20Amount)
    {
        IERC721(IXStore(XStore).nftAddress(_vaultId)).approve(NFTX, _tokenId);
        uint256[] memory _tokenIds = new uint256[](1);
        _tokenIds[0] = _tokenId;
        INFTX(NFTX).mint(_vaultId, _tokenIds, 0);
    }

    function _swapERC20ForERC721ViaNFTX(
        uint256 _vaultId,
        uint256 _amount,
        address _recipient
    ) internal {
        require(
            _amount > 0,
            "_swapERC20ForERC721ViaNFTX: _amount should be > 0"
        );
        INFTX(NFTX).redeem(_vaultId, _amount, _recipient);
    }

    // function _swapERC1155ForERC20ViaNFTX() internal {}

    // function _swapERC20ForERC1155ViaNFTX() internal {}
}
