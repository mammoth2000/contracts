// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// libs
import "contracts/libs/Whitelist.sol";
import "contracts/noui/MammothPoolDistributor.sol";
import "contracts/noui/IvoryDollarDistributor.sol";

// interfaces
import "contracts/interfaces/IERC20.sol";
import "contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/interfaces/IUniswapV2Router02.sol";
import "contracts/interfaces/ITreasury.sol";
import "contracts/interfaces/IMammothPool.sol";
import "contracts/interfaces/IRewardPool.sol";
import "contracts/interfaces/IMammothReserve.sol";

contract BackedForwardingPool is Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public backedAddress; //TRUNK Stable coin

    IERC20 public backedToken;

    constructor(address _backedAddress) Ownable() {
        backedAddress = address(_backedAddress);
        //setup the core tokens
        backedToken = IERC20(backedAddress);
    }

    /// @dev This is how you pump pure "drip" dividends into the system
    function donatePool(uint amount) public {
        require(
            backedToken.transferFrom(msg.sender, address(this), amount),
            "Failed to transfer backed tokens"
        );

        //transfer tokens to the owner, we are done
        backedToken.transfer(owner(), amount);
    }
}
