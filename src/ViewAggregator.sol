// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Contract Imports
import {SettlementNft} from "./SettlementNft.sol";
import {SettlerToken} from "./SettlerToken.sol";

// ================================================================
// │                     VIEW AGGREGATOR CONTRACT                 │
// ================================================================

/// @title View Aggregator for Ethereum Settlers
/// @author EridianAlpha
/// @notice An aggregator contract for multi-calling view functions on Ethereum Settlers contracts.
contract ViewAggregator {
    // ================================================================
    // │                            STRUCTS                           │
    // ================================================================
    struct SettlementData {
        address owner;
        uint256 daysSinceMint;
        uint256 tokens;
        uint256 chainId;
        uint256 nftId;
    }

    // ================================================================
    // │                        STATE VARIABLES                       │
    // ================================================================

    SettlementNft public immutable SETTLEMENT_NFT;
    SettlerToken public immutable SETTLERS_TOKEN;

    // ================================================================
    // │                     FUNCTIONS - CONSTRUCTOR                  │
    // ================================================================

    /// @notice Constructor to initialize the Settlement NFT and SETTLER token addresses.
    /// @param _nftAddress The address of the Settlement NFT contract.
    constructor(address _nftAddress) {
        SETTLEMENT_NFT = SettlementNft(_nftAddress);
        SETTLERS_TOKEN = SETTLEMENT_NFT.SETTLER_TOKEN();
    }

    // ================================================================
    // │                           FUNCTIONS                          │
    // ================================================================

    /// @notice Get the sequential data for a range of NFTs.
    /// @param _startingNftId The starting NFT ID.
    /// @param _endingNftId The ending NFT ID.
    /// @return results The array of SettlementData structs for the range of NFTs.
    function getSequentialData(uint256 _startingNftId, uint256 _endingNftId)
        public
        view
        returns (SettlementData[] memory results)
    {
        results = new SettlementData[](_endingNftId - _startingNftId + 1);
        for (uint256 i = _startingNftId; i <= _endingNftId; i++) {
            results[i - _startingNftId] = _populateSettlementData(i);
        }
    }

    /// @notice Get a pseudo-random selection of NFTs.
    /// @dev This function uses pseudo-randomness as it is only used to return a selection
    ///      of NFTs for display purposes.
    ///      This function could have been implemented offchain but the point of this view
    ///      contract is to make interacting with the contracts easier for the front-end.
    /// @param requestedNumber The number of NFTs to return.
    /// @return results The array of SettlementData structs for the random NFTs.
    function getRandomData(uint256 requestedNumber) external view returns (SettlementData[] memory results) {
        uint256 totalIds = SETTLEMENT_NFT.nextTokenId() - 1;
        if (requestedNumber >= totalIds) {
            return getSequentialData(1, totalIds);
        }
        results = new SettlementData[](requestedNumber);

        uint256[] memory randomIds = new uint256[](requestedNumber);
        uint256 randNonce = 0;

        for (uint256 i = 0; i < requestedNumber; i++) {
            uint256 randomId;
            bool unique;
            do {
                randNonce++;
                randomId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % totalIds + 1;
                unique = true;
                // Check for duplicates
                for (uint256 j = 0; j < i; j++) {
                    if (randomIds[j] == randomId) {
                        unique = false;
                        break;
                    }
                }
            } while (!unique);

            randomIds[i] = randomId;
            results[i] = _populateSettlementData(randomId);
        }
    }

    // ================================================================
    // │                          CALCULATIONS                        │
    // ================================================================

    /// @notice Calculates the days since mint for an NFT.
    /// @param _mintTimestamp The timestamp when the NFT was minted.
    /// @return daysSinceMint The days since the NFT was minted.
    function _daysSinceMint(uint256 _mintTimestamp) internal view returns (uint256 daysSinceMint) {
        daysSinceMint = 1 + (block.timestamp - _mintTimestamp) / (60 * 60 * 24);
    }

    /// @notice Populates the SettlementData struct for an NFT.
    /// @param i The NFT ID.
    /// @return data The SettlementData struct for the NFT.
    function _populateSettlementData(uint256 i) internal view returns (SettlementData memory data) {
        address owner = SETTLEMENT_NFT.ownerOf(i);
        data.owner = owner;
        data.daysSinceMint = _daysSinceMint(SETTLEMENT_NFT.getMintTimestamp(i));
        data.tokens = SETTLERS_TOKEN.balanceOf(owner);
        data.chainId = block.chainid;
        data.nftId = i;
    }
}
