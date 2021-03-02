import pytest
from brownie import *

@pytest.fixture(scope="module", autouse=True)
def user(deployer):
    return TestSwap.deploy(deployer)
@pytest.fixture(scope="module", autouse=True)
def deployer():
    return {'from': accounts[1]}
@pytest.fixture(scope="module", autouse=True)
def ZERO_ADDRESS():
    return "0x0000000000000000000000000000000000000000"
@pytest.fixture(scope="module", autouse=True)
def ETH_ADDRESS():
    return "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"
@pytest.fixture(scope="module", autouse=True)
def cas(deployer):
    return NFT20Swapper.deploy(deployer)
