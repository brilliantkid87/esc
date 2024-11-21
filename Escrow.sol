// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address payable public seller;
    address payable public buyer;
    address public escrowAgent;
    uint public amount;
    bool public isReleased;
    bool public isRefunded;
    
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }
    State public currentState;
    
    constructor(
        address payable _seller,
        address _escrowAgent
    ) {
        seller = _seller;
        escrowAgent = _escrowAgent;
        currentState = State.AWAITING_PAYMENT;
    }
    
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }
    
    modifier onlyEscrowAgent() {
        require(msg.sender == escrowAgent, "Only escrow agent can call this function");
        _;
    }
    
    modifier inState(State _state) {
        require(currentState == _state, "Invalid state");
        _;
    }
    
    function depositInEscrow() external payable inState(State.AWAITING_PAYMENT) {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        buyer = payable(msg.sender);
        amount = msg.value;
        currentState = State.AWAITING_DELIVERY;
    }
    
    function releaseToSeller() external onlyEscrowAgent inState(State.AWAITING_DELIVERY) {
        currentState = State.COMPLETE;
        isReleased = true;
        seller.transfer(amount);
    }
    
    function refundToBuyer() external onlyEscrowAgent inState(State.AWAITING_DELIVERY) {
        currentState = State.REFUNDED;
        isRefunded = true;
        buyer.transfer(amount);
    }
    
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}