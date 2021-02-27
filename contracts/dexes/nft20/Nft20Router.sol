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
        nftToErc20[0xc58641ae25d1e368393cad5cce2cca3c80d8fff6] = 0xc7e5e9434f4a71e6db978bd65b4d61d3593e5f27; // Alpaca City
        nftToErc20[0xb32ca105f6cce99074c58b349d095243b6060303] = 0x6fa769eed284a94a73c15299e1d3719b29ae2f52; // BFH Unit
        nftToErc20[0x57c31c042cb2f6a50f3da70ade4fee20c86b7493] = 0xb80fbf6cdb49c33dc6ae4ca11af8ac47b0b4c0f3; // Block Art
        nftToErc20[0x5e8da1dae500ff338a2fa66b66c9611288d3f4a7] = 0x2f2d5aa0efdb9ca3c9bb789693d06bebea88792f; // Block Cities
        nftToErc20[0xadbebbd65a041e3aeb474fe9fe6939577eb2544f] = 0xc805658931f959abc01133aa13ff173769133512; // CHONKER20
        nftToErc20[0xf395f74ca8f7ad4a1f98bbc92cf9a80be1c7b098] = 0x155cbbca1ab35eab09b66270046317803919e555; // CryptoTendies
        nftToErc20[0x27109ac6b0cc8da16b30a7bea826091797cdf36c] = 0xa58b5224e2fd94020cb2837231b2b0e4247301a6; // Crypto Vexels Wearables
        nftToErc20[0x1e0cd9506d465937e9d6754e76cd389a8bd90fbf] = 0xf87e31492faf9a91b02ee0deaad50d51d56d5d4d; // DECENTRALAND
        nftToErc20[0x22c4ad011cce6a398b15503e0ab64286568933ed] = 0x7cdc0421469398e0f3aa8890693d86c840ac8931; // dokidoki20
        nftToErc20[0x21993ed38dcbb8e1612f34676a3d249b5de538a0] = 0x33b83b6d3179dcb4094c685c2418cab06372ed89; // ETH-MEN
        nftToErc20[0x5b78efdcc5ff2ecc141323491ba194293b955e81] = 0x443b862d3815b1898e85085cafca57fc4335a1be; // Golfer
        nftToErc20[0xc2bde1a2fa26890c8e6acb10c91cc6d9c11f4a73] = 0xc2c747e0f7004f9e8817db2ca4997657a7746928; // Hashmasks
        nftToErc20[0x60acd58d00b2bcc9a8924fdaa54a2f7c0793b3b2] = 0xe4605d46fd0b3f8329d936a8b258d69276cba264; // MEME LTD
        nftToErc20[0x746b9ddf6ddaf05b57f25434d22020f320cf5842] = 0xf9b3b38a458c2512b6680e1f3bc7a022e97d7dab; // MoonBase
        nftToErc20[0x28fa4deb8354f3c4f8d8f7dc095c7ddf5c4ba607] = 0x73e7db3cda787a60a75496ee07078fb11c3a4c88; // NFT20 WRAPLP
        nftToErc20[0x303af77cf2774aabff12462c110a0ccf971d7dbe] = 0x89ee76cc25fcbf1714ed575faa6a10202b71c26a; // NodeRunners
        nftToErc20[0xff22233156b0a4ae0172825e6891887e8f9d2585] = 0xcb6768a968440187157cfe13b67cac82ef6cc5a4; // Pepemon
        nftToErc20[0x4df386e4314644ebc7fb67359b83d17977b41c6d] = 0xba8cdaa1c4c294ad634ab3c6ee0fa82d0a019727; // PolkaPets
        nftToErc20[0xb3cdc594d8c8e8152d99f162cf8f9edfdc0a80a2] = 0xdb68df0e86bc7c6176e6a2255a5365f51113bce8; // ROPE
        nftToErc20[0x7c63164d2e50618c5497ef1e1fbd686e06b7cc12] = 0x5351105753bdbc3baa908a0c04f1468535749c3d; // Rude Boy
        nftToErc20[0x26080d657a8c52119d0973d0c7ffdb25e7b9b219] = 0xa342f5d851e866e18ff98f351f2c6637f4478db5; // Sandbox's assets
        nftToErc20[0x793424220968d59fc1a319d434550982708cf6b6] = 0x629a673a8242c2ac4b7b8c5d8735fbeac21a6205; // SORARE
        nftToErc20[0x6e9ad2f0bd0657c6a168375d21f865e33e8f0112] = 0xf4680c917a873e2dd6ead72f9f433e74eb9c623c; // Twerky Pepe
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
