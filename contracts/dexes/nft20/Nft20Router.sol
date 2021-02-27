// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFT20Pair {
    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts,
        address recipient
    ) external;

    function withdraw(
        uint256[] calldata _tokenIds,
        uint256[] calldata amounts
    ) external;

    function track1155(uint256 _tokenId) external returns (uint256);
}

contract Nft20Router is Ownable {
    mapping(address => address) public nftToErc20;
    uint256 public NFT20_NFT_VALUE = 100 * 10**18;

    constructor() public {
        // add existing nftToErc20
        nftToErc20[0x7CdC0421469398e0F3aA8890693d86c840Ac8931] = 0x22C4AD011Cce6a398B15503e0aB64286568933Ed; // Doki Doki
        nftToErc20[0x89eE76cC25Fcbf1714ed575FAa6A10202B71c26A] = 0x303Af77Cf2774AABff12462C110A0CCf971D7DbE; // Node Runners
        nftToErc20[0xC805658931f959abc01133aa13fF173769133512] = 0xaDBEBbd65a041E3AEb474FE9fe6939577eB2544F; // Chonker Finance
        nftToErc20[0xb80fBF6cdb49c33dC6aE4cA11aF8Ac47b0b4C0f3] = 0x57C31c042Cb2F6a50F3dA70ADe4fEE20C86B7493; // Block Art
        nftToErc20[0xC2C747E0F7004F9E8817Db2ca4997657a7746928] = 0xc2BdE1A2fA26890c8E6AcB10C91CC6D9c11F4a73; // Hashmask
        nftToErc20[0xe4605d46Fd0B3f8329d936a8b258D69276cBa264] = 0x60ACD58d00b2BcC9a8924fdaa54A2F7C0793B3b2; // MEME
        nftToErc20[0xDb68Df0e86Bc7C6176E6a2255a5365f51113BCe8] = 0xB3CDC594D8C8e8152d99F162cF8f9eDFdc0A80A2; // ROPE
        nftToErc20[0xF87E31492Faf9A91B02Ee0dEAAd50d51d56D5d4d] = 0x1E0CD9506d465937E9d6754e76Cd389A8bD90FBf; // DECENTRALAND
    }

    function addNftToErc20(address nft, address erc20) external onlyOwner {
        require(nft != address(0), "addNftToErc20: empty nft address");
        require(erc20 != address(0), "addNftToErc20: empty erc20 address");
        nftToErc20[nft] = erc20;
    }

    function _swapERC721ForERC20EquivalentViaNft20(
        address _fromERC721,
        uint256[] memory _ids
    ) internal returns (address _erc20Address, uint256 _erc20Amount) {
        require(
            _fromERC721 != address(0),
            "_swapERC721ForERC20EquivalentViaNft20: empty _fromERC721 address"
        );
        require(
            nftToErc20[_fromERC721] != address(0),
            "_swapERC721ForERC20EquivalentViaNft20: supplied _fromERC721 not supported"
        );
        require(
            _ids.length > 0,
            "_swapERC721ForERC20EquivalentViaNft20: empty _ids"
        );
        for (uint256 i = 0; i < _ids.length; i++) {
            IERC721(_fromERC721).safeTransferFrom(
                address(this),
                nftToErc20[_fromERC721],
                _ids[i]
            );
        }
        return (
            nftToErc20[_fromERC721],
            IERC20(nftToErc20[_fromERC721]).balanceOf(address(this))
        );
    }

    function _swapERC1155ForERC20EquivalentViaNft20(
        address _fromERC1155,
        uint256 _id,
        uint256 _amount
    ) internal returns (address erc20, uint256 amount) {
        require(
            _fromERC1155 != address(0),
            "_swapERC1155ForERC20EquivalentViaNft20: empty _fromERC1155 address"
        );
        require(
            nftToErc20[_fromERC1155] != address(0),
            "_swapERC1155ForERC20EquivalentViaNft20: supplied _fromERC1155 not supported"
        );
        IERC1155(_fromERC1155).safeTransferFrom(
            address(this),
            nftToErc20[_fromERC1155],
            _id,
            _amount,
            ""
        );
        return (
            nftToErc20[_fromERC1155],
            IERC20(nftToErc20[_fromERC1155]).balanceOf(address(this))
        );
    }

    function _swapERC1155BatchForERC20EquivalentViaNft20(
        address _fromERC1155,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal returns (address erc20, uint256 amount) {
        require(
            _fromERC1155 != address(0),
            "_swapERC1155BatchForERC20EquivalentViaNft20: empty _fromERC1155 address"
        );
        require(
            nftToErc20[_fromERC1155] != address(0),
            "_swapERC1155BatchForERC20EquivalentViaNft20: supplied _fromERC1155 not supported"
        );
        require(
            _ids.length > 0,
            "_swapERC1155BatchForERC20EquivalentViaNft20: empty _ids"
        );
        IERC1155(_fromERC1155).safeBatchTransferFrom(
            address(this),
            nftToErc20[_fromERC1155],
            _ids,
            _amounts,
            ""
        );
        return (
            nftToErc20[_fromERC1155],
            IERC20(nftToErc20[_fromERC1155]).balanceOf(address(this))
        );
    }

    function _swapERC20EquivalentForNFTViaNft20(
        address _fromERC20,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        address recipient
    ) internal {
        require(
            _fromERC20 != address(0),
            "_swapERC20EquivalentForNFTViaNft20: empty _fromERC20 address"
        );
        require(
            _ids.length > 0,
            "_swapERC20EquivalentForNFTViaNft20: empty _ids"
        );

        if(
            _fromERC20 == 0x22C4AD011Cce6a398B15503e0aB64286568933Ed || // Doki Doki
            _fromERC20 == 0x303Af77Cf2774AABff12462C110A0CCf971D7DbE || // Node Runners
            _fromERC20 == 0xaDBEBbd65a041E3AEb474FE9fe6939577eB2544F    // Chonker Finance
        ) {
            INFT20Pair(_fromERC20).withdraw(_ids, _amounts);                
        }
        else {
            INFT20Pair(_fromERC20).withdraw(_ids, _amounts, recipient);
        }
    }
}
