// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IEulerBeats {

    /**
     * @dev Function to mint prints from an existing seed. Msg.value must be sufficient.
     * @param seed The NFT id to mint print of
     * @param _owner The current on-chain owner of the seed
     */
    function mintPrint(uint256 seed, address payable _owner)
        external
        payable
        returns (uint256);

    /**
     * @dev Get the number of prints minted for the corresponding seed
     * @param seed The seed/original NFT token id
     */
    function seedToPrintsSupply(uint256 seed)
        external
        view
        returns (uint256);

    /**
     * @dev Function to get print price
     * @param printNumber the print number of the print Ex. if there are 2 existing prints, and you want to get the
     * next print price, then this should be 3 as you are getting the price to mint the 3rd print
     */
    function getPrintPrice(uint256 printNumber) external pure returns (uint256 price);

    function seedToOwner(uint256 seed) external view returns (address owner);

}

contract EulerBeatsMarket {

    address public EULERBEATS = 0x8754F54074400CE745a7CEddC928FB1b7E985eD6;
    address public PRINTINGPRESS = 0x8Cac485c30641ece09dBeB2b5245E24dE4830F27;

    function buyAssetsFromEulerBeatsMarket(uint256[] memory seeds) public {
        for (uint256 i = 0; i < seeds.length; i++) {
            _buyAssetFromEulerBeatsMarket(seeds[i], estimateEulerBeatsAssetPriceInEth(seeds[i]));
        }
    }

    function estimateEulerBeatsAssetPriceInEth(uint256 seed) public view returns(uint256) {
        // Get price to mint the next print
        return IEulerBeats(EULERBEATS).getPrintPrice(IEulerBeats(EULERBEATS).seedToPrintsSupply(seed) + 1);
    }

    function estimateBatchEulerBeatsAssetPriceInEth(uint256[] memory seeds) public view returns(uint256 totalCost) {
        for (uint256 i = 0; i < seeds.length; i++) {
            totalCost += IEulerBeats(EULERBEATS).getPrintPrice(IEulerBeats(EULERBEATS).seedToPrintsSupply(seeds[i]) + 1);
        }
    }

    function _buyAssetFromEulerBeatsMarket(uint256 _seed, uint256 _price) internal {
        bytes memory _data = abi.encodeWithSelector(IEulerBeats(PRINTINGPRESS).mintPrint.selector, _seed, IEulerBeats(EULERBEATS).seedToOwner(_seed));

        (bool success, ) = PRINTINGPRESS.call{value:_price}(_data);
        require(success, "_buyAssetFromEulerBeatsMarket: EulerBeats buy failed.");
    }
}