
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

contract FlowEngine is Whitelist, Adminable  {

    address public backedToken; // 03_Ivory
    address public backedTreasury; // 07_IvoryTreasury
    address public collateralToken; // BUSD
    address public collateralTreasury; //09_BusdTreasury
    address public flowData; // 18_flowdata
    address public raffle; // 17_Raffle
    address public referralData; // 04_Refferaldata
    address public reserve; // 16_IvoryReserve
    address public sponsorData; // 15_SponsorData

    uint256 public DepositTax;
    uint256 public ExitTax;
    uint256 public sweepThreshold = 100 ether;

    uint256 public rollBalance; // might be a function

    uint256 constant MAX_UINT = 2**256 - 1;
    uint256 public peanutBonus;

    bool public isPaused;

    mapping(address => UserInfo) public userInfo;

    mapping(address => CreditsAndDebits ) public creditsAndDebits ;


    struct CreditsAndDebits {
        uint256 credits;
        uint256 debits;
    }

    struct UserInfo {
        uint256 deposit_time;
        uint256 deposits;
        uint256 payouts;
        uint256 pending_sponsorship;
        uint256 total_sponsorship;
    }


    function claimsAvailable (address _ADDR) public view returns(address){
    
    }

    function contractInfo() public view returns (
    uint256 _total_users,
    uint256 _total_deposited,
    uint256 _total_withdraw,
    uint256 _total_txs,
    uint256 _total_sponsorships
        ) {
            // Retrieve and return the values of the contract state variables

        }

    function payoutOf(address _ADDR) public view returns (uint256 payout, uint256 max_payout) {

    }

    function peggedPayoutOf(address _addr) public view returns (uint256 payout, uint256 max_payout) {

    }
    function scaleBusdByPeg(uint256 amount) public view returns (uint256 scaledAmount) {

    }

    function claim() public {

    }

    function deposit(uint256 _AMOUNT) public {

    }

    function maxPayoutOf(uint256 _AMOUNT) public {

    }

    // called by user
    function peanuts(uint256 _AMOUNT) public {

    }

    function roll() public {
    // deposit pending rewards
    }

    function sponsor(address _ADDR, uint256 _AMOUNT) public {
     // find out the logic behind this   
    }

    function updateFlowData(address FLOWDATAADDRESS) public onlyWhitelisted {
        flowData = FLOWDATAADDRESS;
    }
    function updatePeanutRaffleBonus(uint256 BONUS) public onlyWhitelisted {
        peanutBonus = BONUS;
    }

    function updateRaffle(address RAFFLEADDRESS) public onlyWhitelisted {
    raffle = RAFFLEADDRESS;        
    }

    function updateReferralData(address REFERRALDATAADDRESS) public onlyWhitelisted {
        referralData = REFERRALDATAADDRESS;
    }

    function updateReserve(address RESERVEADDRESS) public onlyWhitelisted {
        reserve = RESERVEADDRESS;
    }


    function updateRunStatus(bool PAUSED) public onlyWhitelisted {
        isPaused = PAUSED;

        }

    function updateSponsorData(address SPONSORDATAADDRESS) public onlyWhitelisted {
        sponsorData = SPONSORDATAADDRESS;
    }
}

