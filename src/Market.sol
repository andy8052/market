// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Market {

    struct Listing {
        uint96 price;
        address seller;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    function list(address nft, uint256 id, uint96 price) public {

    }
}
