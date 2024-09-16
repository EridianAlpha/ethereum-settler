// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// OpenZeppelin Imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/base64.sol";

// Contract Imports
import {SettlerToken} from "./SettlerToken.sol";

// ================================================================
// │                    SETTLEMENT NFT CONTRACT                   │
// ================================================================

/// @title AavePM - Ethereum Settlers NFT
/// @author EridianAlpha
/// @notice An ERC721 NFT token called `Ethereum Settlement` (SETTLEMENT).
contract SettlementNft is ERC721 {
    // ================================================================
    // │                            ERRORS                            │
    // ================================================================

    error SettlementNft_SingleActivePerAddress();

    // ================================================================
    // │                        STATE VARIABLES                       │
    // ================================================================

    // Constant and immutable variables
    SettlerToken public immutable SETTLER_TOKEN;
    string public BASE_IMAGE_URI;

    // Mutable variables
    uint256 public nextTokenId = 1; // Start token IDs at 1

    // Mappings
    mapping(uint256 => uint256) internal s_mintTimestamp;
    mapping(address => uint256) internal s_ownerToId;

    /// @notice Constructor to initialize the contract with a base image URI and deploy the SettlerToken contract.
    /// @param _baseImageUri The base URI for the NFT image.
    constructor(string memory _baseImageUri) ERC721("Ethereum Settlement", "SETTLEMENT") {
        BASE_IMAGE_URI = _baseImageUri;
        SETTLER_TOKEN = new SettlerToken(address(this));
    }

    /// @notice Override standard ERC721 update function.
    /// @dev Mints outstanding SETTLER tokens.
    ///      Check only 1 active NFT per address.
    /// @param to The address to transfer the NFT to.
    /// @param tokenId The ID of the NFT.
    /// @param auth The address that is authorized to transfer the NFT.
    /// @return previousOwner The previous owner of the NFT.
    function _update(address to, uint256 tokenId, address auth) internal override returns (address previousOwner) {
        // Check if the NFT has already been minted
        if (tokenId != nextTokenId) {
            // Get the previous owner of the NFT
            address from = ownerOf(tokenId);

            // Mint any outstanding tokens for the previous owner
            SETTLER_TOKEN.mintOutstandingTokensFromNft(from);

            // Update the s_ownerToId mapping
            s_ownerToId[from] = 0;
            s_ownerToId[to] = tokenId;
        }

        // Call the parent _update function
        previousOwner = super._update(to, tokenId, auth);

        require

        // Only allow one active NFT per address at a time
        require(balanceOf(to) <= 1, SettlementNft_SingleActivePerAddress());
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

        // Create the composite SVG with the settlement ID and days since mint as an overlay
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
        uint256 settlementNumberXWidth = 52 + ((bytes(tokenIdString).length) * 5);

        return string(
            abi.encodePacked(
                '<rect x="',
                Strings.toString((100 - settlementNumberXWidth) / 2),
                '%" y="30%" rx="20" ry="20" width="',
                Strings.toString(settlementNumberXWidth),
                '%" height="38" fill="#201649" />',
                '<text x="50%" y="36%" dominant-baseline="middle" text-anchor="middle" font-size="22" font-weight="bold" font-family="monospace" fill="white">',
                "Settlement #",
                tokenIdString,
                "</text>"
            )
        );
    }

    function _generateDaysSinceMintRectangle(uint256 tokenId) internal view returns (string memory) {
        uint256 daysSinceMint = ((block.timestamp + (60 * 60 * 24)) - s_mintTimestamp[tokenId]) / (60 * 60 * 24);
        uint256 daysSinceMintXWidth = 22 + ((bytes(Strings.toString(daysSinceMint)).length) * 5);

        return string(
            abi.encodePacked(
                '<rect x="',
                Strings.toString((100 - daysSinceMintXWidth) / 2),
                '%" y="42%" rx="20" ry="20" width="',
                Strings.toString(daysSinceMintXWidth),
                '%" height="38" fill="#201649" />',
                '<text x="50%" y="48%" dominant-baseline="middle" text-anchor="middle" font-size="22" font-weight="bold" font-family="monospace" fill="white">',
                Strings.toString(daysSinceMint > 1 ? daysSinceMint : 1),
                daysSinceMint > 1 ? " days" : " day",
                "</text>"
            )
        );
    }

    // Getters
    function getOwnerToId(address owner) external view returns (uint256) {
        return s_ownerToId[owner];
    }

    function getMintTimestamp(uint256 tokenId) external view returns (uint256) {
        return s_mintTimestamp[tokenId];
    }
}
