// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//Importing Libraries
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//Minting a NFT
contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketPlaceAddress) ERC721("Metaverse Tokens", "METT") {
        //Setting the contract address to the address where the contract has taken place which means market place addresss
        contractAddress = marketPlaceAddress;
    }

    function createToken(string memory _tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        //minting the nft
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}