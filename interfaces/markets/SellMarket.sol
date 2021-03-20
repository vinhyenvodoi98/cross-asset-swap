// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface SellMarket {
    function sellERC721ForERC20Equivalent(
        address _fromERC721,
        uint256[] memory _ids
    ) external returns (address _erc20Address, uint256 _erc20Amount);

    function sellERC1155ForERC20Equivalent(
        address _fromERC1155,
        uint256 _id,
        uint256 _amount
    ) external returns (address erc20, uint256 amount);

    function sellERC1155BatchForERC20Equivalent(
        address _fromERC1155,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) external returns (address erc20, uint256 amount);

    function buyNftForERC20Equivalent(
        address _fromERC20,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        address _recipient
    ) external;
}