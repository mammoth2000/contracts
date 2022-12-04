//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

//@dev Callback function called by FarmEngine.yield upon completion
interface IReferralReport {
    function reward_distribution(address _referrer, address _user, uint _referrer_reward, uint _user_reward) external;

}

//@dev Simple struct that tracks asset balances and last time of interaction
struct User {
    //Deposit Accounting
    uint256 assetBalance; //paired asset balance
    uint256 balance; //TRUNK balance
    uint256 payouts; //gross yield payouts
    uint256 last_time; //lat time of interaction which is used for yield calculations
}

//@dev Tracks summary information for users across all farms
struct UserSummary {
    bool exists; //has the user joined a farm
    uint current_balance; //current TRUNK balance
    uint payouts;  //total yield payouts across all farms
    uint rewards; //partner rewards
    uint last_time; //last interaction
}

//@dev Farm struct that tracts net asset balances / payouts 
struct Farm {
    address asset; //core asset
    address treasury; // private asset treasury
    uint256 bonusLevel; // yield bonus 1 -10
    uint256 assetBalance; // core asset balance
    uint256 balance; // TRUNK balance
    uint256 payouts; // yield payouts in TRUNK
    bool useWBNB; // if true, use WBNB in the route for asset pricing
}

struct Sponsorship {
    uint256 pending;
    uint256 total;
}
