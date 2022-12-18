// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/libs/Whitelist.sol";
import "contracts/interfaces/Token.sol";

contract Treasury is Whitelist {
    Token public token; // address of the BEP20 token traded on this contract

    //There can  be a general purpose treasury for any BEP20 token
    constructor(address token_addr) Ownable() {
        token = Token(token_addr);
    }

    function withdraw(uint256 _amount) public onlyWhitelisted {
        require(token.transfer(_msgSender(), _amount));
    }
}
