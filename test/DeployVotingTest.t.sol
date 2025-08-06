// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Voting} from "src/Voting.sol";
import {DeployVoting} from "script/DeployVoting.s.sol";

contract DeployVotingTest is Test {
    DeployVoting deployer;
    uint256 votingTime = 2 hours;
    uint256 minimumVoteThreshold = 5;
    uint256 waitingTime = 10 minutes;

    function setUp() public {
        deployer = new DeployVoting();
    }
    function testDeployVotingScript() public {
        Voting voting = deployer.run();
        assertEq(voting.i_votingTime(), votingTime);
        assertEq(voting.i_minimumVoteThreshold(), minimumVoteThreshold);
        assertEq(voting.i_waitingTime(), waitingTime);
    }
}
