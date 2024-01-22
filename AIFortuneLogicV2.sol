// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AIFortuneLogicV2 is
    ERC721URIStorageUpgradeable,
    IERC2981,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable
{
    uint256 private _tokenIdCounter;
    uint256 public royaltyPercentage;
    uint256 public mintFee;

    event NFTMinted(address recipient, uint256 tokenId);
    event NFTRoyaltyUpdated(uint256 newRoyaltyPercentage);
    event NFTTransferred(address from, address to, uint256 tokenId);
    event Withdrawal(uint256 amount);
    event MintFeeUpdated(uint256 newMintFee);

    function initialize(address initialOwner) public initializer {
        ERC721URIStorageUpgradeable.__ERC721URIStorage_init();
        ERC721Upgradeable.__ERC721_init("AIFortune", "AIF");
        __Ownable_init(initialOwner);
        // Diğer başlangıç yapılandırmaları
        _tokenIdCounter = 0;
        mintFee = 1 ether;
        royaltyPercentage = 10;
    }

    // Function to mint a new NFT.
    function mintNFT(
        address recipient,
        string memory tokenURI
    ) public payable nonReentrant returns (uint256) {
        require(msg.value >= mintFee, "Mint fee is not met.");
        uint256 newItemId = _tokenIdCounter;
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenIdCounter += 1;
        emit NFTMinted(recipient, newItemId);
        return newItemId;
    }

    // Function to update the minting fee, callable only by the owner
    function updateMintFee(uint256 newMintFee) public onlyOwner {
        mintFee = newMintFee;
        emit MintFeeUpdated(newMintFee);
    }

    // Function to get the current mint fee
    function getMintFee() public view returns (uint256) {
        return mintFee;
    }

    // Function to transfer an NFT from one address to another, ensures ownership before transfer.
    function transferNFT(address to, uint256 tokenId) public nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "Sender does not own the NFT.");
        _transfer(msg.sender, to, tokenId);
        emit NFTTransferred(msg.sender, to, tokenId);
    }

    // Function to set the royalty percentage, callable only by the owner
    function setRoyalty(uint256 newRoyaltyPercentage) public onlyOwner {
        require(
            newRoyaltyPercentage <= 30,
            "Royalty percentage cannot exceed 30%."
        );
        royaltyPercentage = newRoyaltyPercentage;
        emit NFTRoyaltyUpdated(newRoyaltyPercentage);
    }

    // Implement `royaltyInfo` function required by the IERC2981 interface
    function royaltyInfo(
        uint256 /* tokenId */,
        uint256 salePrice
    ) public view override returns (address receiver, uint256 royaltyAmount) {
        return (owner(), (salePrice * royaltyPercentage) / 100);
    }

    // Function for the owner to withdraw funds from the contract, callable only by the owner.
    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
        emit Withdrawal(balance);
    }

    // Function that returns the total number of minted NFTs
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    // Function that returns the ConractURI()
    function contractURI() public pure returns (string memory) {
        return "ipfs://QmUWuCio3D1Zjc1YaH4dhBAguk4xBzPxCtD8zFvoQ4igBw";
    }
}
