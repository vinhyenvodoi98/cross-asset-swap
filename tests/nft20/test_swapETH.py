import pytest
from brownie import *
from eth_abi import encode_abi
import typer


@pytest.fixture(scope="module", autouse=True)
def loadAssets(deployer, eth_bag):
    eth_bag.transfer(deployer['from'], 3000*10**18)

# ETH -> ERC721
def test_swapETHToHashmask(swapper, deployer, dai, hashmaskNft):
    toNft = hashmaskNft.address

    toIds = [15329, 16254]
    changeIn = dai.address

    daiBalBefore = dai.balanceOf(deployer['from'])
    ethBalBefore = deployer['from'].balance()

    # perform swap
    swapper.swapEthForERC721(toNft, toIds, changeIn, {'from': deployer['from'], 'value': 1000*10**18})

    daiBalAfter = dai.balanceOf(deployer['from'])
    ethBalAfter = deployer['from'].balance()

    assert daiBalAfter > daiBalBefore
    assert ethBalBefore > ethBalAfter

    for i in range(0, len(toIds)):
        assert hashmaskNft.ownerOf(toIds[i]) == deployer['from']

# ETH -> ERC1155
def test_swapETHToMeme(swapper, deployer, dai, memeNft):
    toNft = memeNft.address

    toIds = [33, 27]
    toAmounts = [2, 2]

    changeIn = dai.address

    daiBalBefore = dai.balanceOf(deployer['from'])
    ethBalBefore = deployer['from'].balance()

    # perform swap
    swapper.swapEthForERC1155(toNft, toIds, toAmounts, changeIn, {'from': deployer['from'], 'value': 1000*10**18})

    daiBalAfter = dai.balanceOf(deployer['from'])
    ethBalAfter = deployer['from'].balance()

    assert daiBalAfter > daiBalBefore
    assert ethBalBefore > ethBalAfter

    for i in range(0, len(toIds)):
        assert memeNft.balanceOf(deployer['from'], toIds[i]) == toAmounts[i]
