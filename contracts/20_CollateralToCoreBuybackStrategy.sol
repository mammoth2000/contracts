// only abi is replicated
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//interfaces
import "contracts/interfaces/IMammothReserve.sol";
// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/SafeMath.sol";
import "contracts/libs/Admin.sol";

// this contracts sends IVORY to NetworkStack depending on peg and apr

contract CollateralToCoreBuybackStrategy is Whitelist, Adminable {

    // addresses

    address public backedTreasury; // 07_IvoryTreasury
    address public collateralRouter; // pancake router
    address public collateralTreasury; // 10_BUSDTreasury
    address public coreTreasury; // 08_MammothTreasury

    // uint256
    uint256 public apr_precision = 10 * 10^6;
    uint256 public liquidityFrequency;
    uint256 public available;
    uint256 public daily_apr;
    uint256 public lastSweep;
    uint256 public liquidityThreshold;
    
    // bool
    bool public isPaused;
    bool public isAbovePeg;

    // constructor
    constructor (address _backedTreasury,address _collateralRouter,address _collateralTreasury,address _coreTreasury) Ownable() {
        backedTreasury = _backedTreasury;
        collateralRouter = _collateralRouter;
        collateralTreasury = _collateralTreasury;
        coreTreasury = _coreTreasury;
        
    }

    function estimateCollateralToCore(uint256 _collateralAmount) public view returns (uint256 wethAmount, uint256 coreAmount) {
    // Calculate the WETH amount based on the given collateral amount and the WETH price
    // wethAmount = _collateralAmount * wethPrice / collateralRatio;

    // Calculate the Core amount based on the given collateral amount and the WETH amount
    // coreAmount = _collateralAmount * wethAmount;

    //  return (wethAmount, coreAmount);
    }


    function sweep() public {

        // if currentValue > something ?

    }

    function randomNonce() public view returns (uint256) {
        // make it return a random Nonce
    }


    // Update functions

    function updateDailyAPR(uint256 APR) public onlyWhitelisted {
        daily_apr = APR;

    }

    function updateCollateralRouter(address _ROUTER) public onlyWhitelisted {
        collateralRouter = _ROUTER;

    }

    function updateLiquidityThreshold(uint256 THRESHOLD) public onlyWhitelisted {
        liquidityThreshold = THRESHOLD;

    }

    

    function updateRunStatus(bool PAUSED) public onlyWhitelisted {
        isPaused = PAUSED;
    }

}

