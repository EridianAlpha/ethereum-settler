// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {console} from "forge-std/Test.sol";
import {SettlerTestSetup} from "./TestSetup.t.sol";

import {ViewAggregator} from "src/ViewAggregator.sol";

// ================================================================
// │                      VIEW AGGREGATOR TESTS                   │
// ================================================================
contract ViewAggregatorTests is SettlerTestSetup {
    function mintNft(address user) public {
        vm.broadcast(user);
        settlementNft.mint();
    }

    function test_GetSequentialData() public {
        mintNft(user1);
        mintNft(user2);

        uint256 user1NftId = settlementNft.getOwnerToId(user1);
        uint256 user2NftId = settlementNft.getOwnerToId(user2);

        ViewAggregator.SettlementData[] memory results = viewAggregator.getSequentialData(user1NftId, user2NftId);

        assertEq(results[0].owner, user1);
        assertEq(results[1].owner, user2);
    }

    function test_GetRandomData() public {
        uint256 startingId = 1;
        uint256 endingId = 1000;

        for (uint256 i = startingId; i <= endingId; i++) {
            mintNft(makeAddr(vm.toString(i)));
        }

        assertEq(viewAggregator.getRandomData(1).length, 1);
        assertEq(viewAggregator.getRandomData(endingId - startingId).length, endingId - startingId);
        assertEq(viewAggregator.getRandomData(endingId + startingId).length, endingId);
    }
}
