// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {ViewAggregator} from "src/ViewAggregator.sol";

contract DeployViewAggregator is Script {
    function run(address _nftAddress) public returns (address deployedViewAggregatorAddress) {
        vm.startBroadcast(msg.sender);
        deployedViewAggregatorAddress = address(new ViewAggregator(_nftAddress));
        vm.stopBroadcast();
    }
}
