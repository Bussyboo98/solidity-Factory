// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract MintVaultNFT is ERC721 {

    uint public nextId;

    constructor() ERC721("GOAT","GT") {}

    function mint(address to) external returns(uint){

        nextId++;

        _mint(to,nextId);

        return nextId;
    }

    function generateSVG(address token, uint amount) internal pure returns(string memory){

        return string(
        abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="200">',
        '<text x="10" y="20">Vault</text>',
        '<text x="10" y="40">Token:</text>',
        '<text x="10" y="60">Amount:</text>',
        '</svg>'
        ));
    }

    function tokenURI(uint tokenId) public view override returns(string memory){
        string memory svg = generateSVG(address(0),0);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"GOAT NFT","image":"data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}