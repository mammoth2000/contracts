
// only abi is replicated

// SPDX-License-Identifier: Unlicensed

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/libs/SafeMath.sol";

// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/Admin.sol";

pragma solidity ^0.8.17;


// still being reverse engineered
contract Raffle is Whitelist, Adminable  {

    using SafeMath for uint256;

    uint256 public awardPercentage;

    uint256 public constant DISQUALIFIED_ENTRY_AMOUNT = 1;
    uint256 public constant DISQUALIFIED_ENTRY_DUPLICATE = 2;
    uint256 public constant DISQUALIFIED_ENTRY_LATE = 3;
    uint256 public constant QUALIFIED_ENTRY = 4;
    uint256 public roundDuration = 86400;
    uint256 private contractStartTime;

    uint256 public stage = 1;

    uint256 public totalAwarded; // some adding awards
    uint256 public totalRaised; // some adding raised

    bool public isPaused;

    uint256 public minimimumAmount = 4990000000000000000;

    address public sponsorData;

    mapping(address => Participants) public participants;
    mapping(address => Rounds) public rounds;
    mapping(uint256 => address) private getWinners;

    struct Participants {
            uint256 round;
            uint256 currentContribution;
            uint256 totalRounds;
            uint256 totalContribution;
            uint256 totalAwards;
            uint256 wins;
    }

    function add(address PARTICIPANT, uint256 AMOUNT) public onlyWhitelisted {
        // add to the struct participant

        uint256 totalContributionSoFar = participants[PARTICIPANT].totalContribution;
        participants[PARTICIPANT].round = round();
        participants[PARTICIPANT].currentContribution = AMOUNT;
        participants[PARTICIPANT].totalRounds;
        participants[PARTICIPANT].totalContribution = totalContributionSoFar + AMOUNT;
        participants[PARTICIPANT].totalAwards = 0;
    //    participants[PARTICIPANT].wins = winsSoFar; we writing to this at a later point
    //  [p.round, p.currentContribution, p.totalRounds,p.totalContribution,p.totalAwards,p.wins] = [round(),AMOUNT,1,1,1,1 ];
    }
   

    struct Rounds {
            uint256 winner_position;
            address winner;
            address maxWinner;
            uint256 maxContribution;
            uint256 maxThreshold;
            uint256 pot;
            uint256 award;
            uint256 participants;
            uint256 startBlock;
            uint256 startTime;
            uint256 endBlock;
            uint256 endTime;
            uint256 finalBlock;
            uint256 finalTime;
    }

    struct status {
            bool running;
            uint256 currentRound;
            uint256 currentStage;
            uint256 lapsed;
            uint256 pot;
            uint256 award;
            uint256 num_participants; 
            uint256 maxContribution;

    }
    
    constructor (address _sponsorData, uint256 _contractStartTime) Adminable() {
        require(_contractStartTime % roundDuration == 0, "please use midnight UTC timestamp");
        contractStartTime = _contractStartTime;
        sponsorData = _sponsorData;
    }

    function currentReward() public view returns (uint256)  {

    }

    function getWinner(uint256 _ROUND) public view returns (address)  {
        return getWinners[_ROUND];

    }

    function findWinner(uint256 min, uint256 max) internal view {
    // only for testing
    uint256 winnerTicket = min.add(uint256(keccak256(abi.encodePacked(block.timestamp, min, max))) % (max - min));
    }

    function round()public view returns (uint256)  {
        uint256 timeDifference = block.timestamp - contractStartTime;
        uint roundNumber = timeDifference / 86400;
        return roundNumber;
    }


    // write functions


    function updateAwardPercentage(uint256 PERCENT) public onlyAdmin {
        awardPercentage = PERCENT;

    }

    function updateDuration(uint256 PERCENT) public onlyAdmin {
        roundDuration = PERCENT;

    }

    function updateMinimumAmount(uint256 AMOUNT) public onlyAdmin {
        minimimumAmount = AMOUNT;

    }
    function updateRunStatus(bool PAUSED) public onlyAdmin {
        isPaused = PAUSED;

    }

    function updateSponsorData(address SPONSORDATAADDRESS) public onlyAdmin {
        sponsorData = SPONSORDATAADDRESS;

    }

}