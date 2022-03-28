//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.2 ; 

// linter warnings (red underline) about pragma version can igonored!

// contract code will go here
contract PhoneSales{
    address owner;
    uint skuCount;

    enum Status {ForSale, Sold, Delivered,Received, Completed }

    struct Item{
        string name;
        uint sku;
        uint price;
        string brand;
        address seller;
        address buyer;
        Status status;
    }
    mapping (uint => Item) items;

    event ForSale(uint skuCount);
    event Sold(uint sku);
    event Delivered(uint sku);
    event Received(uint sku);
    event Completed(uint sku);

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    
    }
 
    modifier paidEnough(uint _price){
        require(msg.value >= _price);
        _;
    }
    modifier forSale(uint _sku){
        require(items[_sku].status == Status.ForSale);
        _;
    }
    modifier sold(uint _sku){
        require(items[_sku].status == Status.Sold);
        _;
    }
    modifier delivered(uint _sku){
        require(items[_sku].status == Status.Delivered);
        _;
    }
    modifier received(uint _sku){
        require(items[_sku].status == Status.Received);
        _;
    }
    modifier completed(uint _sku){
        require(items[_sku].status == Status.Completed);
        _;
    }
    constructor (){
        owner = msg.sender;
        skuCount = 0;
    }

    function addInventory(string memory _name, string memory _brand, uint _price)  onlyOwner public{
        skuCount += 1 ;// this increments the sku
        // emit the ForSale event
        emit ForSale(skuCount);
        // add the items to the inventory
        items[skuCount] = Item({name: _name, sku: skuCount,brand:_brand, price: _price, status: Status.ForSale, seller: msg.sender , buyer: 0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF});
    }
    function buyItem(uint sku) forSale(sku) paidEnough(items[sku].price)  public payable {
        
        address buyer = msg.sender;
        uint price = items[sku].price;
        items[sku].buyer = buyer;
        if (msg.value > price){
            uint refundAmount = msg.value - price;
            payable(items[sku].buyer).transfer(refundAmount);
        }
        items[sku].status = Status.Sold;
        payable(items[sku].seller).transfer(price);
        emit Sold(sku);

    }
    function deliveredItem(uint sku) sold(sku) public{
        require(msg. sender == items[sku].seller);
        items[sku].status = Status.Delivered;
        emit Delivered(sku);
        
    }
    function receivedItem(uint sku) delivered(sku) public{
        require(msg. sender == items[sku].buyer);
        items[sku].status = Status.Received;
        emit Received(sku);
        
    }
    function completedOrder(uint sku) received(sku) public{
        require(msg. sender == items[sku].seller);
        items[sku].status = Status.Completed;
        emit Completed(sku);
        
    }
    function fetchItems(uint _sku) public view returns (string memory _name, uint sku,string memory _brand, uint _price, address _seller, address _buyer, string memory statusIs){
       sku = items[_sku].sku;
       _name = items[_sku].name;
       _brand = items[_sku].brand;
       _price = items[_sku].price;
       _seller = items[_sku].seller;
       _buyer = items[_sku].buyer;
       uint status = uint(items[_sku].status);
       if(status == 0){
           statusIs = "This item is for sale"; 
       }
       else if (status == 1){
           statusIs = "This item has been sold";
       }
       else if (status == 2){
            statusIs = "This item has been delivered";
       }
       else if (status == 3){
            statusIs = "This item has been received";
       }
       else if (status == 4) {
           statusIs = "This order has been completed";
       }
       else{
           statusIs = "This order doesn't exist";
       }

    }

}
