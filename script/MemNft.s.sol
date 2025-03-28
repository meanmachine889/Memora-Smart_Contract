// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MemNFT} from "../src/MemNft.sol";

contract DeployMemNFT is Script {
    MemNFT public memNFT;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address deployerAddress = vm.addr(deployerPrivateKey);
        
        console.log("Deploying with address:", deployerAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        memNFT = new MemNFT("Membership NFT", "MEM", deployerAddress);
        
        console.log("MemNFT deployed at:", address(memNFT));
        console.log("Owner set to:", memNFT.owner());
        
        vm.stopBroadcast();
    }
}