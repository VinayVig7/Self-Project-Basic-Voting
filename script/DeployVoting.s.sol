// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Voting} from "src/Voting.sol";

contract DeployVoting is Script {
    Voting deployer;
    uint256 votingTime = 2 hours;
    uint256 minimumVoteThreshold = 5;
    uint256 waitingTime = 10 minutes;

    function run() public returns (Voting){
        vm.startBroadcast();
        deployer = new Voting(votingTime, minimumVoteThreshold, waitingTime);
        vm.stopBroadcast();
        return deployer;
    }
}
