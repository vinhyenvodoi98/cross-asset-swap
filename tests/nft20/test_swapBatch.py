import pytest
from brownie import *
from eth_abi import encode_abi
import typer


@pytest.fixture(scope="module", autouse=True)
def loadAssets(deployer, swapper, blockartNft, blockartIds, memeNft, dai):
    dai.transfer(deployer["from"], 20000*10**18, {'from': '0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643'})
    dai.approve(swapper.address, 20000*10**18, deployer)
    for _id in blockartIds:
        blockartNft.safeTransferFrom("0x31fE8439F34ed04514288a6f0F19f26c647Cd6aD", deployer["from"], _id, {'from': '0x31fE8439F34ed04514288a6f0F19f26c647Cd6aD'})
        blockartNft.approve(swapper.address, _id, deployer)
    memeNft.safeBatchTransferFrom("0x60ACD58d00b2BcC9a8924fdaa54A2F7C0793B3b2", deployer["from"], [1, 27], [700, 226], "", {"from": "0x60ACD58d00b2BcC9a8924fdaa54A2F7C0793B3b2"})
    memeNft.setApprovalForAll(swapper.address, True, deployer)

def test_swapMultiAssetToMultiAsset(swapper, dai, usdc, usdt, tusd, dokiNft, hashmaskNft, hashmaskIds, blockartNft, blockartIds, memeNft, deployer):
    inputERC20s = [[dai.address], [20000*10**18]]
    inputERC721s = [[blockartNft.address, blockartNft.address], blockartIds]
    inputERC1155s = [memeNft.address, [1, 27], [700, 226]]

    outputERC20s = [[usdc.address, usdt.address], [500*10**6,500*10**6]]
    outputERC721s = [[hashmaskNft.address, hashmaskNft.address],[16023, 15929]]
    outputERC1155s = [dokiNft.address, [3841608023549, 3851608024494], [100, 100]]

    changeIn = tusd.address

    swapper.swap(inputERC20s, inputERC721s, inputERC1155s, outputERC20s, outputERC721s, outputERC1155s, changeIn, deployer)

    usdc.balanceOf(deployer['from'].address) == 500*10**6
    usdt.balanceOf(deployer['from'].address) == 500*10**6
    tusd.balanceOf(deployer['from'].address) > 500*10**6

    hashmaskNft.ownerOf(16023) == deployer['from'].address
    hashmaskNft.ownerOf(15929) == deployer['from'].address

    dokiNft.balanceOf(deployer['from'].address, 3841608023549) == 100
    dokiNft.balanceOf(deployer['from'].address, 3851608024494) == 100
