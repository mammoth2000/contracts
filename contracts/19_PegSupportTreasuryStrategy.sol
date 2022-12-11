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

contract IVORYBackedPool is Whitelist, Adminable  {

    address public reserve; // 16_IvoryReserve
    address public backedTreasury; // 07_IvoryTreasury
    address public collateralRouter; // pancake router
    address public collateralTreasury; // 10_BUSDTreasury
    address public coreTreasury; // 08_MammothTreasury

    uint256 public apr_precision = 10 * 10^6;
    uint256 public available;
    uint256 public daily_apr;
    
    bool public isPaused;
    
    bool public isAbovePeg;

    uint256 public lastSweep;

    uint256 public liquidityThreshold;


    
    constructor (address _reserve,address _backedTreasury,address _collateralRouter,address _collateralTreasury,address _coreTreasury) Ownable() {
        reserve = _reserve;
        backedTreasury = _backedTreasury;
        collateralRouter = _collateralRouter;
        collateralTreasury = _collateralTreasury;
        coreTreasury = _coreTreasury;
        
    }

    function estimateCoreToCollateral(uint256 _coreAmount) public view returns (uint256 wethAmount, uint256 collateralAmount) {
      // Calculate the WETH amount based on the given Core amount
     // wethAmount = _coreAmount * wethPrice;

      // Calculate the collateral amount based on the given Core amount and the WETH amount
     // collateralAmount = _coreAmount * collateralRatio / wethAmount;

      return (wethAmount, collateralAmount);
    }


    function sweep() public {

        // if currentValue > something ?

    }

    function updateDailyAPR(uint256 APR) public onlyWhitelisted {
        daily_apr = APR;

    }

    function updateReserve(address RESERVEADDRESS) public onlyWhitelisted {
            reserve = RESERVEADDRESS;

        }

    function updateLiquidityThreshold(uint256 THRESHOLD) public onlyWhitelisted {
            liquidityThreshold = THRESHOLD;

        }


    function updateRunStatus(bool PAUSED) public onlyWhitelisted {
    isPaused = PAUSED;

        }


}

