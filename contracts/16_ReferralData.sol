

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;


contract ReferralData {
    event onReferralUpdate(
        address indexed participant,
        address indexed referrer
    );

    mapping(address => address) private referrals;
    mapping(address => uint256) private refCounts;

    ///@dev Updated the referrer of the participant
    function updateReferral(address referrer) public {
        //non-zero, no self, no duplicate
        require(
            referrer != address(0) &&
                referrer != msg.sender &&
                referrals[msg.sender] != referrer,
            "INVALID ADDRESS"
        );

        address prevReferrer = referrals[msg.sender];

        //decrement previous referrer
        if (prevReferrer != address(0)) {
            if (refCounts[prevReferrer] > 0) {
                refCounts[prevReferrer] = refCounts[prevReferrer] - 1;
            }
        }
        //increment new referrer
        refCounts[referrer] = refCounts[referrer] + 1;

        //update to new
        referrals[msg.sender] = referrer;
        emit onReferralUpdate(msg.sender, referrer);
    }

    ///@dev Return the referral of the sender
    function myReferrer() public view returns (address) {
        return referrerOf(msg.sender);
    }

    //@dev Return true if referrer of user is sender
    function isMyReferral(address _user) public view returns (bool) {
        return referrerOf(_user) == msg.sender;
    }

    //@dev Return true if user has a referrer
    function hasReferrer(address _user) public view returns (bool) {
        return referrerOf(_user) != address(0);
    }

    ///@dev Return the referral of a participant
    function referrerOf(address participant) public view returns (address) {
        return referrals[participant];
    }

    ///@dev Return the referral count of a participant
    function referralCountOf(address _user) public view returns (uint256) {
        return refCounts[_user];
    }
}