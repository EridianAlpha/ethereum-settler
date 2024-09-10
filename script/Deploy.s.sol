// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {SettlerToken} from "src/SettlerToken.sol";
import {SettlementNft} from "src/SettlementNft.sol";

contract Deploy is Script {
    function run() public returns (address deployedSettlementNftAddress, address deployedSettlerTokenAddress) {
        string memory baseImageUri = "ipfs://QmViprAUrkh1ECEYBnXyNgDhcij6giT6xJuPkNCk8pTjbX";

        vm.startBroadcast(msg.sender);
        deployedSettlementNftAddress = address(new SettlementNft(baseImageUri));
        deployedSettlerTokenAddress = address(SettlementNft(deployedSettlementNftAddress).i_settlerToken());
        vm.stopBroadcast();
    }
}
