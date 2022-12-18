
// only abi is replicated
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// libs
import "contracts/libs/SafeMath.sol";

// interfaces
import "contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/interfaces/IUniswapV2Router02.sol";
import "contracts/interfaces/Token.sol";

// this contracts sends IVORY to NetworkStack depending on peg and apr

contract MammothRouterProxy is Ownable  {

    address public collateralRouter;
    address public raffle;
    address public referralData;

    address private Mammoth;
    address private WETH;
    address private Ivory;
    address private Busd;
        address private factory;

    bool public isPaused;

    uint256 public precision = 1000;
    uint256 public referralFee = 5;
    uint256 public processingFee = 85;
    uint256 public transferFee = 35;

function swapExactETH(uint256 AMOUNTOUTMIN, address TO) public {
    // Step 1: Obtain the Uniswap V2 Router contract address
    IUniswapV2Router02 router = IUniswapV2Router02(collateralRouter);


}

function swapExactTokens(uint256 AMOUNTIN,  uint256 AMOUNTOUTMIN, address TO  )public {
    // Step 1: Obtain the Uniswap V2 Router contract address
    IUniswapV2Router02 router = IUniswapV2Router02(collateralRouter);


}

function transferExactTokens(uint256 AMOUNT, address TO)public {



}

  // Update the collateral router address
  function updateCollateralRouter(address _ROUTER) public onlyOwner {
    collateralRouter = _ROUTER;
  }

  // Update the processing fee
  function updateProcessingFee(uint256 FEE) public onlyOwner {
    processingFee = FEE;
  }

  // Update the raffle address
function updateRaffle(address RAFFLEADDRESS) public onlyOwner {
  raffle = RAFFLEADDRESS;
}

  // Update the referral data
function updateReferralData(address REFERRALDATAADDRESS) public onlyOwner {
  referralData = REFERRALDATAADDRESS;
}

  // Update the run status
function updateRunStatus(bool PAUSED) public onlyOwner {
  isPaused = PAUSED;
}

  // Update the transfer fee
function updateTransferFee(uint256 FEE) public onlyOwner {
  transferFee = FEE;
}
}

