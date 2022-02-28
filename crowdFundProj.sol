// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract croudFund
{
    mapping(address=>uint) public contributors; 
    address public Manager; 
    uint public mimContribution;
    uint public Deadline;
    uint public RaisedAmount;
    uint public Target;
    uint public NumOfcontributor;

    constructor (uint _target, uint _deadline)
    {
        Target = _target;
        Deadline = block.timestamp + _deadline; 
        Manager = msg.sender;
        mimContribution = 100 wei;
    }

    function Send_Eth() public payable
    {
        require(block.timestamp < Deadline, "Check if Deadline for contribution has passed");
        require(msg.value <= mimContribution, "value should be more tham mim contribution value");

        if(contributors[msg.sender]==0)
        {
            NumOfcontributor++;
        }

        contributors[msg.sender] += msg.value;
        RaisedAmount +=msg.value; 
    }

    function GetContractBalanve() public view returns(uint)
    {
        return address(this).balance;  
    }

    function Refund() public 
    {
        //Condition 1. if Dedline passed and required amount not collected
        
    }
}
