pragma solidity ^0.4.24;

contract someContract {
    address owner = msg.sender;
    
    modifier onlyOwner() {
        require(msg.sender == owner, 
        "You are not allowed to do this.");
        _;
    }
    
    function ownedFunction() public view  onlyOwner returns(string) {
        return "Yes, you can do this!";
    }
}