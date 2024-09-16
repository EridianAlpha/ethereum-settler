// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SettlerTestSetup} from "./TestSetup.t.sol";

// ================================================================
// │                          TOKEN TESTS                         │
// ================================================================
contract TokenTests is SettlerTestSetup {
    uint256 public previousBlockTimestamp = block.timestamp;
    uint256 public previousBlockNumber = block.number;
    uint256 public blockIncrease = 1;

    function mintNft(address user) public {
        vm.broadcast(user);
        settlementNft.mint();
    }

    function advanceBlock() public {
        vm.warp(previousBlockTimestamp + BLOCK_PERIOD * blockIncrease);
        vm.roll(previousBlockNumber + BLOCK_NUMBER_INCREASE * blockIncrease);
        blockIncrease++;
    }

    function test_mintNftTokenIncrease() public {
        mintNft(user1);
        advanceBlock();
        assertEq(
            settlerToken.balanceOf(user1), settlerToken.TOKEN_EMISSION_RATE() * BLOCK_PERIOD * BLOCK_NUMBER_INCREASE
        );
    }

    function test_tokenTransferToUserWithoutNft() public {
        mintNft(user1);
        advanceBlock();

        uint256 user1InitialBalance = settlerToken.balanceOf(user1);

        // Transfer all tokens from user1 to user2
        vm.broadcast(user1);
        settlerToken.transfer(user2, user1InitialBalance);

        assertEq(settlerToken.balanceOf(user1), 0);
        assertEq(settlerToken.balanceOf(user2), user1InitialBalance);

        // Advance the block again to check that
        // - The balance of user2 remains the same
        // - The balance of user1 increases
        advanceBlock();
        assertEq(settlerToken.balanceOf(user1), user1InitialBalance);
        assertEq(settlerToken.balanceOf(user2), user1InitialBalance);
    }

    function test_tokenTransferToUserWithNft() public {
        mintNft(user1);
        mintNft(user2);
        advanceBlock();

        uint256 user1InitialBalance = settlerToken.balanceOf(user1);
        uint256 user2InitialBalance = settlerToken.balanceOf(user2);

        // Transfer all tokens from user1 to user2
        vm.broadcast(user1);
        settlerToken.transfer(user2, user1InitialBalance);

        assertEq(settlerToken.balanceOf(user1), 0);
        assertEq(settlerToken.balanceOf(user2), user1InitialBalance + user2InitialBalance);

        // Advance the block again to check that
        // - The balance of user2 increases and includes the tokens from user1
        // - The balance of user1 increases
        advanceBlock();

        assertEq(settlerToken.balanceOf(user1), user1InitialBalance);
        assertEq(settlerToken.balanceOf(user2), user1InitialBalance + user2InitialBalance * 2);
    }
}
