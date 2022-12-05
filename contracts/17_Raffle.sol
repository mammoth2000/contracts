
// only abi is replicated

// SPDX-License-Identifier: Unlicensed

import "@openzeppelin/contracts/access/Ownable.sol";

// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/Admin.sol";

pragma solidity ^0.8.17;


// still being reverse engineered
contract Raffle is Whitelist, Adminable  {


    uint256 public awardPercentage;

    uint256 public constant DISQUALIFIED_ENTRY_AMOUNT = 1;
    uint256 public constant DISQUALIFIED_ENTRY_DUPLICATE = 2;
    uint256 public constant DISQUALIFIED_ENTRY_LATE = 3;
    uint256 public constant QUALIFIED_ENTRY = 4;
    uint256 public roundDuration = 86400;
    uint256 public stage = 1;

    uint256 public totalAwarded; // some adding awards
    uint256 public totalRaised; // some adding raised

    bool public isPaused;

    uint256 public minimimumAmount = 4990000000000000000;

    address public sponsorData;






    function currentReward () public view returns (uint256)  {

    }

        function getWinner (uint256 _ROUND) public view returns (uint256)  {
          uint256  winner = 0;
        return winner;

    }

    function round () public view returns (uint256)  {
          uint256  round = 0;
        return round;

    }
   
   
        // rounds(uint256 UINT256) 
        // returns

        // winner_position uint256
        // winner address
        // maxWinner address
        // maxContribution uint256
        // maxThreshold uint256
        // pot uint256
        // award uint256
        // participants uint256
        // startBlock uint256
        // startTime uint256
        // endBlock uint256
        // endTime uint256
        // finalBlock uint256
        // finalTime uint256


        // participants(address ADDRESS) 
        // returns

        // round  uint256
        // currentContribution  uint256
        // totalRounds  uint256
        // totalContribution  uint256
        // totalAwards  uint256
        // wins  uint256


        // status
        // returns

        // running bool
        // currentRound uint256
        // currentStage uint256
        // lapsed unit256
        // pot uint256
        // award uint256
        // num_participants uint256
        // maxContribution uint256


        // write functions --------------------------------------->

    }