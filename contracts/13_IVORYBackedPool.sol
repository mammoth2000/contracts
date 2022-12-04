// only abi is replicated
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//interfaces
import "contracts/interfaces/IElephantReserve.sol";
// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/SafeMath.sol";

// this contracts sends IVORY to NetworkStack depending on peg and apr

contract IVORYBackedPool  is Ownable {

    address public destination; // network stack
    address public registry; // contract that contains addresses of other contracts

    uint256 public apr_precision = 10 * 10^6;
    uint256 public available;
    uint256 public currentValue;
    uint256 public dailyEstimate;
    uint256 public daily_apr;
    
    bool public isPaused;
    uint256 public lastSweep;
    uint256 public liquidityThreshold;
    uint256 public peggedAvailable;
    uint256 public peggedDailyEstimate;
    
    constructor (address _networkStack) Ownable() {
        destination = _networkStack;
    }

    function scaleByPeg(uint256 AMOUNT)  public view returns (uint256) {

        // some calculations going on here
    }

    function sweep() public {

        // if currentValue > something ?

    }

    function updateDailyAPR(uint256 APR) public {
        daily_apr = APR;

    }

        function updateDestination(address _DESTINATION) public {
        destination = _DESTINATION;

    }

            function updateLiquidityThreshold(uint256 THRESHOLD) public {
        liquidityThreshold = THRESHOLD;

    }

            function updateReserve (address RESERVEADDRESS) public {
                // guessing it is the reserve
        registry = RESERVEADDRESS;

    }

                function updateRunStatus(bool PAUSED) public {

                isPaused = PAUSED;

    }


}

