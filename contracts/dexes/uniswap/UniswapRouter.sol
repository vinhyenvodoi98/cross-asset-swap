// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface Uni {
    function swapExactTokensForTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract UniswapRouter {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public DEX = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function _swapExactERC20ForERC20ViaUniswap(
        address _from,
        address _to,
        address _recipient
    ) internal virtual returns (uint256[] memory amounts) {
        uint256 _bal = IERC20(_from).balanceOf(address(this));
        IERC20(_from).safeApprove(DEX, _bal);

        address[] memory _path = new address[](3);
        _path[0] = _from;
        _path[1] = WETH;
        _path[2] = _to;

        return
            Uni(DEX).swapExactTokensForTokens(
                _bal,
                uint256(0),
                _path,
                _recipient,
                now.add(1800)
            );
    }

    function _swapERC20ForExactERC20ViaUniswap(
        address _from,
        address _to,
        address _recipient,
        uint256 _amountOut
    ) internal virtual returns (uint256[] memory amounts) {
        uint256 _bal = IERC20(_from).balanceOf(address(this));
        IERC20(_from).safeApprove(DEX, _bal);

        address[] memory _path = new address[](3);
        _path[0] = _from;
        _path[1] = WETH;
        _path[2] = _to;

        return
            Uni(DEX).swapTokensForExactTokens(
                _amountOut,
                uint256(0),
                _path,
                _recipient,
                now.add(1800)
            );
    }

    function _swapExactERC20ForETHViaUniswap(
        address _from,
        address _recipient,
        uint256 _amountIn
    ) internal virtual returns (uint256[] memory amounts) {
        uint256 _bal = IERC20(_from).balanceOf(address(this));
        IERC20(_from).safeApprove(DEX, _bal);

        address[] memory _path = new address[](2);
        _path[0] = _from;
        _path[1] = WETH;

        return
            Uni(DEX).swapExactTokensForETH(
                _amountIn,
                0,
                _path,
                _recipient,
                now.add(1800)
            );
    }

    function _swapETHForExactERC20ViaUniswap(
        address _to,
        address _recipient,
        uint256 _amountOut
    ) internal virtual /* returns (uint256[] memory amounts) */ {
        address[] memory _path = new address[](2);
        _path[0] = WETH;
        _path[1] = _to;

        bytes memory _data = abi.encodeWithSelector(Uni(DEX).swapETHForExactTokens.selector, _amountOut, _path, _recipient, now.add(1800));

        (bool success, ) = DEX.call{value:address(this).balance}(_data);
        require(success, "_swapETHForExactERC20ViaUniswap: uniswap swap failed.");
    }

    function _swapExactETHForERC20ViaUniswap(
        address _to,
        address _recipient,
        uint256 _amountOutMin
    ) internal virtual /* returns (uint256[] memory amounts) */ {
        address[] memory _path = new address[](2);
        _path[0] = WETH;
        _path[1] = _to;

        bytes memory _data = abi.encodeWithSelector(Uni(DEX).swapExactETHForTokens.selector, _amountOutMin, _path, _recipient, now.add(1800));

        (bool success, ) = DEX.call{value:address(this).balance}(_data);
        require(success, "_swapExactETHForERC20ViaUniswap: uniswap swap failed.");
    }
}
