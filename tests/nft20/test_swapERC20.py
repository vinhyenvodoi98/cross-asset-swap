import pytest
from brownie import *
import typer


@pytest.fixture(scope="module", autouse=True)
def loadAssets(deployer, dai):
    dai.transfer(deployer["from"], 100000*10**18, {'from': '0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643'})

# ERC20 -> ERC721
def test_swapDaiToHashmask(swapper, hashmaskNft, dai, usdc, deployer):    
    fromERC20s = [[dai.address],[10000*10**18]]

    toNft = hashmaskNft.address

    toIds = [16023, 15929]
    toAmounts = [1,1]

    changeIn = usdc.address

    daiBalBefore = dai.balanceOf(deployer['from'])
    usdcBalBefore = usdc.balanceOf(deployer['from'])

    ## perform swap
    dai.approve(swapper.address, fromERC20s[1][0], deployer)
    tx = swapper.swapERC20ForERC721(fromERC20s, toNft, toIds, changeIn, deployer)

    daiBalAfter = dai.balanceOf(deployer['from'])
    usdcBalAfter = usdc.balanceOf(deployer['from'])

    assert daiBalBefore > daiBalAfter
    assert usdcBalAfter > usdcBalBefore

    for i in range(0, len(toIds)):
        assert hashmaskNft.ownerOf(toIds[i]) == deployer['from']

# ERC20 -> ERC1155
def test_swapDaiToMeme(swapper, memeNft, dai, usdc, deployer):
    fromERC20s = [[dai.address],[10000*10**18]]

    toNft = memeNft.address

    toIds = [33, 27]
    toAmounts = [2, 2]

    changeIn = usdc.address

    daiBalBefore = dai.balanceOf(deployer['from'])
    usdcBalBefore = usdc.balanceOf(deployer['from'])

    ## perform swap
    dai.approve(swapper.address, fromERC20s[1][0], deployer)
    tx = swapper.swapERC20ForERC1155(fromERC20s, toNft, toIds, toAmounts, changeIn, deployer)

    daiBalAfter = dai.balanceOf(deployer['from'])
    usdcBalAfter = usdc.balanceOf(deployer['from'])

    assert daiBalBefore > daiBalAfter
    assert usdcBalAfter > usdcBalBefore

    for i in range(0, len(toIds)):
        assert memeNft.balanceOf(deployer['from'], toIds[i]) == toAmounts[i]



