
// only abi is replicated

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// libs
import "contracts/libs/Whitelist.sol";

// interfaces
import "contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/interfaces/IUniswapV2Router02.sol";


contract IvoryReserve_NOT_DONE is Whitelist {

    IUniswapV2Router02 private uniswapV2Router;

    mapping(address => uint256) public claimableBalance;

    address public immutable BUSD;
    address public redeemData;
    address public raffle;
    address public collateralTreasury;
    address public backedTreasury;
    address public collateralRouter;
    address public mintData;

    // max the user can redeem ig
    uint256 public maxRedemption = 1e22;
    
    bool public isPaused;

    // might be public instead of the function
    mapping(address => Mints) private lastMinted;
    uint256 public processingFee;
    
    constructor(address _collateralRouter, address _BUSD) Ownable()  {
    collateralRouter =    _collateralRouter;
    BUSD =  _BUSD;
    uniswapV2Router = IUniswapV2Router02(collateralRouter);

    }

    struct Mints {
        uint256 mintAmount;
        uint256 time;
    }

    function lastMint (address DESTINATION)  public view returns (uint256[2] memory) {
    // redeemdata seems to be a contract that handles redeem queue, there is a contract RedemptionSupportStrategy that is related to this contract
        Mints memory s = lastMinted[DESTINATION];
        uint256[2] memory statArray = [s.mintAmount, s.time];

        return statArray;
    }

    function estimateSwap (uint256 _INPUT)  public view returns (uint256) {

        // some swap calculations going on here

    }

    function estimateMint (uint256 _INPUT)  public view returns (uint256) {

        // some swap calculations going on here, shows as a write function ???

    }

    

    function collateralizationRatio ()  public view returns (uint256) {

        // some calculations going on here

    }


    function available (address DESTINATION)  public view returns (uint256) {
        // some user stats going here
        
    }
    
    function estimateRedemption (uint256 _INPUT)  public view returns (uint256) {

        // some redem calculations going on here
        
    }

    function updateRedeemData(address _redeemData) onlyOwner public {
        require(_redeemData != address(0), "cant be zero address");
        redeemData = _redeemData;
    }

     // there is a raffel, there must be a write to this contract upon mint, raffel is not verified
    function updateRaffle(address _raffle) onlyOwner public {
        require(_raffle != address(0), "cant be zero address");
        raffle = _raffle;
    }

    // seems this is where BUSD is sent to (treasury)
    function updateCollateralTreasury(address _collateralTreasury) onlyOwner public {
        require(_collateralTreasury != address(0), "cant be zero address");
        collateralTreasury = _collateralTreasury;
    }

        // seems this is where BUSD is sent to (treasury)
    function updateBackedTreasury(address _backedTreasury) onlyOwner public {
        require(_backedTreasury != address(0), "cant be zero address");
        backedTreasury = _backedTreasury;
    }


    // mintdata is a seperate contract, no known abi.. assuming it handles who minted when and how much

    function updateMintdata(address _mintData) onlyOwner public {
        require(_mintData != address(0), "cant be zero address");
        mintData = _mintData;
    }

    // mint does not mint tokens, it sends BUSD to treasury, updates a claimable balance, perhaps it signs the user up to the raffle in this process
    // not sure why the user is not getting tokens upon mint call

    function mint(uint256 _mint) public {
        ERC20(BUSD).transfer(collateralTreasury, _mint);
        uint256 previousBalance = claimableBalance[msg.sender];
        claimableBalance[msg.sender] = previousBalance + _mint;
        

        // do test if this method works, update lastMinted struct user mint and time

        Mints memory s = lastMinted[msg.sender];
        s.mintAmount = _mint;
        s.time = block.timestamp;

        // call to raffel contract

    }   

    function claim() public {
        require(claimableBalance[msg.sender] >= 0, "sorry you got no claim");
        claimableBalance[msg.sender] = 0;

        // mint token to user

    }


    // there is no update on original contract, not sure what this fee is for
    function updateProcessingFee(uint256 _processingFee) onlyOwner public {
        processingFee = _processingFee;
    }


  //  function lastMint(address lastMint) public view returns (uint256) {}

    

}