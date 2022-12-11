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

contract PegSupportTreasuryStrategy is Whitelist, Adminable  {


    address public backedTreasury; // 07_IvoryTreasury
    address public collateralRouter; // pancake router
    address public collateralTreasury; // 10_BUSDTreasury
    address public coreTreasury; // 08_MammothTreasury
    address public collateralRedemptionPool; // 10_BUSDredemtionPool
    address public redeemData; //22_redeemdata

    uint256 public apr_precision = 10 * 10^6;

    uint256 public daily_apr;
    
    bool public isPaused;


    uint256 public lastSweep;

    uint256 public liquidityThreshold;

    uint256 public maxJobs;

    uint256 constant MAX_JOBS = 200;


    
    constructor (address _redeemData, address _collateralRedemptionPool,address _reserve,address _backedTreasury,address _collateralRouter,address _collateralTreasury,address _coreTreasury) Ownable() {
        backedTreasury = _backedTreasury;
        collateralRouter = _collateralRouter;
        collateralTreasury = _collateralTreasury;
        coreTreasury = _coreTreasury;
        collateralRedemptionPool = _collateralRedemptionPool;
        redeemData = _redeemData;
        
    }

    function estimateCoreToCollateral(uint256 _coreAmount) public view returns (uint256 wethAmount, uint256 collateralAmount) {


      return (wethAmount, collateralAmount);
    }

function available() public view returns (uint256 coreAmount, uint256 collateralAmount){

    

    }

    function sweep() public {

        // if currentValue > something ?

    }

    function updateDailyAPR(uint256 APR) public onlyWhitelisted {
        daily_apr = APR;

    }


    function updateMaxJobs(uint256 JOBS) public onlyWhitelisted {
            maxJobs = JOBS;

        }


    function updateLiquidityThreshold(uint256 THRESHOLD) public onlyWhitelisted {
            liquidityThreshold = THRESHOLD;

        }



    function updateRunStatus(bool PAUSED) public onlyWhitelisted {
    isPaused = PAUSED;

        }

    function updateCollateralRouter(address _ROUTER) public onlyWhitelisted {
    collateralRouter = _ROUTER;

        }

        function updateRedeemData(address REDEEMDATAADDRESS) public onlyWhitelisted {
            redeemData = REDEEMDATAADDRESS;

        }

}

