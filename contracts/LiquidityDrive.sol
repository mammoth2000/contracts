
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MammothLiquidityDrive is Context, Ownable {
    using SafeMath for uint256;
    using Address for address;


    //FAIR LAUNCH
    uint256 public totalEthDonated;
    mapping (address => uint256) private _ethDonated;
    mapping (address => uint256) private _claimed;
    uint256 public totalClaimableTokens;
    uint256 public totalClaimedTokens;
    uint256 public endedOn;
    uint256 private estimatedPercentageOfSupply;

    IERC20 public token; 

    uint256 public participants;
    uint256 public totalTxs;

    event LiquidityDonation(
        address from,
        uint256 donation
    );

    event TokenClaim(
        address from,
        uint256 tokens
    );


    modifier notLaunched {
        require(endedOn == 0, "Token already succcessfully launched");
        _;
    }

    

    constructor (uint256 _estimatedPercentageOfSupply) public {
        require(_estimatedPercentageOfSupply > 0 && _estimatedPercentageOfSupply <= 35, "estimate not in range"); 

        //get a handle on the token
        token = IERC20(owner());

        //claimable will use an estimate until the drive is over
        estimatedPercentageOfSupply = _estimatedPercentageOfSupply;


    }

     /**
     * @dev Receive function to handle ETH that was send straight to the contract
     */
    receive() external payable {
        require(false, "Do not send funds directly to this contract");
    }


    function  donate() public payable notLaunched returns (uint256) {
        
        require(msg.value >= 0.01 ether, "Minimum donation is 0.1");

        address _sender = _msgSender();
        uint256 _value = msg.value;

        //track participants
        if (_ethDonated[_sender] == 0) {
            participants = participants.add(1);
        }
        
        //add donation
        _ethDonated[_sender] = _ethDonated[_sender].add(_value);
        totalEthDonated = totalEthDonated.add(_value);

        emit LiquidityDonation(_sender, _value);

        totalTxs = totalTxs.add(1);

    }

    function  claimTokens() external returns (uint256) {
        require(endedOn > 0, "Token not launched yet");
        
        address _sender = _msgSender();

        //check if there are tokens to claim
        require(_ethDonated[_sender] > 0, "No donations made prior to launch");
        require(_claimed[_sender] == 0, "This account has already claimed tokens");

        uint256 tokens = availableOf(_sender);
        _claimed[_sender] = tokens;

        //Send the tokens
        token.transfer(_sender, tokens);

        emit TokenClaim(_sender, tokens);

        totalClaimedTokens = totalClaimedTokens.add(tokens);

        totalTxs = totalTxs.add(1);

    } 

    function end() onlyOwner notLaunched external {
        require(token.balanceOf(address(this)) > 0, "Tokens must be transfered to the drive before it can be ended");

        //donations will no longer be processed
        endedOn = block.timestamp;

        //Set the amount of tokens to be distributed
        totalClaimableTokens = token.balanceOf(address(this));

        //transfer eth funds to token, will be used to add liquidity
        address payable tokenAddr = payable(address(token));
        tokenAddr.transfer(address(this).balance);
    }

    function donationsOf(address from) public view returns (uint256) {
        return  _ethDonated[from]; 
    }

    function availableOf(address from) public view returns (uint256) {
        uint256 totalTokens = (totalClaimableTokens > 0) ? totalClaimableTokens : token.totalSupply().mul(estimatedPercentageOfSupply).div(100);
        return (totalEthDonated > 0) ? totalTokens.mul(_ethDonated[from]).div(totalEthDonated) : 0;
    }

    function claimedOf(address from) public view returns (uint256) {
        return _claimed[from];
    }

}

