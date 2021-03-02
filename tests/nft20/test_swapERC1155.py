import pytest
from brownie import *
from eth_abi import encode_abi
import typer

@pytest.fixture(scope="module", autouse=True)
def loadAssets(user, nodeRunnerNft, memeNft, chonkerNft):
    nodeRunnerNft.safeBatchTransferFrom("0x303Af77Cf2774AABff12462C110A0CCf971D7DbE", user.address, [1, 8], [23, 23], "", {"from": "0x303Af77Cf2774AABff12462C110A0CCf971D7DbE"})
    memeNft.safeBatchTransferFrom("0x60ACD58d00b2BcC9a8924fdaa54A2F7C0793B3b2", user.address, [1, 27], [700, 226], "", {"from": "0x60ACD58d00b2BcC9a8924fdaa54A2F7C0793B3b2"})
    chonkerNft.safeBatchTransferFrom("0xaDBEBbd65a041E3AEb474FE9fe6939577eB2544F", user.address, [9, 10], [10, 500], "", {"from": "0xaDBEBbd65a041E3AEb474FE9fe6939577eB2544F"})


## ERC1155 -> ERC721
def test_swapMemeToHashMask(swapper, user, deployer, memeNft, hashmaskNft, dai, MEME20):
    toNFT = hashmaskNft.address
    changeIn = dai.address
    addrs = [toNFT, changeIn]
    fromIds = [1, 27]
    fromAmounts = [700, 226]
    toIds = [15329, 16254]
    toAmounts = [1,1]

    daiBalBefore = dai.balanceOf(user.address)
    meme1BalBefore = memeNft.balanceOf(user.address, 1)
    meme2BalBefore = memeNft.balanceOf(user.address, 27)

    ## perform swap
    tx = user.swapERC1155ForAnyAsset(swapper.address, memeNft.address, fromIds, fromAmounts, toIds, toAmounts, addrs, deployer)

    daiBalAfter = dai.balanceOf(user.address)
    meme1BalAfter = memeNft.balanceOf(user.address, 1)
    meme2BalAfter = memeNft.balanceOf(user.address, 27)

    for i in range(0, len(toIds)):
        assert hashmaskNft.ownerOf(toIds[i]) == user.address

    for i in range(0, len(fromIds)):
        assert memeNft.balanceOf(MEME20, fromIds[i]) >= fromAmounts[i]
        assert memeNft.balanceOf(user.address, fromIds[i]) == 0

    assert daiBalAfter > daiBalBefore


## ERC1155 -> ERC1155
def test_swapNodeRunnerToDoki(swapper, user, deployer, nodeRunnerNft, dokiNft, dai, NDR20):
    toNFT = dokiNft.address
    changeIn = dai.address
    addrs = [toNFT, changeIn]
    fromIds = [1, 8]
    fromAmounts = [23, 23]
    toIds = [3841608023549, 3851608024494]
    toAmounts = [100, 100]

    daiBalBefore = dai.balanceOf(user.address)
    node1BalBefore = nodeRunnerNft.balanceOf(user.address, 1)
    node2BalBefore = nodeRunnerNft.balanceOf(user.address, 8)

    ## perform swap
    tx = user.swapERC1155ForAnyAsset(
        swapper.address, nodeRunnerNft.address, fromIds, fromAmounts, toIds, toAmounts, addrs, deployer)

    daiBalAfter = dai.balanceOf(user.address)
    node1BalAfter = nodeRunnerNft.balanceOf(user.address, 1)
    node2BalAfter = nodeRunnerNft.balanceOf(user.address, 8)

    for i in range(0, len(toIds)):
        assert dokiNft.balanceOf(user.address, toIds[i]) == toAmounts[i]

    for i in range(0, len(fromIds)):
        assert nodeRunnerNft.balanceOf(NDR20, fromIds[i]) >= fromAmounts[i]
        assert nodeRunnerNft.balanceOf(user.address, fromIds[i]) == 0

    assert daiBalAfter > daiBalBefore

## ERC1155 -> ERC20
def test_swapChonkerToDAI(swapper, user, deployer, chonkerNft, dai, ZERO_ADDRESS, CHONK20):
    toNFT = ZERO_ADDRESS
    changeIn = dai.address
    addrs = [toNFT, changeIn]
    fromIds = [9, 10]
    fromAmounts = [10, 500]
    toIds = []
    toAmounts = []

    daiBalBefore = dai.balanceOf(user.address)
    chonker1BalBefore = chonkerNft.balanceOf(user.address, 1)
    chonker2BalBefore = chonkerNft.balanceOf(user.address, 8)

    ## perform swap
    tx = user.swapERC1155ForAnyAsset(
        swapper.address, chonkerNft.address, fromIds, fromAmounts, toIds, toAmounts, addrs, deployer)

    daiBalAfter = dai.balanceOf(user.address)
    chonker1BalAfter = chonkerNft.balanceOf(user.address, 1)
    chonker2BalAfter = chonkerNft.balanceOf(user.address, 8)

    for i in range(0, len(fromIds)):
        assert chonkerNft.balanceOf(CHONK20, fromIds[i]) >= fromAmounts[i]
        assert chonkerNft.balanceOf(user.address, fromIds[i]) == 0

    assert daiBalAfter > daiBalBefore

## ERC1155 -> ETH
def test_swapDokiToETH(swapper, user, deployer, dokiNft, dai, ZERO_ADDRESS, DOKI20, ETH_ADDRESS):
    toNFT = ZERO_ADDRESS
    changeIn = ETH_ADDRESS
    addrs = [toNFT, changeIn]
    fromIds = [3841608023549, 3851608024494]
    fromAmounts = [100, 100]
    toIds = []
    toAmounts = []

    ethBalBefore = user.balance()
    doki1BalBefore = dokiNft.balanceOf(user.address, 3841608023549)
    doki2BalBefore = dokiNft.balanceOf(user.address, 3851608024494)

    tx = user.swapERC1155ForAnyAsset(
        swapper.address, dokiNft.address, fromIds, fromAmounts, toIds, toAmounts, addrs, deployer)

    ethBalAfter = user.balance()
    doki1BalAfter = dokiNft.balanceOf(user.address, 3841608023549)
    doki2BalAfter = dokiNft.balanceOf(user.address, 3851608024494)

    for i in range(0, len(fromIds)):
        assert dokiNft.balanceOf(DOKI20, fromIds[i]) >= fromAmounts[i]
        assert dokiNft.balanceOf(user.address, fromIds[i]) == 0

    assert ethBalAfter > ethBalBefore

