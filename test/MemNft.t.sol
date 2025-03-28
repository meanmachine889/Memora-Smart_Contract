// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MemNFT} from "../src/MemNft.sol";

contract MemNFTTest is Test {
    MemNFT private memNFT;
    address private owner = address(this); 
    address private user1 = 0xC5193D539bD74a42a89B876de5Be27CE6356970a; 
    address private user2 = address(0x456); 
    
    function setUp() public {
        
        memNFT = new MemNFT("Membership NFT", "MEM", owner);
        
        
        assertEq(memNFT.owner(), owner);
    }
    
    function testMintNFT() public {
        string memory tokenURI = "https://gateway.pinata.cloud/ipfs/QmXqhLoRE22vypK6ajfMkLGdJgg38SZxx6gTQx4N3XiFSK";
        
        
        memNFT.mintNFT(user1, 90, tokenURI);
        
        
        assertEq(memNFT.ownerOf(1), user1);
        
        
        assertTrue(memNFT.isMembershipActive(1));
        
        
        assertGt(memNFT.memberExpiryDate(1), block.timestamp);
    }
    
    function testCannotMintIfAlreadyActive() public {
        string memory tokenURI = "https://gateway.pinata.cloud/ipfs/QmXqhLoRE22vypK6ajfMkLGdJgg38SZxx6gTQx4N3XiFSK";
        
        
        memNFT.mintNFT(user1, 90, tokenURI);
        
        
        vm.expectRevert("User already has an active membership.");
        memNFT.mintNFT(user1, 90, tokenURI);
    }
    
    function testTransferMembership() public {
        string memory tokenURI = "https://gateway.pinata.cloud/ipfs/QmXqhLoRE22vypK6ajfMkLGdJgg38SZxx6gTQx4N3XiFSK";
        
        
        memNFT.mintNFT(user1, 90, tokenURI);
        
        
        vm.prank(user1); 
        memNFT.transferMembership(user2, 1);
        
        
        assertEq(memNFT.ownerOf(1), user2);
    }
    
    function testCannotTransferExpiredMembership() public {
        string memory tokenURI = "https://gateway.pinata.cloud/ipfs/QmXqhLoRE22vypK6ajfMkLGdJgg38SZxx6gTQx4N3XiFSK";
        
        
        memNFT.mintNFT(user1, 2, tokenURI);
        
        
        vm.warp(block.timestamp + 3 days); 
        
        
        assertFalse(memNFT.isMembershipActive(1));
        
        
        vm.prank(user1);
        vm.expectRevert("Membership has expired. Cannot transfer.");
        memNFT.transferMembership(user2, 1);
    }
    
    function testOwnershipTransfer() public {
        
        address newOwner = address(0x789);
        
        
        memNFT.transferOwnership(newOwner);
        
        
        assertEq(memNFT.owner(), newOwner);
        
        
        vm.expectRevert("Not the contract owner");
        memNFT.mintNFT(user1, 90, "test-uri");
        
        
        vm.prank(newOwner);
        memNFT.mintNFT(user2, 30, "test-uri-2");
        
        
        assertEq(memNFT.ownerOf(1), user2);
    }
    
    function testCannotTransferOwnershipToZeroAddress() public {
        
        vm.expectRevert("New owner cannot be zero address");
        memNFT.transferOwnership(address(0));
    }
}