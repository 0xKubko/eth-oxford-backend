// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CharityVault} from "../src/CharityVault.sol";
import {MockETH} from "../src/MockETH.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract Deploy is Script {
    uint256 privateKey;
    address deployerAddress;
    MockETH mockETH;
    CharityVault charityVault;
    address charityAddress;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        mockETH = MockETH(vm.envAddress("MOCK_ETH_ADDRESS"));
        charityVault = CharityVault(vm.envAddress("CHARITY_VAULT_ADDRESS"));
        charityAddress = vm.envAddress("CHARITY_ADDRESS");
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
    }

    function run() public {
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        vm.startBroadcast(privateKey);

        charityVault.setCharityAddress(charityAddress);

        vm.stopBroadcast();

        console.log(
            "CharityVault charityAddress: ",
            charityVault.charityAddress()
        );
    }
}