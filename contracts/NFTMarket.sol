// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//importing the libraries
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//ReentrancyGuard is used for security purposes
contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    address payable owner;

    //Commision 

    //The listing price
    uint256 listeningPrice = 0.025 ether;
    constructor() {
        owner = payable(msg.sender);
    }

    // Structure of an item in the market
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    //Creating a array to store all the items in the market
    mapping(uint256 => MarketItem) private idToMarketItem;

    //Creating an event bout an item being created in the market
    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    //Function to get the listing price 
    function getListneingPrice() public view returns (uint256) {
        return listeningPrice;
    }

    //Function to add an item to the market
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint price
    ) public payable nonReentrant {

        //Price of the market item should be greater than 0
        require (price > 0, "Price must be at least 1");
        require(msg.value == listeningPrice , "Price must be equal to listening price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        // Creating the new item
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );
        
        // Transfering the contract from sender to the market
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Emitting that the item is created
        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
    }

    function createMarketSale(
        address nftContract,
        uint itemId
    ) public payable nonReentrant {

        //Price of nft
        uint price = idToMarketItem[itemId].price;

        //token id of nft
        uint tokenId = idToMarketItem[itemId].tokenId;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        //Transfering the amount to seller
        idToMarketItem[itemId].seller.transfer(msg.value);

        //Transfering the contract from market to buyer
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        //Adding the ownership
        idToMarketItem[itemId].owner = payable(msg.sender);

        //Marking the item sold
        idToMarketItem[itemId].sold = true;

        //Increasing sold items
        _itemsSold.increment();

        
        payable(owner).transfer(listeningPrice);
    }

    //Function to get unsold items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for(uint i = 0 ; i < itemCount ; i++) {
            if(idToMarketItem[i+1].owner == address(0)) {
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

    //Function to get my items
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i = 0 ; i<totalItemCount; i++) {
            if(idToMarketItem[i+1].owner == msg.sender) {
                itemCount+=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i<totalItemCount; i++) {
            if(idToMarketItem[i+1].owner == msg.sender) {
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }

    //Function to get seller's nfts
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i = 0 ; i<totalItemCount; i++) {
            if(idToMarketItem[i+1].seller == msg.sender) {
                itemCount+=1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i<totalItemCount; i++) {
            if(idToMarketItem[i+1].seller == msg.sender) {
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }
}
