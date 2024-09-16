// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {SettlementNft} from "src/SettlementNft.sol";
import {SettlerToken} from "src/SettlerToken.sol";

import {Deploy} from "script/Deploy.s.sol";

contract SettlerTestSetup is Test {
    // Added to remove this whole testing file from coverage report.
    function test() public {}

    SettlementNft settlementNft;
    SettlerToken settlerToken;

    // Setup testing constants
    uint256 internal constant GAS_PRICE = 1;
    uint256 internal constant STARTING_BALANCE = 10 ether;
    uint256 internal constant SEND_VALUE = 1 ether;
    uint256 internal constant BLOCK_PERIOD = 12;
    uint256 internal constant BLOCK_NUMBER_INCREASE = 1;

    // Create users
    address defaultFoundryCaller = address(uint160(uint256(keccak256("foundry default caller"))));
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    function setUp() external {
        // Deploy standard contract and internal functions helper contract
        Deploy deploy = new Deploy();
        (address settlementNftAddress, address settlerTokenAddress) = deploy.run();

        settlementNft = SettlementNft(settlementNftAddress);
        settlerToken = SettlerToken(settlerTokenAddress);

        // Give all the users some starting balance
        vm.deal(user1, STARTING_BALANCE);
        vm.deal(user2, STARTING_BALANCE);
    }
}
