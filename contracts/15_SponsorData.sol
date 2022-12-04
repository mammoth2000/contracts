
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/SafeMath.sol";
import "contracts/interfaces/IReferralReport.sol";

contract SponsorData is Whitelist {
    using SafeMath for uint256;

    mapping(address => Sponsorship) public users;

    uint256 public total_sponsored;

    constructor() Ownable() {}

    function add(address _user, uint256 _amount) external onlyWhitelisted {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        total_sponsored += _amount;
    }

    function settle(address _user) external onlyWhitelisted {
        users[_user].pending = 0;
    }
}