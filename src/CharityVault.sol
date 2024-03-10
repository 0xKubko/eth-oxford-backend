//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC4626} from "solmate/src/tokens/ERC4626.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import {FixedPointMathLib} from "solmate/src/utils/FixedPointMathLib.sol";
import {MockETH} from "./MockETH.sol";
import {SafeTransferLib} from "solmate/src/utils/SafeTransferLib.sol";

/**
 * @title CharityVault
 * @notice This contract enables yield stripping for staked ETH assets to support charity initiatives.
 * @dev This contract is a modified version of ERC4626 contract, with additional functionality to support charity initiatives.
 * @author 0xKubko
 */
contract CharityVault is ERC4626 {
    /**
     * @dev Library: FixedPointMathLib - Provides fixed-point arithmetic for uint256.
     */
    using FixedPointMathLib for uint256;

    /**
     * @dev Library: SafeTransferLib - Provides safe transfer functionality for ERC20 tokens.
     */
    using SafeTransferLib for ERC20;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice A mapping that checks if a user has deposited the token
     */
    mapping(address => uint256) public shareHolder;

    /**
     * @notice Address of the charity
     */
    address public charityAddress;

    /**
     * @notice Address of the asset
     */
    address public assetAddress;

    /**
     * @notice Ratio of assets per share
     */
    uint256 public lastAssetPerShareRatio;

    /**
     * @notice Ratio of user to charity yield
     */
    uint256 public userCharityYieldRatio;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    // todo: add events
    event CharityAddressSet(address indexed charityAddress);

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Contract constructor
     * @param _asset ERC20 Underlying asset
     * @param _name Name of the vault token
     * @param _symbol Symbol of the vault token
     */

    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset, _name, _symbol) {
        assetAddress = address(_asset);
        lastAssetPerShareRatio = 1e18;
        userCharityYieldRatio = 90; // (out of 100) 90% of the yield goes to the user and 10% goes to charity
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Update reward states modifier
     */
    modifier updateReward() {
        harvestYield();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Return the amount of assets per 1 (1e18) share
     * @return uint256 Assets
     */
    function assetsPerShare() public view returns (uint256) {
        return convertToAssets(1e18);
    }

    /**
     * @notice Return the amount of assets in the vault
     * @return uint256 Assets
     */
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /**
     * @notice Return the amount of assets owned by a user
     * @param _user Address of the user
     * @return uint256 Assets
     */
    function totalAssetsOfUser(address _user) public view returns (uint256) {
        return asset.balanceOf(_user);
    }

    /*//////////////////////////////////////////////////////////////
                            MUTATING FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Set the charity address
     * @param _charityAddress Address of the charity
     */
    function setCharityAddress(address _charityAddress) public {
        require(_charityAddress != address(0), "Zero Address");
        charityAddress = _charityAddress;
    }

    /**
     * @notice Set the user to charity yield ratio
     * @param _userCharityYieldRatio Ratio of user to charity yield
     */
    function setUserCharityYieldRatio(uint256 _userCharityYieldRatio) public {
        require(_userCharityYieldRatio <= 100, "Out of Range");
        userCharityYieldRatio = _userCharityYieldRatio;
    }

    /**
     * @notice Helper function to artificially inflate underlying asset balance to facilitate the demonstration of the yield stripping
     */
    function speedrunYield() public {
        MockETH mockETH = MockETH(assetAddress);
        mockETH.mint(address(this), 500000000);
    }

    /**
     * @notice Function to harvest the yield and transfer it to the charity address
     */
    function harvestYield() public {
        require(charityAddress != address(0), "Charity Address not set");
        require(asset.balanceOf(address(this)) > 0, "No assets to harvest");
        require(this.totalSupply() > 0, "No shares to harvest");

        // calculate the new assets to yield ratio
        uint256 newlastAssetPerShareRatio = assetsPerShare();

        // calculate the yield
        uint256 yield = ((
            (newlastAssetPerShareRatio - lastAssetPerShareRatio).divWadDown(
                newlastAssetPerShareRatio
            )
        ) * asset.balanceOf(address(this))) / 1e18;

        // update the assets to yield ratio
        lastAssetPerShareRatio = newlastAssetPerShareRatio;

        // transfer the yield to the charity address
        asset.safeTransfer(
            charityAddress,
            (yield * (100 - userCharityYieldRatio)) / 100
        );
    }

    /**
     * @notice function to deposit assets and receive vault tokens in exchange
     * @param _assets amount of the asset token
     */
    function _deposit(uint _assets) public {
        // checks that the deposited amount is greater than zero.
        require(_assets > 0, "Deposit less than Zero");
        // calling the deposit function from the ERC-4626 library to perform all the necessary functionality
        deposit(_assets, msg.sender);
        // Increase the share of the user
        shareHolder[msg.sender] += _assets;
    }

    /**
     * @notice Function to allow msg.sender to redeem their deposit plus accrued interest
     * @param _shares amount of shares the user wants to convert
     * @param _receiver address of the user who will receive the assets
     */
    function _withdraw(uint _shares, address _receiver) public {
        // checks that the deposited amount is greater than zero.
        require(_shares > 0, "withdraw must be greater than Zero");
        // Checks that the _receiver address is not zero.
        require(_receiver != address(0), "Zero Address");
        // checks that the caller is a shareholder
        require(shareHolder[msg.sender] > 0, "Not a share holder");
        // checks that the caller has more shares than they are trying to withdraw.
        require(shareHolder[msg.sender] >= _shares, "Not enough shares");
        // calling the redeem function from the ERC-4626 library to perform all the necessary functionality
        redeem(_shares, _receiver, msg.sender);
        // Decrease the share of the user
        shareHolder[msg.sender] -= _shares;
    }
}
