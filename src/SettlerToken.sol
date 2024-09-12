// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

import {SettlementNft} from "./SettlementNft.sol";

contract SettlerToken is ERC20, ERC20Permit {
    uint256 public constant TOKEN_EMISSION_RATE = 1e18; // Tokens per second
    SettlementNft public immutable SETTLEMENT_NFT;
    mapping(uint256 => uint256) public s_mintedTokensFromNft;

    constructor(address _nftAddress) ERC20("Ethereum Settler", "SETTLER") ERC20Permit("Ethereum Settler") {
        SETTLEMENT_NFT = SettlementNft(_nftAddress);
    }

    // Useful when NFT is transferred as this function can be called before the NFT is transferred,
    // so that the previous owner receives all their outstanding tokens.
    // It can also be called at any time by anyone,
    // but that does not make any difference to the balance calculations.
    function mintOutstandingTokensFromNft(address account) public {
        _mintOutstandingTokensFromNft(account);
    }

    function balanceOf(address account) public view override returns (uint256 accountBalance) {
        // If the account has an NFT, calculate the unminted balance based on the time since the NFT was minted
        if (SETTLEMENT_NFT.balanceOf(account) > 0) {
            (,, uint256 unmintedTokensFromNft) = _calculateNewTokensToMint(account);
            accountBalance = super.balanceOf(account) + unmintedTokensFromNft;
        } else {
            accountBalance = super.balanceOf(account);
        }
    }

    function _update(address from, address to, uint256 value) internal override {
        // If the account has an NFT, mint any outstanding tokens based on the time since the NFT was minted
        if (from != address(0) && SETTLEMENT_NFT.balanceOf(from) > 0) {
            _mintOutstandingTokensFromNft(from);
        }
        super._update(from, to, value);
    }

    function _totalLifetimeTokensFromNft(uint256 _mintTimestamp) internal view returns (uint256) {
        return (block.timestamp - _mintTimestamp) * TOKEN_EMISSION_RATE;
    }

    function _calculateNewTokensToMint(address account)
        internal
        view
        returns (uint256 nftId, uint256 totalLifetimeTokensFromNft, uint256 newTokensToMint)
    {
        nftId = SETTLEMENT_NFT.s_ownerToId(account);

        uint256 mintedLifetimeTokens = s_mintedTokensFromNft[nftId];
        uint256 mintTimestamp = SETTLEMENT_NFT.s_mintTimestamp(nftId);

        totalLifetimeTokensFromNft = _totalLifetimeTokensFromNft(mintTimestamp);
        newTokensToMint = totalLifetimeTokensFromNft - mintedLifetimeTokens;
    }

    function _mintOutstandingTokensFromNft(address account) internal {
        (uint256 nftId, uint256 totalLifetimeTokensFromNft, uint256 newTokensToMint) =
            _calculateNewTokensToMint(account);
        if (nftId != 0) {
            s_mintedTokensFromNft[nftId] = totalLifetimeTokensFromNft;
            _mint(account, newTokensToMint);
        }
    }
}
