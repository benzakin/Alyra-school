// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
 
contract Whitelist is Ownable{
    
    enum addressStatus{Default, Blacklist, Whitelist}
    
   mapping(address=> addressStatus) list;
   event Authorized(address _address); // Event
   event Blacklisted(address _address); // Event

 
   function authorize(address _address) public onlyOwner {
       list[_address] = addressStatus.Whitelist;
       emit Authorized(_address); // Triggering event
   }

      function unauthorize(address _address) public onlyOwner {
       list[_address] = addressStatus.Blacklist;
       emit Blacklisted(_address); // Triggering event
   }

      function plebe(address _address) public onlyOwner {
       list[_address] = addressStatus.Default;
   }

   function getStatus(address _address) public view  returns(addressStatus){
       return(list[_address]);
   }
}