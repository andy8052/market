// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "solmate/tokens/ERC721.sol";

error Price();
error Auth();

contract Market {

    event List(address indexed nft, uint256 id, uint96 price, address indexed seller);
    event Delist(address indexed nft, uint256 id, address indexed seller);
    event Sale(address indexed nft, uint256 id, uint96 price, address indexed seller, address indexed buyer);

    struct Listing {
        uint96 price;
        address seller;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    function list(address nft, uint256 id, uint96 price) public {
        if (ERC721(nft).ownerOf(id) != msg.sender) revert Auth();
        listings[nft][id] = Listing(price, msg.sender);
        emit List(nft, id, price, msg.sender);
    }

    function bulkList(address[] calldata nfts, uint256[] calldata ids, uint96[] calldata prices) public {
        for (uint256 x = 0; x < nfts.length; x++) {
            list(nfts[x], ids[x], prices[x]);
        }
    }

    function delist(address nft, uint256 id) public {
        if (ERC721(nft).ownerOf(id) != msg.sender) revert Auth();
        delete listings[nft][id];
        emit Delist(nft, id, msg.sender);
    }

    function bulkDelist(address[] calldata nfts, uint256[] calldata ids) public {
        for (uint256 x = 0; x < nfts.length; x++) {
            delist(nfts[x], ids[x]);
        }
    }

    function buy(address nft, uint256 id) public payable {
        Listing memory l = listings[nft][id];
        if (l.price != msg.value) revert Price();
        delete listings[nft][id];
        ERC721(nft).safeTransferFrom(l.seller, msg.sender, id);
        // TODO royalties/fees
        payable(l.seller).transfer(msg.value);
        emit Sale(nft, id, l.price, l.seller, msg.sender);
    }

}
