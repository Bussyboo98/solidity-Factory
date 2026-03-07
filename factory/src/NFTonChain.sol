// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract BishopNFT is ERC721, ERC721URIStorage {

    using Strings for uint256;

    uint256 private _tokenIds;
    mapping(uint256 => uint256) public tokenIdToLevels;

    constructor() ERC721("BishopNFT", "BISHOP") {}

    // Interface Support
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Token URI override
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // Generate On-Chain SVG Image
    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: red; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">June</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">Level: ',
            tokenIdToLevels[tokenId].toString(),
            '</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    // On-chain metadata URI
    function getTokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Bishop NFT #', tokenId.toString(), '",',
                '"description": "NFT",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    // Mint NFT
    function mint() public {
        _tokenIds++;

        uint256 newItemId = _tokenIds;
        _safeMint(msg.sender, newItemId);

        tokenIdToLevels[newItemId] = 0;

        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    // Train NFT (level up)
    function train(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");

        tokenIdToLevels[tokenId]++;

        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}