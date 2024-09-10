// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// ================================================================
// │                           IMPORTS                            │
// ================================================================

// Forge and Script Imports
import {console} from "lib/forge-std/src/Script.sol";
import {GetDeployedContract} from "script/GetDeployedContract.s.sol";

// Contract Imports
import {SettlementNft} from "src/SettlementNft.sol";
import {SettlerToken} from "src/SettlerToken.sol";

// Library Directive Imports
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

// ================================================================
// │                         INTERACTIONS                         │
// ================================================================
contract Interactions is GetDeployedContract {
    function test() public override {} // Added to remove this whole contract from coverage report.

    // Library directives
    using Address for address payable;

    // Contract variables
    SettlementNft public settlementNft;
    SettlerToken public settlerToken;

    function interactionsSetup() public {
        settlementNft = SettlementNft(payable(getDeployedContract("SettlementNft")));
        settlerToken = settlementNft.i_settlerToken();
    }

    function mintNft() public {
        interactionsSetup();
        vm.startBroadcast();
        settlementNft.mint();
        vm.stopBroadcast();
    }

    function getMintTimestamp(uint256 tokenId) public returns (uint256) {
        interactionsSetup();
        return settlementNft.mintTimestamp(tokenId);
    }

    function getSettlerBalance(address account) public returns (uint256) {
        interactionsSetup();
        return settlerToken.balanceOf(account);
    }
}
