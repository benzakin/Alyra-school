pragma solidity >=0.4.16 <0.7.0;

contract SimpleSorage {
    uint data;

    function set(uint x) public {
            data = x;
    }

    function get() public view returns (uint){
    return data;
    }
}