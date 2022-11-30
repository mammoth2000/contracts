//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

interface ILiquidityDrive {
    function end() external;
    function claimTokens() external;
    function donate() external;

}

