pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

/*Playing with arrays: 
- Creating array
- Deleting Elements
- adding elements (at first empty spot or to the back of the array)
- Getting elements (single element or whole array)
*/


contract DogeContract {
    uint80 private constant NULL = uint80(0); 

    string[] doges = ["Doggo", "Doge", "wuffie"];
    
    function addDoge (string _dogName) public {
        uint i = 0;
        while(doges.length > i) {
            if(bytes(doges[i]).length == 0){
                doges[i] = _dogName;
               return;
            }
            i++;
        }
        
        addDogeToTheEnd(_dogName);
    }
    
    function addDogeToTheEnd (string _dogName) private {
        doges.push(_dogName);
    }
    
    function deleteDogeByName (string _dogeName) public {
        uint i = 0;
        while(doges.length > i) {
            if (keccak256(doges[i]) == keccak256(_dogeName)){
                deleteDogeByIndex(i);
            }
            i++;
        }
    }
    
    function deleteDogeByIndex (uint _index) public{
        doges = deleteElementFromStringArray(doges, _index);
    }
    
    function deleteElementFromStringArray  (string[] _array, uint _index) pure private returns(string[]){
        delete _array[_index];
        uint i = _index;
        while (_array.length > i && _array.length > i+1){
            _array[i] = _array[i+1];
            delete _array[i+1]; 
            i++;
        }
        
        return _array;
    }
    
    function getDoge (int _index ) public view returns (string) {
        return doges[uint(_index)];
    }
    
    function getAllDoges () public view returns (string[]) {
        return doges;
    }
}