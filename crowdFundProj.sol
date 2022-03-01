// SPDX-License-Identifier: GPL-3.0

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

    // Declaring struct for requesting crowd funds
    struct REQUEST
    {
        string Description; // description of request or Cause for fund raise
        address payable recipient; // whom it will go (in which account)
        uint value; // Targeted amount to collect
        bool Completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>REQUEST) public request; // mapping ith struc t 
    uint public noOfRequests; 

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
        require(msg.value >= mimContribution, "value should be more tham mim contribution value");

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
        require(block.timestamp > Deadline && RaisedAmount < Target, "Not eligible for Refund");
        require(contributors[msg.sender] > 0,"check if contributor really send money");
        address payable user = payable(msg.sender);  // create new variable of payable type to make sue of 'transfer' function
        user.transfer(contributors[msg.sender]); // Refund whaever amount sent by contributor
        contributors[msg.sender] = 0; // clear contributor addess amount after refund
    }

    modifier onlyManager()
    {
        require (msg.sender == Manager, "Only Manager can call this fucntion");
        _; // this syntax required for modifier body
    }

    // Manager will access below function to decide for which request to raise fund
    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyManager
    {
        REQUEST storage newRequest = request[noOfRequests]; // alwasy use 'Storage' keyword while creating struct instance within function
        noOfRequests++;
        newRequest.Description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.Completed = false;
        newRequest.noOfVoters = 0; 
    }

    // this function getting called by contributors and it will vote for the requests for which they want to transfer fund
    function voteRequest(uint _requestnumber) public
    {
        require(contributors[msg.sender] > 0, "you must be contributor");
        REQUEST storage thisRequest = request[_requestnumber];  
        require(thisRequest.voters[msg.sender] == false, "you have already voted" );
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    // Based on no of votes, below fucntion will decide in whoes favor funding shall go. and only manager can call this function
    function makePAyment(uint _requestNo) public onlyManager 
    {
        require (RaisedAmount >= Target );
        REQUEST storage thisReq = request[_requestNo];
        // to check whether we already send fund to this requestit is already 
        require(thisReq.Completed == false, "this request lready completed");
        // check whether 50% voter has voted, then only transer
        require (thisReq.noOfVoters > NumOfcontributor/2,"MAjority does not support");
        thisReq.recipient.transfer(thisReq.value);
        // mark this request as completed 
        thisReq.Completed = true;
    }
}
