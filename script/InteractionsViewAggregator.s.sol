// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Forge and Script Imports
import {console} from "lib/forge-std/src/Script.sol";
import {GetDeployedContract} from "script/GetDeployedContract.s.sol";

// Contract Imports
import {ViewAggregator} from "src/ViewAggregator.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// ================================================================
// │                         INTERACTIONS                         │
// ================================================================
contract InteractionsViewAggregator is GetDeployedContract {
    function test() public override {} // Added to remove this whole contract from coverage report.

    // Library directives
    using Address for address payable;

    // Contract variables
    ViewAggregator public viewAggregator;

    function interactionsSetup() public {
        viewAggregator = ViewAggregator(payable(getDeployedContract("ViewAggregator")));
    }

    function getSequentialData(uint256 _startingNftId, uint256 _endingNftId)
        public
        returns (ViewAggregator.SettlementData[] memory)
    {
        interactionsSetup();
        return viewAggregator.getSequentialData(_startingNftId, _endingNftId);
    }

    function getRandomData(uint256 _nftId) public returns (ViewAggregator.SettlementData[] memory) {
        interactionsSetup();
        return viewAggregator.getRandomData(_nftId);
    }
}
