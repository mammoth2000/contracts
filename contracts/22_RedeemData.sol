
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

contract RedeemData is Whitelist, Adminable  {


    address public jobQueue; // 0x2E31099A9Eb7243EB56Cb106977E61647dcB8F9F see if it changes

    bool public isPaused;

    uint256 public currentRedemptions;
    uint256 public length;
    uint256 public totalRedeemed;

    mapping(uint256 => Job) public jobs;
    mapping(address => uint256) public lastRedeem;
    mapping(address => User) public users;

    struct Job {
        address user;
        uint256 amount;
        uint256 blockNum;
        uint256 timestamp;
    }

    struct User {
        uint256 pending;
        uint256 total;
        uint256 lastBlock;
        uint256 lastTimestamp;
        uint256 currentJob;
        uint256 jobs;
    }




    function updateRunStatus(bool PAUSED) public onlyWhitelisted {
        isPaused = PAUSED;

        }

    function peekJob() public view returns (bool active,uint256 jobId,uint256 amount) {

        }
    
    function pending(address _user) public view returns (uint256) {

    }
  

    function position(address _user) public view returns (uint256 first,uint256 pos,uint256 wait) {

        }

    function ready(address _user) public view returns (bool) {

        }
    function addRedeem(address _user, uint256 _amount) public returns (uint256 jobId)
    {

        }

    function dequeueJob() public returns (uint256 jobId, address user, uint256 amount)
        {

        }
}

