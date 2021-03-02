import pytest
from brownie import *
from eth_abi import encode_abi
import typer

@pytest.fixture(scope="module", autouse=True)
def loadAssets(user):
    pass

# ERC721 -> ERC721
def test_ERC721_to_ERC721():
    pass

# ERC721 -> ERC20
def test_ERC721_to_ERC20():
    pass

# ERC721 -> ETH
def test_ERC721_to_ETH():
    pass
