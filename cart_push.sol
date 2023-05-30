// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract OrderContract {
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
    }

    mapping(uint256 => Order) public orders;
    uint256 public orderCount;

    event OrderCreated(
        uint256 orderNo,
        address userAddress,
        uint256[] itemIds,
        string[] itemNames,
        uint256[] itemCosts,
        string deliveryAddress
    );

    function createOrder(
        uint256[] memory _itemIds,
        string[] memory _itemNames,
        uint256[] memory _itemCosts,
        string memory _deliveryAddress
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
            _deliveryAddress
        );
        orderCount++;
        emit OrderCreated(orderNo, msg.sender, _itemIds, _itemNames, _itemCosts, _deliveryAddress);
    }

    function getOrder(uint256 _orderNo)
        public
        view
        returns (
            address,
            uint256[] memory,
            string[] memory,
            uint256[] memory,
            string memory
        )
    {
        require(_orderNo < orderCount, "Invalid order number");
        Order storage order = orders[_orderNo];
        return (
            order.userAddress,
            order.itemIds,
            order.itemNames,
            order.itemCosts,
            order.deliveryAddress
        );
    }
}
