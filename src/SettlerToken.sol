// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

import {SettlementNft} from "./SettlementNft.sol";

contract SettlerToken is ERC20, ERC20Permit {
    uint256 public constant s_tokenEmissionRate = 1e18; // Tokens per second
    SettlementNft public immutable i_settlementNft;
    mapping(uint256 => uint256) public s_mintedTokensFromNft;

    constructor(address _nftAddress) ERC20("Ethereum Settler", "SETTLER") ERC20Permit("Ethereum Settler") {
        i_settlementNft = SettlementNft(_nftAddress);
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
        if (i_settlementNft.balanceOf(account) > 0) {
            (,, uint256 unmintedTokensFromNft) = _calculateNewTokensToMint(account);
            accountBalance = super.balanceOf(account) + unmintedTokensFromNft;
        } else {
            accountBalance = super.balanceOf(account);
        }
    }

    function _update(address from, address to, uint256 value) internal override {
        // If the account has an NFT, mint any outstanding tokens based on the time since the NFT was minted
        if (from != address(0) && i_settlementNft.balanceOf(from) > 0) {
            _mintOutstandingTokensFromNft(from);
        }
        super._update(from, to, value);
    }

    function _totalLifetimeTokensFromNft(uint256 _mintTimestamp) internal view returns (uint256) {
        return (block.timestamp - _mintTimestamp) * s_tokenEmissionRate;
    }

    function _calculateNewTokensToMint(address account)
        internal
        view
        returns (uint256 nftId, uint256 totalLifetimeTokensFromNft, uint256 newTokensToMint)
    {
        nftId = i_settlementNft.ownerToId(account);

        uint256 mintedLifetimeTokens = s_mintedTokensFromNft[nftId];
        uint256 mintTimestamp = i_settlementNft.mintTimestamp(nftId);

        totalLifetimeTokensFromNft = _totalLifetimeTokensFromNft(mintTimestamp);
        newTokensToMint = totalLifetimeTokensFromNft - mintedLifetimeTokens;
    }

    function _mintOutstandingTokensFromNft(address account) internal {
        (uint256 nftId, uint256 totalLifetimeTokensFromNft, uint256 newTokensToMint) =
            _calculateNewTokensToMint(account);
        s_mintedTokensFromNft[nftId] = totalLifetimeTokensFromNft;
        _mint(account, newTokensToMint);
    }
}
