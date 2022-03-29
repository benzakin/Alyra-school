// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

contract epargne is Ownable {
    
  // address private owner1;
    uint id;
    mapping(uint=>uint) depots;
    uint time;

    /* constructor()  {
        owner1=msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender==owner1);
        _;
    } */

    function deposit() public payable onlyOwner {
        id ++;
        depots[id]=msg.value;
        if (time==0){
            time=block.timestamp +12 weeks;
        }
    }

    function retraits() public onlyOwner{
        require (block.timestamp >= time, "t'as pas attendu assez");
        (bool sent,) = payable(msg.sender).call{value:address(this).balance}("");
        require (sent, unicode"transfert non effectué");
    }
}