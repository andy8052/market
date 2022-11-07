// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";
import "../src/Market.sol";

contract TestNFT is ERC721 {
    constructor() ERC721("","") {}

    function mint(address to, uint256 id) public {
        _mint(to, id);
    }

    function tokenURI(uint256) public view override returns(string memory) {}
}

contract MarketTest is Test {
    Market public mrkt;
    TestNFT public nft;

    function setUp() public {
        mrkt = new Market();
        nft = new TestNFT();
        nft.mint(address(this), 1);
        nft.setApprovalForAll(address(mrkt), true);
    }

    function testList() public {
        mrkt.list(address(nft), 1, 1 ether);
        (uint256 price, address seller) = mrkt.listings(address(nft), 1);
        assertEq(price, 1 ether);
        assertEq(seller, address(this));
    }

    function testDelist() public {
        testList();
        mrkt.delist(address(nft), 1);
        (uint256 price, address seller) = mrkt.listings(address(nft), 1);
        assertEq(price, 0);
        assertEq(seller, address(0));
    }

    function testBuy() public {
        testList();
        payable(address(0x0B0EE8e6570C47dEBe98710c60A265bF3DB7fb89)).transfer(5 ether);
        vm.prank(address(0x0B0EE8e6570C47dEBe98710c60A265bF3DB7fb89));
        mrkt.buy{value: 1 ether}(address(nft), 1);
    }

    receive() external payable {}
}
