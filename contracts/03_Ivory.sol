// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// interfaces
import "contracts/interfaces/BEP20Basic.sol";

// libs
import "contracts/libs/Whitelist.sol";
import "contracts/libs/BasicToken.sol";
import "contracts/libs/BEP20.sol";
import "contracts/libs/StandardToken.sol";
import "contracts/libs/MintableToken.sol";
import "contracts/libs/BurnableToken.sol";
import "contracts/libs/Admin.sol";

contract IvoryDollar is BurnableToken, Adminable {
    struct Stats {
        uint256 txs;
    }

    string private _name;
    string private _symbol;
    uint8 public constant decimals = 18;
    uint256 public constant MAX_INT = 2 ** 256 - 1;
    uint256 public constant targetSupply = MAX_INT;
    uint256 public totalTxs;
    uint256 public participants;
    uint256 private mintedSupply_;

    mapping(address => Stats) private stats;

    using SafeMath for uint256;

    /**
     * @dev default constructor
     */
    constructor() Ownable() Adminable() {
        _name = "Ivory";
        _symbol = "IVY";
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Function to mint tokens (onlyOwner)
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) public override returns (bool) {
        //Never fail, just don't mint if over
        require(_amount > 0 && totalSupply_.add(_amount) <= targetSupply);

        //Mint
        super.mint(_to, _amount);

        if (totalSupply_ == targetSupply) {
            mintingFinished = true;
            emit MintFinished();
        }

        /* Members */
        if (stats[_to].txs == 0) {
            participants += 1;
        }

        stats[_to].txs += 1;
        totalTxs += 1;

        return true;
    }

    /** @dev Transfers (using transferFrom) */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        require(super.transferFrom(_from, _to, _value));

        /* Members */
        if (stats[_to].txs == 0) {
            participants += 1;
        }

        stats[_to].txs += 1;
        stats[_from].txs += 1;

        totalTxs += 1;

        return true;
    }

    /** @dev Transfers */
    function transfer(
        address _to,
        uint256 _value
    ) public override(BEP20Basic, BasicToken) returns (bool) {
        require(super.transfer(_to, _value));

        /* Members */
        if (stats[_to].txs == 0) {
            participants += 1;
        }

        stats[_to].txs += 1;
        stats[msg.sender].txs += 1;

        totalTxs += 1;

        return true;
    }

    /** @dev Returns the supply still available to mint */
    function remainingMintableSupply() public view returns (uint256) {
        return targetSupply.sub(totalSupply_);
    }
}
