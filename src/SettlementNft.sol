// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/base64.sol";

import {SettlerToken} from "./SettlerToken.sol";

contract SettlementNft is ERC721 {
    // Errors
    error SettlementNft_SingleActivePerAddress();

    // State variables
    SettlerToken public immutable SETTLER_TOKEN;
    string public BASE_IMAGE_URI;
    uint256 public nextTokenId = 1; // Start token IDs at 1
    mapping(uint256 => uint256) public s_mintTimestamp;
    mapping(address => uint256) public s_ownerToId;

    constructor(string memory _baseImageUri) ERC721("Ethereum Settlement", "SETTLEMENT") {
        BASE_IMAGE_URI = _baseImageUri;

        // Deploy the SETTLER ERC20 token
        SETTLER_TOKEN = new SettlerToken(address(this));
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        // Only allow one active NFT per address at a time
        require(balanceOf(msg.sender) == 0, SettlementNft_SingleActivePerAddress());

        // Mint any outstanding SETTLER tokens from the SettlerToken contract
        SETTLER_TOKEN.mintOutstandingTokensFromNft(msg.sender);

        // Update the s_ownerToId mapping
        s_ownerToId[msg.sender] = 0;
        s_ownerToId[to] = tokenId;

        // TODO: Which address is returned?
        return super._update(to, tokenId, auth);
    }

    function mint() external {
        _safeMint(msg.sender, nextTokenId);
        s_mintTimestamp[nextTokenId] = block.timestamp;
        s_ownerToId[msg.sender] = nextTokenId;
        nextTokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // Create the JSON metadata and encode it in base64
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Ethereum Settlement #',
                        Strings.toString(tokenId),
                        '",',
                        '"description": "An on-chain NFT representing an Ethereum settlement.",',
                        '"image": "',
                        BASE_IMAGE_URI,
                        '",',
                        '"imageCompositeSvg": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(_generateSvg(tokenId))),
                        '",',
                        '"attributes": [',
                        '{"trait_type": "Mint Timestamp", "value": "',
                        Strings.toString(s_mintTimestamp[tokenId]),
                        '"}',
                        "]}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _generateSvg(uint256 tokenId) internal view returns (string memory svg) {
        string memory tokenIdString = Strings.toString(tokenId);

        // Create the custom SVG with the timestamp as an overlay
        svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
                '<image href="',
                BASE_IMAGE_URI,
                '" height="100%" width="100%" />',
                _generateSettlementRectangle(tokenIdString),
                _generateDaysSinceMintRectangle(tokenId),
                "</svg>"
            )
        );
    }

    function _generateSettlementRectangle(string memory tokenIdString) internal pure returns (string memory) {
        uint256 settlementNumberXWidth = 55 + ((bytes(tokenIdString).length) * 5);

        return string(
            abi.encodePacked(
                '<rect x="',
                Strings.toString((100 - settlementNumberXWidth) / 2),
                '%" y="30%" rx="20" ry="20" width="',
                Strings.toString(settlementNumberXWidth),
                '%" height="38" fill="#201649" />',
                '<text x="50%" y="36%" dominant-baseline="middle" text-anchor="middle" font-size="24" font-weight="bold" font-family="monospace" fill="white">',
                "Settlement #",
                tokenIdString,
                "</text>"
            )
        );
    }

    function _generateDaysSinceMintRectangle(uint256 tokenId) internal view returns (string memory) {
        uint256 daysSinceMint = ((block.timestamp + (60 * 60 * 24 * 1234)) - s_mintTimestamp[tokenId]) / (60 * 60 * 24);
        uint256 daysSinceMintXWidth = 22 + ((bytes(Strings.toString(daysSinceMint)).length) * 5);

        return string(
            abi.encodePacked(
                '<rect x="',
                Strings.toString((100 - daysSinceMintXWidth) / 2),
                '%" y="42%" rx="20" ry="20" width="',
                Strings.toString(daysSinceMintXWidth),
                '%" height="38" fill="#201649" />',
                '<text x="50%" y="48%" dominant-baseline="middle" text-anchor="middle" font-size="24" font-weight="bold" font-family="monospace" fill="white">',
                Strings.toString(daysSinceMint > 1 ? daysSinceMint : 1),
                daysSinceMint > 1 ? " days" : " day",
                "</text>"
            )
        );
    }
}
