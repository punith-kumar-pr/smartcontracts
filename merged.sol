// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract OrderEscrow {
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

    State public currentState;
    address payable public buyer;
    address payable public seller;

    struct Item {
        uint256 itemId;
        string itemName;
        uint256 itemCost;
    }

    struct Order {
        uint256 orderNo;
        address userAddress;
        uint256[] itemIds;
        string[] itemNames;
        uint256[] itemCosts;
        string deliveryAddress;
        uint256 paymentAmount;
    }

    mapping(uint256 => Order) public orders;
    uint256 public orderCount;

    event OrderCreated(
        uint256 orderNo,
        address userAddress,
        uint256[] itemIds,
        string[] itemNames,
        uint256[] itemCosts,
        string deliveryAddress,
        uint256 paymentAmount
    );

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

    function createOrder(
        uint256[] memory _itemIds,
        string[] memory _itemNames,
        uint256[] memory _itemCosts,
        string memory _deliveryAddress,
        uint256 _paymentAmount
    ) public {
        require(
            _itemIds.length == _itemNames.length &&
                _itemIds.length == _itemCosts.length,
            "Invalid item details"
        );

        uint256 orderNo = orderCount;
        orders[orderNo] = Order(
            orderNo,
            msg.sender,
            _itemIds,
            _itemNames,
            _itemCosts,
            _deliveryAddress,
            _paymentAmount
        );
        orderCount++;

        currentState = State.AWAITING_PAYMENT;

        emit OrderCreated(
            orderNo,
            msg.sender,
            _itemIds,
            _itemNames,
            _itemCosts,
            _deliveryAddress,
            _paymentAmount
        );
    }

    function confirmPayment(uint256 _orderNo) buyerOnly inState(State.AWAITING_PAYMENT) payable public {
        require(_orderNo < orderCount, "Invalid order number");
        Order storage order = orders[_orderNo];
        require(msg.value >= order.paymentAmount, "Incorrect payment amount");

        currentState = State.AWAITING_DELIVERY;
    }

    function revertPayment(uint256 _orderNo) buyerOnly inState(State.AWAITING_DELIVERY) payable public {
        require(_orderNo < orderCount, "Invalid order number");
        Order storage order = orders[_orderNo];
        buyer.transfer(address(this).balance);

        currentState = State.COMPLETE;
    }

    function confirmDelivery(uint256 _orderNo) buyerOnly inState(State.AWAITING_DELIVERY) payable public {
        require(_orderNo < orderCount, "Invalid order number");
        Order storage order = orders[_orderNo];
        seller.transfer(address(this).balance);

        currentState = State.COMPLETE;
    }

    function getOrder(uint256 _orderNo)
        public
        view
        returns (
            address,
            uint256[] memory,
            string[] memory,
            uint256[] memory,
            string memory,
            uint256
        )
    {
        require(_orderNo < orderCount, "Invalid order number");
        Order memory order = orders[_orderNo];
        return (
            order.userAddress,
            order.itemIds,
            order.itemNames,
            order.itemCosts,
            order.deliveryAddress,
            order.paymentAmount
        );
    }
}
