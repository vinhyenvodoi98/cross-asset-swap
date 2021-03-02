import pytest
from brownie import *
from eth_abi import encode_abi
import typer

@pytest.fixture(scope="module", autouse=True)
def loadAssets(user):
    pass

# ERC20 -> ERC721
def test_ERC20_to_ERC721():
    pass

# ERC20 -> ERC20
def test_ERC20_to_ERC20():
    pass

# ERC20 -> ETH
def test_ERC20_to_ETH():
    pass
