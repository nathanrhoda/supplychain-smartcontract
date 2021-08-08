// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract LemonadeStand {
    address owner;
    uint skuCount;

    enum State {ForSale, Sold, Shipped }

    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    mapping(uint => Item) items;

    event ForSale(uint skuCount);

    event Sold(uint sku);

    event Shipped(uint sku);

    modifier onlyOwner() {
        require((msg.sender == owner));
        _;
    }

    
    modifier verifyCaller(address _address) {
        require((msg.sender == _address));
        _;
    }    

    modifier paidEnough(uint _price) {
        require(msg.value >= _price);
        _;
    }        

    modifier forSale(uint _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }        

    modifier sold(uint _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }            

    modifier checkValue(uint _sku) {
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;

        address payable buyerPayableAddress = items[_sku].buyer;
        buyerPayableAddress.transfer(amountToRefund);
    }

    constructor()  public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint _price) onlyOwner public {
        skuCount = skuCount + 1;

        emit ForSale(skuCount);

        items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    }

    function buyItem(uint sku) public payable forSale(sku) paidEnough(items[sku].price) {
        address payable buyer = msg.sender;
        uint price = items[sku].price;

        items[sku].buyer = buyer;
        items[sku].state = State.Sold;

        // Transfer money to seller
        address payable sellerPayableAddress = items[sku].seller;
        sellerPayableAddress.transfer(price);
        
        emit Sold(sku);
    }

    function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, string memory  stateIs, address seller, address buyer) {
        uint state;
        name = items[_sku].name;
        sku  = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        if(state == 0) {
            stateIs = "For Sale";
        }
        if(state == 1) {
            stateIs = "Sold";
        }
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
    }

    function shipItem(uint _sku) public sold(_sku) verifyCaller(msg.sender) {        
        items[_sku].state = State.Shipped;
        emit Shipped(_sku);
    }
}