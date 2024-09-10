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
    SettlerToken public immutable i_settlerToken;
    string public baseImageUri;
    uint256 public nextTokenId = 1; // Start token IDs at 1
    mapping(uint256 => uint256) public mintTimestamp;
    mapping(address => uint256) public ownerToId;

    constructor(string memory _baseImageUri) ERC721("Ethereum Settlement", "SETTLEMENT") {
        baseImageUri = _baseImageUri;

        // Deploy the SETTLER ERC20 token
        i_settlerToken = new SettlerToken(address(this));
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        // Only allow one active NFT per address at a time
        require(balanceOf(msg.sender) == 0, SettlementNft_SingleActivePerAddress());

        // Mint any outstanding SETTLER tokens from the SettlerToken contract
        i_settlerToken.mintOutstandingTokensFromNft(msg.sender);

        // Update the ownerToId mapping
        ownerToId[msg.sender] = 0;
        ownerToId[to] = tokenId;

        return super._update(to, tokenId, auth);
    }

    function mint() external {
        _safeMint(msg.sender, nextTokenId);
        mintTimestamp[nextTokenId] = block.timestamp;
        ownerToId[msg.sender] = nextTokenId;
        nextTokenId++;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // Create the custom SVG with the timestamp as an overlay
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
                '<image href="',
                baseImageUri,
                '" height="100%" width="100%" />',
                '<rect x="25%" y="32%" rx="20" ry="20" width="50%" height="38" fill="#201649" />',
                '<text x="50%" y="38%" dominant-baseline="middle" text-anchor="middle" font-size="24" font-weight="bold" font-family="monospace" fill="white">',
                Strings.toString(((block.timestamp + (60 * 60 * 24 * 1234)) - mintTimestamp[tokenId]) / (60 * 60 * 24)),
                " days</text>",
                "</svg>"
            )
        );

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
                        baseImageUri,
                        '",',
                        '"imageCompositeSvg": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '",',
                        '"attributes": [',
                        '{"trait_type": "Mint Timestamp", "value": "',
                        Strings.toString(mintTimestamp[tokenId]),
                        '"}',
                        "]}"
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
