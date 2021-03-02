import pytest
from brownie import *
from eth_abi import encode_abi
import typer

@pytest.fixture(scope="module", autouse=True)
def loadAssets(user, hashmaskIds, hashmaskNft):
    for _id in hashmaskIds:
        hashmaskNft.safeTransferFrom("0xC72AED14386158960D0E93Fecb83642e68482E4b", user.address, _id, {'from': '0xC72AED14386158960D0E93Fecb83642e68482E4b'})

# ERC721 -> ERC721
def test_swapHashmaskToDecentraland(swapper, user, hashmaskIds, hashmaskNft, dai, decentralandNft, MASK20, deployer):
    fromERC721 = hashmaskNft.address
    fromId = hashmaskIds[0]

    toNFT = decentralandNft.address
    toIds = [15329]
    toAmounts = [1]

    changeIn = dai.address
    addrs = [toNFT, changeIn]

    daiBalBefore = dai.balanceOf(user.address)
    assert hashmaskNft.ownerOf(fromId) == user.address

    ## perform swap
    tx = user.swapERC721ForAnyAsset(swapper.address, fromERC721, fromId, toIds, toAmounts, addrs, deployer)

    daiBalAfter = dai.balanceOf(user.address)

    for i in range(0, len(toIds)):
        assert decentralandNft.ownerOf(toIds[i]) == user.address

    assert hashmaskNft.ownerOf(fromId) == MASK20

    assert daiBalAfter > daiBalBefore


# ERC721 -> ERC1155
def test_swapHashmaskToMeme(swapper, user, hashmaskIds, hashmaskNft, dai, memeNft, MASK20, deployer):
    fromERC721 = hashmaskNft.address
    fromId = hashmaskIds[1]

    toNFT = memeNft.address
    toIds = [33, 27]
    toAmounts = [1, 1]

    changeIn = dai.address
    addrs = [toNFT, changeIn]

    daiBalBefore = dai.balanceOf(user.address)
    assert hashmaskNft.ownerOf(fromId) == user.address

    ## perform swap
    tx = user.swapERC721ForAnyAsset(swapper.address, fromERC721, fromId, toIds, toAmounts, addrs, deployer)

    daiBalAfter = dai.balanceOf(user.address)

    for i in range(0, len(toIds)):
        assert memeNft.balanceOf(user.address, toIds[i]) == toAmounts[i]

    assert hashmaskNft.ownerOf(fromId) == MASK20

    assert daiBalAfter > daiBalBefore

# ERC721 -> ERC20
def test_swapHashmaskToDai(swapper, user, hashmaskIds, hashmaskNft, dai, MASK20, ZERO_ADDRESS, deployer):
    fromERC721 = hashmaskNft.address
    fromId = hashmaskIds[2]

    toNFT = ZERO_ADDRESS
    toIds = []
    toAmounts = []

    changeIn = dai.address
    addrs = [toNFT, changeIn]

    daiBalBefore = dai.balanceOf(user.address)
    assert hashmaskNft.ownerOf(fromId) == user.address

    ## perform swap
    tx = user.swapERC721ForAnyAsset(swapper.address, fromERC721, fromId, toIds, toAmounts, addrs, deployer)

    daiBalAfter = dai.balanceOf(user.address)

    assert hashmaskNft.ownerOf(fromId) == MASK20

    assert daiBalAfter > daiBalBefore

# ERC721 -> ETH
def test_swapHashmaskToETH(swapper, user, hashmaskIds, hashmaskNft, ETH_ADDRESS, MASK20, ZERO_ADDRESS, deployer):
    fromERC721 = hashmaskNft.address
    fromId = hashmaskIds[3]

    toNFT = ZERO_ADDRESS
    toIds = []
    toAmounts = []

    changeIn = ETH_ADDRESS
    addrs = [toNFT, changeIn]

    ethBalBefore = user.balance()
    assert hashmaskNft.ownerOf(fromId) == user.address

    ## perform swap
    tx = user.swapERC721ForAnyAsset(swapper.address, fromERC721, fromId, toIds, toAmounts, addrs, deployer)

    ethBalAfter = user.balance()

    assert hashmaskNft.ownerOf(fromId) == MASK20

    assert ethBalAfter > ethBalBefore
