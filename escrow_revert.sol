
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
contract Escrow {
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

    State public currentState;
    address payable public buyer;
    address payable public seller;

    modifier buyerOnly {
        require(msg.sender == buyer);
        _;
    }

    modifier inState(State expectedState) {
        require(currentState == expectedState);
        _;
    }

    constructor(address payable _buyer, address payable _seller) {
        buyer = _buyer;
        seller = _seller;
    }

    function confirmPayment() buyerOnly inState(State.AWAITING_PAYMENT) payable public {
        currentState = State.AWAITING_DELIVERY;
    }

    function revertPayment() buyerOnly inState(State.AWAITING_DELIVERY) payable public {
        buyer.transfer(address(this).balance);
        currentState = State.COMPLETE;
    }

    function confirmDelivery() buyerOnly inState(State.AWAITING_DELIVERY) payable public {
        seller.transfer(address(this).balance);
        currentState = State.COMPLETE;
    }
}
