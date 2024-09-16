// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SettlerTestSetup} from "./TestSetup.t.sol";

import {SettlementNft} from "src/SettlementNft.sol";

// ================================================================
// │                            NFT TESTS                         │
// ================================================================
contract NftTests is SettlerTestSetup {
    function test_mintNft() public {
        vm.broadcast(user1);
        settlementNft.mint();
        assertEq(settlementNft.balanceOf(user1), 1);
    }

    function test_revertIfMintTwice() public {
        vm.startBroadcast(user1);
        settlementNft.mint();
        vm.expectRevert(SettlementNft.SettlementNft_SingleActivePerAddress.selector);
        settlementNft.mint();
    }

    function test_transferNft() public {
        vm.startBroadcast(user1);
        settlementNft.mint();

        // Get the tokenId of the newly minted NFT
        uint256 tokenId = settlementNft.getOwnerToId(user1);

        // Transfer the NFT to user2
        settlementNft.safeTransferFrom(user1, user2, tokenId);
        vm.stopBroadcast();

        assertEq(settlementNft.balanceOf(user1), 0);
        assertEq(settlementNft.balanceOf(user2), 1);
    }

    function test_MintAgainAfterTransfer() public {
        vm.startBroadcast(user1);
        settlementNft.mint();

        // Get the tokenId of the newly minted NFT
        uint256 initialTokenId = settlementNft.getOwnerToId(user1);

        // Transfer the NFT to user2
        settlementNft.safeTransferFrom(user1, user2, initialTokenId);

        // Mint a new NFT to user1
        settlementNft.mint();

        assertEq(settlementNft.balanceOf(user1), 1);
        assertNotEq(settlementNft.getOwnerToId(user1), initialTokenId);
    }

    function test_approveAndTransfer() public {
        vm.startBroadcast(user1);
        settlementNft.mint();

        // Get the tokenId of the newly minted NFT
        uint256 tokenId = settlementNft.getOwnerToId(user1);

        // Approve user2 to transfer the NFT
        settlementNft.approve(user2, tokenId);
        vm.stopBroadcast();

        // Transfer the NFT to user2
        vm.startBroadcast(user2);
        settlementNft.safeTransferFrom(user1, user2, tokenId);
        vm.stopBroadcast();

        assertEq(settlementNft.balanceOf(user1), 0);
        assertEq(settlementNft.balanceOf(user2), 1);
    }

    function test_tokenUriGeneration() public {
        vm.broadcast(user1);
        settlementNft.mint();

        uint256 tokenId = settlementNft.getOwnerToId(user1);
        string memory tokenUri = settlementNft.tokenURI(tokenId);

        console.log(tokenUri);
    }
}
