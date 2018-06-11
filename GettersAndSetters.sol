pragma solidity ^0.4.0;

/*
**  Basic getters and setters
*/
contract GettersAndSetters {
    uint age = 24;
	string name = "Osman";

	function getAge() public view returns (uint) {
        return age;
    }
    
    function getName() public view returns (string) {
        return name;
    }
    
    function setAge (uint _age) public {
        age = _age;
    }
    
    function setName(string _name) public {
        name = _name;
    }
}
