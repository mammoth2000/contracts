//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/SafeMath.sol";
import "contracts/libs/Initializable.sol";

// interfaces
import "contracts/interfaces/IERC20.sol";
import "contracts/interfaces/IElephantReserve.sol";
import "contracts/interfaces/IElephantPool.sol";

contract ElephantDollarDistributor is Whitelist {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    event onCredit(
        uint256 amount,
        uint256 balance,
        uint256 timestamp
    );
    
    
    event onDebit(
        uint256 amount,
        uint256 balance,
        uint256 timestamp
    );

    uint256 public creditBalance;
    uint256 public lastSweep;
    uint256 public payoutThreshold;
    
    address public backedAddress; //TRUNK Stable coin

    IERC20 public backedToken;
    
    IElephantReserve public reserve;

 
    // Declare a set state variable
    EnumerableSet.AddressSet private poolRegistry;

    constructor (address _backedAddress) Ownable() {
        backedAddress = address(_backedAddress);
        //setup the core tokens
        backedToken = IERC20(backedAddress);
        
        lastSweep = block.timestamp;

    }
    
    function updateReserve(address reserveAddress) onlyOwner public {
        require(reserveAddress != address(0), "Require valid non-zero addresses");
        
        //the main reeserve fore the backed token
        reserve = IElephantReserve(reserveAddress);
        
    }
    
    function updatePayoutThreshold(uint256 threshold) onlyOwner public {
        require(threshold > 1e18, "Minimum requirement is 1e18");
        payoutThreshold = threshold;
    }
    

    function credit(uint256 collateralAmount) onlyWhitelisted public {
         creditBalance = creditBalance.add(collateralAmount);
         
         emit onCredit(collateralAmount,creditBalance, block.timestamp);
    }

    function add(address pool) public onlyOwner {
        require(pool != address(0), "Require valid non-zero addresses");

        //Add will return false if it already exist; lets fail to make sure folks know what they are doing
        require(poolRegistry.add(pool), "Pool already exists; remove before updating configuration");
    }

    function remove(address pool) onlyOwner public {
        require(pool != address(0), "Require valid non-zero addresses");
        require(poolRegistry.remove(pool), "Pool not found");
    }

    function contains(address pool) public view returns (bool) {
        return poolRegistry.contains(pool);
    }  
    
    function available() public view returns (uint) {
        //Calculate daily drip 1%
        uint256 _share = creditBalance.div(100).div(24 hours); //divide the profit by seconds in the day
        uint256 _payout = _share * block.timestamp.sub(lastSweep);  //share times the amount of time elapsed
        
        return _payout;
    }
    
    function dailyEstimate(uint userTokens, uint tokenSupply) public view returns (uint256){
        uint256 share = creditBalance.div(100);

        return (tokenSupply > 0) ? share.mul(userTokens).div(tokenSupply) : 0;
    }

    function sweep() public {
         //balance at the contract is dripped back to pools

        //Calculate daily drip 1%
        uint256 _share = creditBalance.div(100).div(24 hours); //divide the profit by seconds in the day
        uint256 _payout = _share * block.timestamp.sub(lastSweep);  //share times the amount of time elapsed
        
        require(_payout > payoutThreshold, "Not enough payout available");

        //Update balance
        creditBalance = creditBalance.sub(_payout);
        
        emit onDebit(_payout, creditBalance, block.timestamp);
        
        uint length = poolRegistry.length();
        
        //convert paypout to WETH
        reserve.redeemCreditAsBacked(address(this), _payout);
        
        //The payout is whatever WETH is currently available including residual from the last run
        _payout = backedToken.balanceOf(address(this));
        uint _subPayout = _payout.div(length);

        //payout each pool
        for (uint256 i = 0; i < length; i++) {
            payPool(poolRegistry.at(i), _subPayout);
        }
         
        lastSweep = block.timestamp;
    }
    
    function payPool(address pool, uint payout) private {
        IElephantPool creditPool = IElephantPool(pool);
        
        //Need to be able to approve the output token for transfer
        require(backedToken.approve(pool, payout), "Failed to approve payout");
        
        //credit the pool
        creditPool.donatePool(payout);
        
    }
    
}