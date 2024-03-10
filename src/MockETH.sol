// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockETH
 * @notice This contract is a mock of the ERC20 token for testing purposes.
 * @dev This contract is a mock of the ERC20 token for testing purposes.
 * @author 0xKubko
 */
contract MockETH is ERC20 {
    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor() ERC20("MockETH", "MockETH") {}

    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints the token to the recipient
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to mint
     */
    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }

    /**
     * @notice Returns the number of decimals used to get its user representation.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}