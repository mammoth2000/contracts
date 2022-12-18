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
import "contracts/interfaces/IUniswapV2Factory.sol";
import "contracts/interfaces/IUniswapV2Pair.sol";
import "contracts/interfaces/IUniswapV2Router02.sol";
import "contracts/interfaces/IERC20.sol";
import "contracts/interfaces/IMammothReserve.sol";
import "contracts/interfaces/IMammothPool.sol";

contract MammothPoolDistributor is Whitelist {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Pool {
        address pool;
        address token;
        address router;
    }

    event onCredit(uint256 amount, uint256 balance, uint256 timestamp);

    event onDebit(uint256 amount, uint256 balance, uint256 timestamp);

    uint256 public creditBalance;
    uint256 public payoutThreshold;
    uint256 public lastSweep;

    IERC20 public wethToken;

    IMammothReserve private reserve;
    IUniswapV2Router02 public router;

    address public routerAddress;

    // Declare a set state variable
    EnumerableSet.AddressSet private poolRegistry;
    mapping(address => Pool) private pools;

    //Takes the
    constructor(address _routerAddress) Ownable() {
        //the collateral router can be upgraded in the future
        routerAddress = address(_routerAddress);
        router = IUniswapV2Router02(routerAddress);

        //setup the core tokens
        wethToken = IERC20(router.WETH());

        lastSweep = block.timestamp;
    }

    function updateReserve(address reserveAddress) public onlyOwner {
        require(
            reserveAddress != address(0),
            "Require valid non-zero addresses"
        );

        //the main reeserve fore the backed token
        reserve = IMammothReserve(reserveAddress);
    }

    function updatePayoutThreshold(uint256 threshold) public onlyOwner {
        require(threshold > 1e18, "Minimum requirement is 1e18");
        payoutThreshold = threshold;
    }

    function updateRouter(address _router) public onlyOwner {
        require(_router != address(0), "Router must be set");
        router = IUniswapV2Router02(_router);
    }

    function credit(uint256 collateralAmount) public onlyWhitelisted {
        creditBalance = creditBalance.add(collateralAmount);

        emit onCredit(collateralAmount, creditBalance, block.timestamp);
    }

    function add(
        address pool,
        address token,
        address tokenRouter
    ) public onlyOwner {
        require(
            pool != address(0) &&
                token != address(0) &&
                tokenRouter != address(0),
            "Require valid non-zero addresses"
        );

        //Add will return false if it already exist; lets fail to make sure folks know what they are doing
        require(
            poolRegistry.add(pool),
            "Pool already exists; remove before updating configuration"
        );
        pools[pool].pool = pool;
        pools[pool].token = token;
        pools[pool].router = tokenRouter;
    }

    function remove(address pool) public onlyOwner {
        require(pool != address(0), "Require valid non-zero addresses");
        require(poolRegistry.remove(pool), "Pool not found");
    }

    function contains(
        address pool
    ) public view returns (address token, address tokenRouter) {
        require(poolRegistry.contains(pool), "Registry does not contain pool");
        return (pools[pool].token, pools[pool].router);
    }

    function available() public view returns (uint) {
        //Calculate daily drip 1%
        uint256 _share = creditBalance.div(100).div(24 hours); //divide the profit by seconds in the day
        uint256 _payout = _share * block.timestamp.sub(lastSweep); //share times the amount of time elapsed

        return _payout;
    }

    function sweep() public {
        //balance at the contract is dripped back to pools

        //Calculate daily drip 1%
        uint256 _share = creditBalance.div(100).div(24 hours); //divide the profit by seconds in the day
        uint256 _payout = _share * block.timestamp.sub(lastSweep); //share times the amount of time elapsed

        require(_payout > payoutThreshold, "Not enough payout available");

        //Update balance
        creditBalance = creditBalance.sub(_payout);

        emit onDebit(_payout, creditBalance, block.timestamp);

        uint length = poolRegistry.length();

        //convert paypout to WETH
        reserve.redeemCollateralCreditToWETH(_payout);

        //The payout is whatever WETH is currently available including residual from the last run
        _payout = wethToken.balanceOf(address(this));
        uint _subPayout = _payout.div(length);

        //payout each pool
        for (uint256 i = 0; i < length; i++) {
            payPool(poolRegistry.at(i), _subPayout);
        }

        lastSweep = block.timestamp;
    }

    function payPool(address pool, uint payout) private {
        uint _outputBalance;
        IERC20 outputToken = IERC20(pools[pool].token);
        IMammothPool creditPool = IMammothPool(pool);

        //If we aren't working with the WETH pool lets trade
        if (pools[pool].token != router.WETH()) {
            address[] memory path = new address[](2);

            //We always have WETH sourced from the best liquidity pool for the core asset if necessary
            path[0] = router.WETH();
            path[1] = pools[pool].token;

            //Need to be able to approve the WETH token for transfer
            require(
                wethToken.approve(address(router), payout),
                "Failed to approve wethAmount"
            );

            router.swapExactTokensForTokens(
                payout,
                0, //accept any amount of Elephant
                path,
                address(this), //send it here first so we can find out how much core we receieved
                block.timestamp
            );

            //transfer output tokens (buyback); again it is OK for us to count the entire balance since we aren't meant to hold tokens here
            _outputBalance = outputToken.balanceOf(address(this));
        }
        //If we are servicing the WETH pool lets go!
        else {
            _outputBalance = payout;
        }

        //Need to be able to approve the output token for transfer
        require(
            outputToken.approve(pool, _outputBalance),
            "Failed to approve outputBalance"
        );

        //credit the pool
        creditPool.donatePool(_outputBalance);
    }
}
