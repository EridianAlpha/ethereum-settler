// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SettlerTestSetup} from "./TestSetup.t.sol";

// ================================================================
// │                           MINT TESTS                         │
// ================================================================
contract MintTests is SettlerTestSetup {
    // Mint an NFT to user1
    // log the token balance
    function test_mintNft() public {
        vm.startBroadcast(user1);

        uint256 blockTimestamp = block.timestamp;

        settlementNft.mint();

        vm.warp(blockTimestamp + 12);
        console.log("User1 balance: ", settlerToken.balanceOf(user1));
    }
}
