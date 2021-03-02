import pytest
from brownie import *
from eth_abi import encode_abi
import typer

@pytest.fixture(scope="module", autouse=True)
def loadAssets(user):
    pass

# ETH -> ERC721
def test_ETH_to_ERC721():
    pass

# ETH -> ERC20
def test_ETH_to_ERC20():
    pass

# ETH -> ERC721
def test_ETH_to_ERC721():
    pass
