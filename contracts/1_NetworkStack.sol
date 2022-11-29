//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

// libs
import "contracts/libs/SafeMath.sol";

// interfaces
import "contracts/libs/Initializable.sol";
import "contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/interfaces/IUniswapV2Router02.sol";
import "contracts/interfaces/Token.sol";

contract NetworkStack is Ownable, Initializable {

    using SafeMath for uint;

    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with tokens
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    /// @dev Only people with profits
    modifier onlyStronghands {
        require(myDividends() > 0);
        _;
    }


    /*==============================
    =            EVENTS            =
    ==============================*/


    event onLeaderBoard(
        address indexed customerAddress,
        uint256 invested,
        uint256 tokens,
        uint256 soldTokens,
        uint timestamp
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingeth,
        uint256 tokensMinted,
        uint timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethEarned,
        uint timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethReinvested,
        uint256 tokensMinted,
        uint timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethWithdrawn,
        uint timestamp
    );


    event onTransfer(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint timestamp
    );

    event onBalance(
        uint256 balance,
        uint256 timestamp
    );

    event onBuyBack(
        uint256 amount,
        uint256 timestamp
    );

    event onDonation(
        address indexed from,
        uint256 amount,
        uint timestamp
    );

    // Onchain Stats!!!
    struct Stats {
        uint invested;
        uint reinvested;
        uint withdrawn;
        uint rewarded;
        uint contributed;
        uint transferredTokens;
        uint receivedTokens;
        uint xInvested;
        uint xReinvested;
        uint xRewarded;
        uint xContributed;
        uint xWithdrawn;
        uint xTransferredTokens;
        uint xReceivedTokens;
    }


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    /// @dev dividends for token purchase
    uint8 internal entryFee_ = 10;


    /// @dev dividends for token selling
    uint8 internal exitFee_ = 10;

    uint8 internal payoutRate_ = 2;

    uint256 constant internal magnitude = 2 ** 64;

    /*=================================
     =            DATASETS            =
     ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) private tokenBalanceLedger_;
    mapping(address => int256) private payoutsTo_;
    mapping(address => Stats) private stats;

    //on chain referral tracking
    uint256 private tokenSupply_;
    uint256 private profitPerShare_;
    uint256 public totalDeposits;
    uint256 internal lastBalance_;

    uint public players;
    uint public totalTxs;
    uint public dividendBalance_;
    uint public mammothReserve_;
    uint public lastPayout;
    uint public totalClaims;
    uint public totalBuyBack;
    uint public firstBlock;
    uint public firstTimestamp;

    uint256 public balanceInterval = 6 hours;
    uint256 public distributionInterval = 2 seconds;

    address public tokenAddress;
    address public mammothAddress;
    address public graveyardAddress;
    address public router; 

    /* 
    Pancake v2 Mainnet - 0x10ed43c718714eb63d5aa57b78b54704e256024e
    Uniswap v2 Rinkeby Testnet - 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a
    */

    IUniswapV2Router02 public  uniswapV2Router;
    IUniswapV2Router02 public  tokenUniswapV2Router;

    Token private token;
    Token private mammothToken;
    Token private wethToken;
    
    bool public buybackEnabled = true; 



    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/
  //  address public mammothAddress =  address(0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688);
  //  address public graveyardAddress = address(0xF7cC784BD260eafC1193D337fFcEA4D6ddA0dd71);
  //  address public router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

      constructor() Ownable() {
    }


    function initialize(address _tokenAddress, address _tokenRouter, uint8 _fee, uint8 _payout, address _mammothAddress, address _graveyardAddress, address _router)  public initializer {
        require(_tokenAddress != address(0) && _tokenRouter != address(0), "Token and liquidity router must be set");
        require(_fee <= 90 && _payout <= 100, "fee and payout must be properly set, fee <= 90 and payout <= 10");

        mammothAddress =  _mammothAddress;
        graveyardAddress = _graveyardAddress;
        router = _router;

        entryFee_ = _fee;
        exitFee_ = _fee;
        payoutRate_ = _payout;

        tokenAddress = _tokenAddress;
        token = Token(_tokenAddress);

        mammothToken = Token(mammothAddress);

        uniswapV2Router = IUniswapV2Router02(router);
        
        tokenUniswapV2Router = IUniswapV2Router02(_tokenRouter);
        
         //Sanity check router
        require(tokenUniswapV2Router.WETH() == uniswapV2Router.WETH(), "Router is not compatible");
        
        wethToken = Token(uniswapV2Router.WETH());

        lastPayout = block.timestamp;
        firstBlock = block.number;
        firstTimestamp = block.timestamp;
    }

    //Public function 
    function sweep() public {
        if (mammothReserve_ >  0){
                totalBuyBack = totalBuyBack.add(buyback(mammothReserve_));
                mammothReserve_ = 0;
        }
    }
    
    //If enabled  the mammothReserve is funded
    function enableBuyback(bool enable) onlyOwner public {
        buybackEnabled = enable;
    }
    
    function updateTokenRouter(address _tokenRouter) onlyOwner public {
        require(_tokenRouter != address(0), "Router must be set");
        tokenUniswapV2Router = IUniswapV2Router02(_tokenRouter);
        
        //Sanity check router
        require(tokenUniswapV2Router.WETH() == uniswapV2Router.WETH(), "Router is not compatible");
    }

    //Execute the buyback against the router using WETH as a bridge
    function buyback(uint tokenAmount) private returns (uint) {
        address[] memory path;
        bool isWETH = tokenAddress == uniswapV2Router.WETH();
        
        if (!isWETH){
            path = new address[](2);
            path[0] = tokenAddress;
            path[1] = uniswapV2Router.WETH();
            
            //Need to be able to approve the collateral token for transfer against where its liquidity may reside in the future
            //Pancake and others will maintain interfaces for legacy applications
            require(token.approve(address(tokenUniswapV2Router), tokenAmount));
            
            uint initial = wethToken.balanceOf(address(this));
            
            tokenUniswapV2Router.swapExactTokensForTokens(
                tokenAmount,
                0, // accept any amount of Mammoth
                path,
                address(this), //send it here first so we can find out how much MAMMOTH we receieved
                block.timestamp.add(1 minutes)
            );
            
            //update the tokenAmount with the difference in WETH
            tokenAmount = wethToken.balanceOf(address(this)).sub(initial);
            
            
        }
        
        //We always have WETH sourced from the best liquidity pool for the core asset if necessary
        path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = mammothAddress;
       
        //Need to be able to approve the collateral token for transfer
        require(wethToken.approve(address(uniswapV2Router), tokenAmount));

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of Mammoth
            path,
            address(this), //send it here first so we can find out how much MAMMOTH we receieved
            block.timestamp.add(1 minutes)
        );

        //transfer mammoth tokens (buyback)
        uint _balance = mammothToken.balanceOf(address(this));
        mammothToken.transfer(graveyardAddress, _balance);

        emit onBuyBack(_balance, block.timestamp);
        return _balance;

    }


    /// @dev This is how you pump pure "drip" dividends into the system
    function donatePool(uint amount) public returns (uint256) {
        require(token.transferFrom(msg.sender, address(this),amount));
        require(tokenSupply_ > 0, "Must have supply to donate");
    
        //If we just have instant divs, no drip
        if (entryFee_ == 0){
            //Apply divs
            profitPerShare_ = SafeMath.add(profitPerShare_, (amount * magnitude) / tokenSupply_);
        } else {
            dividendBalance_ += amount;
        }

        emit onDonation(msg.sender, amount,block.timestamp);
    }

    /// @dev Converts all incoming eth to tokens for the caller, and passes down the referral addy (if any)
    function buy(uint buy_amount) public returns (uint256)  {
        return buyFor(msg.sender, buy_amount);
    }


    /// @dev Converts all incoming eth to tokens for the caller, and passes down the referral addy (if any)
    function buyFor(address _customerAddress, uint buy_amount) public returns (uint256)  {
        require(token.transferFrom(msg.sender, address(this), buy_amount));
        totalDeposits += buy_amount;
        uint amount = purchaseTokens(_customerAddress, buy_amount);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        //distribute
        distribute();

        return amount;
    }

    /**
     * @dev Fallback function to return any TRX/ETH accidentally sent to the contract
     */
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    /// @dev Converts all of caller's dividends to tokens.
    function reinvest() onlyStronghands public {
        // fetch dividends
        uint256 _dividends = myDividends();
        // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(msg.sender, _dividends);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens, block.timestamp);

        //Stats
        stats[_customerAddress].reinvested = SafeMath.add(stats[_customerAddress].reinvested, _dividends);
        stats[_customerAddress].xReinvested += 1;

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        //distribute
        distribute();
    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw() onlyStronghands public {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends();

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        // lambo delivery service
        token.transfer(_customerAddress,_dividends);

        //stats
        stats[_customerAddress].withdrawn = SafeMath.add(stats[_customerAddress].withdrawn, _dividends);
        stats[_customerAddress].xWithdrawn += 1;
        totalTxs += 1;
        totalClaims += _dividends;

        // fire event
        emit onWithdraw(_customerAddress, _dividends, block.timestamp);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        //distribute
        distribute();
    }


    /// @dev Liquifies tokens to eth.
    function sell(uint256 _amountOfTokens) onlyBagholders public {
        // setup data
        address _customerAddress = msg.sender;

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);


        // data setup
        uint256 _undividedDividends = SafeMath.mul(_amountOfTokens, exitFee_) / 100;
        uint256 _taxedeth = SafeMath.sub(_amountOfTokens, _undividedDividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens + (_taxedeth * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;


        //drip and buybacks
        allocateFees(_undividedDividends);

        // fire event
        emit onTokenSell(_customerAddress, _amountOfTokens, _taxedeth, block.timestamp);

        //distribute
        distribute();
    }

    /**
    * @dev Transfer tokens from the caller to a new holder.
    *  Zero fees
    */
    function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders external returns (bool) {
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // withdraw all outstanding dividends first
        if (myDividends() > 0) {
            withdraw();
        }


        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);



        /* Members
            A player can be initialized by buying or receiving and we want to add the user ASAP
         */
        if (stats[_toAddress].invested == 0 && stats[_toAddress].receivedTokens == 0) {
            players += 1;
        }

        //Stats
        stats[_customerAddress].xTransferredTokens += 1;
        stats[_customerAddress].transferredTokens += _amountOfTokens;
        stats[_toAddress].receivedTokens += _amountOfTokens;
        stats[_toAddress].xReceivedTokens += 1;
        totalTxs += 1;

        // fire event
        emit onTransfer(_customerAddress, _toAddress, _amountOfTokens,block.timestamp);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            block.timestamp
        );

        emit onLeaderBoard(_toAddress,
            stats[_toAddress].invested,
            tokenBalanceLedger_[_toAddress],
            stats[_toAddress].withdrawn,
            block.timestamp
        );

        // ERC20
        return true;
    }


    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current eth stored in the contract
     */
    function totalTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * @dev Retrieve the dividends owned by the caller.
     */
    function myDividends() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress);
    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Retrieve the token balance of any single address.
    function tokenBalance(address _customerAddress) public view returns (uint256) {
        return _customerAddress.balance;
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }


    /// @dev Return the sell price of 1 individual token.
    function sellPrice() public  view returns (uint256) {
        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);

        return _taxedeth;

    }

    /// @dev Return the buy price of 1 individual token.
    function buyPrice() public view returns (uint256) {
        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, entryFee_), 100);
        uint256 _taxedeth = SafeMath.add(_eth, _dividends);

        return _taxedeth;

    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.
    function calculateTokensReceived(uint256 _ethToSpend) public view returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethToSpend, entryFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_ethToSpend, _dividends);
        uint256 _amountOfTokens = _taxedeth;

        return _amountOfTokens;
    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of sell orders.
    function calculateethReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _eth = _tokensToSell;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);
        return _taxedeth;
    }


    /// @dev Stats of any single address
    function statsOf(address _customerAddress) public view returns (uint256[14] memory){
        Stats memory s = stats[_customerAddress];
        uint256[14] memory statArray = [s.invested, s.withdrawn, s.rewarded, s.contributed, s.transferredTokens, s.receivedTokens, s.xInvested, s.xRewarded, s.xContributed, s.xWithdrawn, s.xTransferredTokens, s.xReceivedTokens, s.reinvested, s.xReinvested];
        return statArray;
    }


    function dailyEstimate(address _customerAddress) public view returns (uint256){
        uint256 share = dividendBalance_.mul(payoutRate_).div(100);

        return (tokenSupply_ > 0) ? share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_) : 0;
    }


    function allocateFees(uint fee) private {

        //If no fees lets save time
        if (fee == 0){
            return;
        }

        // 1/5 paid out instantly to Mammoth holders
        uint256 instant = fee.div(5); 

       
        //If buy backs are enabled split the fee
        if (buybackEnabled) {
             
             //add the instant fee to the reserve
            mammothReserve_ = mammothReserve_.add(instant);
            dividendBalance_ = dividendBalance_.add(fee).sub(instant);
        } else {
            //add the entire fee to the dividend balance
            //this only happens when there is an issue with the buy back process.
            //If Pancake upgrades liquidity pools
            dividendBalance_ = dividendBalance_.add(fee); 
        }
        
    }

    function distribute() private {

        if (block.timestamp.safeSub(lastBalance_) > balanceInterval) {
            emit onBalance(totalTokenBalance(), block.timestamp);
            lastBalance_ = block.timestamp;
        }


        if (dividendBalance_ > 0 && SafeMath.safeSub(block.timestamp, lastPayout) > distributionInterval && tokenSupply_ > 0) {

            //A portion of the dividend is paid out according to the rate
            uint256 share = dividendBalance_.mul(payoutRate_).div(100).div(24 hours);
            //divide the profit by seconds in the day
            uint256 profit = share * block.timestamp.safeSub(lastPayout);
            //share times the amount of time elapsed
            dividendBalance_ = dividendBalance_.safeSub(profit);

            //Apply divs
            profitPerShare_ = SafeMath.add(profitPerShare_, (profit * magnitude) / tokenSupply_);

            lastPayout = block.timestamp;
        }

    }



    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    /// @dev Internal function to actually purchase the tokens.
    function purchaseTokens(address _customerAddress, uint256 _incomingeth) internal returns (uint256) {

        /* Members */
        if (stats[_customerAddress].invested == 0 && stats[_customerAddress].receivedTokens == 0) {
            players += 1;
        }

        totalTxs += 1;

        // data setup
        uint256 _undividedDividends = SafeMath.mul(_incomingeth, entryFee_) / 100;
        uint256 _amountOfTokens = SafeMath.sub(_incomingeth, _undividedDividends);

        // fire event
        emit onTokenPurchase(_customerAddress, _incomingeth, _amountOfTokens, block.timestamp);

        // yes we kblock.timestamp that the safemath function automatically rules out the "greater then" equation.
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);


        // we can't give people infinite eth
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ += _amountOfTokens;

        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        //drip and buybacks
        allocateFees(_undividedDividends);

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        // really i kblock.timestamp you think you do but you don't
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_customerAddress] += _updatedPayouts;


        //Stats
        stats[_customerAddress].invested += _incomingeth;
        stats[_customerAddress].xInvested += 1;

        return _amountOfTokens;
    }


}
