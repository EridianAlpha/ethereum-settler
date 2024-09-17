// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// OpenZeppelin Imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// Contract Imports
import {SettlementNft} from "./SettlementNft.sol";

// ================================================================
// │                     SETTLER TOKEN CONTRACT                    │
// ================================================================

/// @title Ethereum Settlers - Token
/// @author EridianAlpha
/// @notice An ERC20 token called `Ethereum Settler` (SETTLER).
contract SettlerToken is ERC20, ERC20Permit {
    // ================================================================
    // │                        STATE VARIABLES                       │
    // ================================================================

    // Constant and immutable variables
    uint256 public constant TOKEN_EMISSION_RATE = 1e18; // Tokens per second
    SettlementNft public immutable SETTLEMENT_NFT;

    // Mappings
    mapping(uint256 => uint256) public s_mintedTokensFromNft;

    // ================================================================
    // │                     FUNCTIONS - CONSTRUCTOR                  │
    // ================================================================

    /// @notice Constructor for the Settler Token contract to initialize the Settlement NFT address.
    /// @param _nftAddress The address of the Settlement NFT contract.
    constructor(address _nftAddress) ERC20("Ethereum Settler", "SETTLER") ERC20Permit("Ethereum Settler") {
        SETTLEMENT_NFT = SettlementNft(_nftAddress);
    }

    // ================================================================
    // │                        FUNCTIONS - MINT                      │
    // ================================================================

    /// @notice Mint outstanding tokens for an account based on the Settler NFT held by that account.
    /// @dev Useful when NFT is transferred as this function can be called before the NFT is transferred,
    //       so that the previous owner receives all their outstanding tokens.
    //       It can also be called at any time by anyone,
    //       but that does not make any difference to the balance calculations.
    /// @param account The account to mint tokens for.
    function mintOutstandingTokensFromNft(address account) public {
        _mintOutstandingTokensFromNft(account);
    }

    /// @notice Internal function to mint outstanding tokens for an account based on the Settler NFT held by that account.
    /// @dev This function calculates the new tokens to mint and updates the state to reflect the minted tokens.
    ///      If the `nftId` is zero, the function does nothing as there is no corresponding NFT for the account.
    /// @param account The account for which tokens are minted.
    function _mintOutstandingTokensFromNft(address account) internal {
        (uint256 nftId, uint256 totalLifetimeTokensFromNft, uint256 newTokensToMint) =
            _calculateNewTokensToMint(account);
        if (nftId != 0) {
            s_mintedTokensFromNft[nftId] = totalLifetimeTokensFromNft;
            _mint(account, newTokensToMint);
        }
    }

    // ================================================================
    // │                      FUNCTIONS - UPDATE                      │
    // ================================================================

    /// @notice Override standard ERC20 `_update` function.
    /// @dev Mints outstanding SETTLER tokens based on the Settler NFT held by the account,
    ///      then calls the parent `_update` function to update the account balances.
    /// @param from The account to transfer tokens from.
    function _update(address from, address to, uint256 value) internal override {
        // If the account has an NFT, mint any outstanding tokens based on the time since the NFT was minted
        if (from != address(0) && SETTLEMENT_NFT.balanceOf(from) > 0) {
            _mintOutstandingTokensFromNft(from);
        }
        super._update(from, to, value);
    }

    // ================================================================
    // │                     FUNCTIONS - BALANCE                      │
    // ================================================================

    /// @notice Override standard ERC20 `balanceOf` function.
    /// @dev If the account has an NFT, calculate the unminted balance based on the time since the NFT was minted.
    /// @param account The account to get the balance of.
    /// @return accountBalance The balance of the account as a sum of the minted and unminted tokens.
    function balanceOf(address account) public view override returns (uint256 accountBalance) {
        // If the account has an NFT, calculate the unminted balance based on the time since the NFT was minted
        if (SETTLEMENT_NFT.balanceOf(account) > 0) {
            (,, uint256 unmintedTokensFromNft) = _calculateNewTokensToMint(account);
            accountBalance = super.balanceOf(account) + unmintedTokensFromNft;
        } else {
            accountBalance = super.balanceOf(account);
        }
    }

    // ================================================================
    // │                    FUNCTIONS - CALCULATIONS                   │
    // ================================================================

    /// @notice Calculate the total lifetime tokens from an NFT based on the mint timestamp.
    /// @param _mintTimestamp The timestamp when the NFT was minted.
    /// @return totalLifetimeTokens The total lifetime tokens from the NFT.
    function _totalLifetimeTokensFromNft(uint256 _mintTimestamp) internal view returns (uint256 totalLifetimeTokens) {
        return (block.timestamp - _mintTimestamp) * TOKEN_EMISSION_RATE;
    }

    /// @notice Calculate the new tokens to mint for an account based on the Settler NFT held by the account.
    /// @param account The account to calculate the new tokens to mint for.
    /// @return nftId The ID of the NFT held by the account.
    /// @return totalLifetimeTokensFromNft The total lifetime tokens from the NFT.
    /// @return newTokensToMint The new tokens to mint for the account.
    function _calculateNewTokensToMint(address account)
        internal
        view
        returns (uint256 nftId, uint256 totalLifetimeTokensFromNft, uint256 newTokensToMint)
    {
        nftId = SETTLEMENT_NFT.getOwnerToId(account);

        uint256 mintedLifetimeTokens = s_mintedTokensFromNft[nftId];
        uint256 mintTimestamp = SETTLEMENT_NFT.getMintTimestamp(nftId);

        totalLifetimeTokensFromNft = _totalLifetimeTokensFromNft(mintTimestamp);
        newTokensToMint = totalLifetimeTokensFromNft - mintedLifetimeTokens;
    }
}
