
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

    uint256 public total_deposited;
    uint256 public total_txs;
    uint256 public total_users;
    uint256 public total_withdraw;

struct User {
  uint256 deposits;
  uint256 deposit_time;
  uint256 payouts;
}

mapping(address => User) public users;

function total_deposited_add(uint256 _amount) public {
  total_deposited = total_deposited.add(_amount);
}

function total_txs_incr() public {
  total_txs++;
}

function total_users_incr() public {
  total_users++;
}

function total_withdraw_add(uint256 _amount) public onlyWhitelisted {
  total_withdraw = total_withdraw.add(_amount);
}

function user_deposits_add(address _user, uint256 _amount) public onlyWhitelisted {
  users[_user].deposits = users[_user].deposits.add(_amount);
}

function user_deposit_time(address _user) public onlyWhitelisted {
  users[_user].deposit_time = block.timestamp;
}

function user_paypouts_add(address _user, uint256 _amount) public onlyWhitelisted {
  users[_user].payouts = users[_user].payouts.add(_amount);
}

}