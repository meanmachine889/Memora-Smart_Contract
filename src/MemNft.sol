// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MemNFTFactory {
    
    event MemNFTCreated(address indexed creator, address contractAddress, string name, string symbol);
   
    
    address[] public deployedContracts;
   
    
    mapping(address => address[]) public creatorContracts;
   
    
    function createMemNFT(string memory name, string memory symbol) public returns (address) {
        
        MemNFT newContract = new MemNFT(name, symbol, msg.sender);
       
        
        address contractAddress = address(newContract);
        deployedContracts.push(contractAddress);
        creatorContracts[msg.sender].push(contractAddress);
       
        
        emit MemNFTCreated(msg.sender, contractAddress, name, symbol);
       
        return contractAddress;
    }
   
    
    function getCreatorContracts(address creator) public view returns (address[] memory) {
        return creatorContracts[creator];
    }
   
    
    function getDeployedContractsCount() public view returns (uint256) {
        return deployedContracts.length;
    }
}

contract MemNFT is ERC721URIStorage {
    uint256 public ntkid;
    address public owner;
    mapping(uint256 => uint256) public expirationTimeStamps;
    mapping(address => uint256) public existingMembership;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    constructor(
        string memory _name,
        string memory _symbol,
        address initialOwner
    ) ERC721(_name, _symbol) {
        owner = initialOwner;
        ntkid = 1;
    }
    
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }
    
    function mintNFT(
        address recipient,
        uint256 duration,
        string memory tokenURI
    ) public onlyOwner {
        require(
            existingMembership[recipient] == 0 ||
                expirationTimeStamps[existingMembership[recipient]] == 0 ||
                block.timestamp >
                expirationTimeStamps[existingMembership[recipient]],
            "User already has an active membership."
        );
        uint256 tokenId = ntkid;
        existingMembership[recipient] = tokenId;
        ntkid++;
       
        uint256 expirationDate = block.timestamp + (duration * 1 days);
        expirationTimeStamps[tokenId] = expirationDate;
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
    
    function isMembershipActive(uint256 tokenId) public view returns (bool) {
        return block.timestamp < expirationTimeStamps[tokenId];
    }
    
    function memberExpiryDate(uint256 tokenId) public view returns (uint256) {
        return expirationTimeStamps[tokenId];
    }
    
    function transferMembership(address to, uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "You are not the owner of this NFT."
        );
        require(
            isMembershipActive(tokenId),
            "Membership has expired. Cannot transfer."
        );
        require(
            existingMembership[to] == 0 ||
                block.timestamp > expirationTimeStamps[existingMembership[to]],
            "Receiver already has an active membership."
        );
        existingMembership[msg.sender] = 0;
        existingMembership[to] = tokenId;
        _transfer(msg.sender, to, tokenId);
    }
    
    function returnTokenURI(
        uint256 tokenId
    ) public view returns (string memory) {
        return super.tokenURI(tokenId);
    }
}