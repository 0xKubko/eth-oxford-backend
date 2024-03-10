// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CharityVault} from "../src/CharityVault.sol";
import {MockETH} from "../src/MockETH.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract Deploy is Script {
    uint256 privateKey;
    address deployerAddress;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.envAddress("DEPLOYER_ADDRESS");
    }

    function run() public {
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        vm.startBroadcast(privateKey);

        // Deploy MockETH
        MockETH mockETH = new MockETH();
        // Mint some MockETH to the deployer
        mockETH.mint(deployerAddress, 1e18);

        // Deploy CharityVault
        CharityVault charityVault = new CharityVault(
            ERC20(address(mockETH)),
            "Fair ETH",
            "FairETH"
        );

        vm.stopBroadcast();

        console.log("MockETH address: ", address(mockETH));
        console.log("CharityVault address: ", address(charityVault));
        console.log(
            "MockETH balance (deployer): ",
            mockETH.balanceOf(deployerAddress)
        );
    }
}
