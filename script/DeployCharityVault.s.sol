// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {CharityVault} from "../src/CharityVault.sol";
import {MockETH} from "../src/MockETH.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/src/utils/FixedPointMathLib.sol";

contract DeployCharityVault is Script {
    /**
     * @dev Library: FixedPointMathLib - Provides fixed-point arithmetic for uint256.
     */
    using FixedPointMathLib for uint256;

    function setUp() public {
    }

    function run() public {
        MockETH mockETH = new MockETH();
        mockETH.mint(address(this), 100000000);

        console.log("---------------------------------");
        console.log("mockETH.mint(address(this), 100000000);");
        console.log("MockETH address: ", address(mockETH));
        console.log("MockETH balance: ", mockETH.balanceOf(address(this)));

        CharityVault charityVault = new CharityVault(
            ERC20(address(mockETH)),
            "Fair ETH",
            "FairETH"
        );

        console.log("\n---------------------------------");
        console.log("CharityVault deployed");
        console.log("CharityVault address: ", address(charityVault));

        mockETH.approve(address(charityVault), 100000000);
        charityVault._deposit(100000000);

        console.log("\n---------------------------------");
        console.log("CharityVault deposit");
        console.log(
            "CharityVault balance: ",
            charityVault.balanceOf(address(this))
        );
        console.log(
            "MockETH balance of CharityVault: ",
            mockETH.balanceOf(address(charityVault))
        );
        console.log(
            "MockETH balance of CharityAddress: ",
            mockETH.balanceOf(
                address(0x0c06B6D4EC451987e8C0B772ffcf7F080c46447A)
            )
        );
        console.log(
            "MockETH balance of msg.sender",
            mockETH.balanceOf(address(this))
        );

        // set charity address
        charityVault.setCharityAddress(
            address(0x0c06B6D4EC451987e8C0B772ffcf7F080c46447A)
        );

        console.log("\n---------------------------------");
        console.log("CharityVault setCharityAddress");
        console.log(
            "CharityVault charityAddress: ",
            charityVault.charityAddress()
        );
        console.log("assetsPerShare", charityVault.assetsPerShare());

        charityVault.speedrunYield();

        console.log("\n---------------------------------");
        console.log("CharityVault speedrunYield");
        console.log(
            "CharityVault balance: ",
            charityVault.balanceOf(address(this))
        );
        console.log(
            "MockETH balance of CharityVault: ",
            mockETH.balanceOf(address(charityVault))
        );
        console.log(
            "MockETH balance of CharityAddress: ",
            mockETH.balanceOf(
                address(0x0c06B6D4EC451987e8C0B772ffcf7F080c46447A)
            )
        );
        console.log(
            "MockETH balance of msg.sender",
            mockETH.balanceOf(address(this))
        );

        charityVault.harvestYield();

        console.log("assetsPerShare", charityVault.assetsPerShare());
        console.log("\n---------------------------------");
        console.log("CharityVault harvestYield");
        console.log(
            "CharityVault balance after harvest: ",
            charityVault.balanceOf(address(this))
        );
        console.log(
            "MockETH balance of CharityVault: ",
            mockETH.balanceOf(address(charityVault))
        );
        console.log(
            "MockETH balance of CharityAddress: ",
            mockETH.balanceOf(
                address(0x0c06B6D4EC451987e8C0B772ffcf7F080c46447A)
            )
        );
        console.log(
            "MockETH balance of msg.sender",
            mockETH.balanceOf(address(this))
        );
    }
}
