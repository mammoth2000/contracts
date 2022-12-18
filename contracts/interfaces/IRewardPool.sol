//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface IRewardPool {
    function credit(uint256 collateralAmount) external;

    function sweep() external;

    function creditBalance() external returns (uint256);
}
