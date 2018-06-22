pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

/*
 * First Practical smart contract for the real world.
 * Handling the case where a company has a certain amount of
 * employees who all have the same sallary,
 * and the company wants to pay all of them
 * at the same time by depositing money to a smart contract.
 * Employees can then withdraw their funds themselves.
 *
 * It is very simple to build more complex behaviour on top of
 * this solution. Ie. if you want to use it in a context where
 * employees have different sallaries, you can just give the
 * Employee struct a "stake" variable that defines the employees
 * stake (in percentage) of the entire pool.
*/
contract EmployeePayout {
    address internal owner;
    uint256 internal balance;
    uint256 internal balancePerEmployee;

    struct Employee {
        string name;
        address ethAddress;
        uint256 amountWeiPaidOut;
    }
    
    Employee[] internal employees;
    
    constructor(uint256 _numEmployees) public payable {
        require(msg.value >= 10 ether, "You need to send at least 10 ETH to initialize this smart contract");
        owner = msg.sender;
        balance = msg.value;
        employees.length = _numEmployees;
        balancePerEmployee = msg.value/_numEmployees;
    }

    /* Modifiers */
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized to do this.");
        _;
    }
    

    modifier isEmployee(address emplAddress, string errorMessage) {
        bool result = false;
        uint i = 0;
        
        while(i < employees.length) {
            if(employees[i].ethAddress == emplAddress){
                result = true;
                break;
            }
            
            i++;
        }
        require(result, errorMessage);
        _;
    }
    
    modifier sufficientBalance(uint256 _amountWeiToSend) {
        uint256 amountWeiLeftForEmployee;
        uint i = 0;

        while(i < employees.length) {
            if(employees[i].ethAddress == msg.sender){
                amountWeiLeftForEmployee = balancePerEmployee - employees[i].amountWeiPaidOut;
                break;
            }
            
            i++;
        }
        
        require(
            amountWeiLeftForEmployee >= _amountWeiToSend
            && balance >= _amountWeiToSend
            && balance != 0
            , "Insufficient balance."
        );
        _;
    }
    
    modifier employeeListIsNotFull() {
        require(
            bytes(employees[employees.length - 1].name).length == 0
            , "Could not add another Employee, list is full-");
        _; 
    }
    
    modifier employeeListIsFull() {
        // Don't tell user that list isn't full
        require(
            bytes(employees[employees.length - 1].name).length != 0
            , "Contract is not ready for payout yet. Try again later.");
        _;
    }
    
    /* Getters */
    function getBalance() public view onlyOwner returns(uint256){
        return balance;
    }

    function getBalancePerEmployee() public view onlyOwner returns(uint256){
        return balancePerEmployee;
    }
    

    function getEmployee(uint index) public view onlyOwner returns(string, address, uint256){
        return (employees[index].name, employees[index].ethAddress, employees[index].amountWeiPaidOut);
    }
    
    function getEmployeeByAddress(address emplAddress) public view 
    onlyOwner 
    isEmployee(emplAddress, "Provided address does not belong to an employee") 
    returns(string, address, uint256){
        uint256 i = 0;
        while(i < employees.length) {
            if(employees[i].ethAddress == emplAddress){
                break;
            }
            
            i++;
        }
        
        return getEmployee(i);
    }
    
    /* Business logic functions */
    function addFunds() public payable onlyOwner {
        balance += msg.value;
        balancePerEmployee += msg.value/employees.length;
    } 
    
    function addEmployee(string _name, address _employeeAddress) public onlyOwner employeeListIsNotFull {
        uint i = 0;
        while(i <employees.length) {
            require(_employeeAddress != employees[i].ethAddress, "Address already exists.");

            if(bytes(employees[i].name).length == 0){
                employees[i] = Employee({
                    name: _name, 
                    ethAddress: _employeeAddress,
                    amountWeiPaidOut: 0
                    
                });
               return;
            }
            
            i++;
        }
    }
    
    event fundsSentSuccesfully(uint256 _amountWei, address _receiver);
    
    function withdrawWei(uint256 _amountWei) public 
    isEmployee(msg.sender, "You are not allowed to withdraw funds from this contract.")
    employeeListIsFull
    sufficientBalance(_amountWei) 
    {
        address receiver = msg.sender;
        
        uint i = 0;
        while(i <employees.length) {
            if(employees[i].ethAddress == msg.sender){
                employees[i].amountWeiPaidOut += _amountWei;
                break;
            }
            
            i++;
        }
        
        balance -= _amountWei;
        
        receiver.transfer(_amountWei);

        emit fundsSentSuccesfully(_amountWei, receiver);
    }
    
}