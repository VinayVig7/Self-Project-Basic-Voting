// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Voting} from "src/Voting.sol";

contract VotingTest is Test {
    ///////////////////////////
    // Variables For testing //
    //////////////////////////
    Voting voting;
    uint256 votingTime = 2 hours;
    uint256 voteCount;
    uint256 minimumVoteThreshold = 2; // For testing only 2 votes required for execution
    uint256 waitingTime = 10 minutes;
    address USER = makeAddr("user");
    address VOTER = makeAddr("voter");

    function setUp() public {
        voting = new Voting(votingTime, minimumVoteThreshold, waitingTime);
        voteCount = 0;
    }

    ///////////////
    // Functions //
    //////////////
    function testConstructor() public view {
        // Assert
        assertEq(voting.i_votingTime(), votingTime);
        assertEq(voting.i_minimumVoteThreshold(), minimumVoteThreshold);
        assertEq(voting.i_waitingTime(), waitingTime);
    }

    function testCreateProposal() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 proposalId = 1;
        uint256 votingCount = 0; // 0 because no vote has been done
        uint256 startTime = block.timestamp;

        // Act
        vm.prank(USER);
        voting.createProposal(title);
        Voting.Proposal memory testingProposal = voting.getProposal(proposalId);

        // Assert
        assertEq(testingProposal.id, proposalId);
        assertEq(testingProposal.title, title);
        assertEq(testingProposal.creator, USER);
        assertEq(testingProposal.votingCount, votingCount);
        assertEq(uint(testingProposal.status), uint(Voting.Status.PENDING));
        assertEq(testingProposal.startTime, startTime + waitingTime);
        assertEq(testingProposal.endTime, startTime + votingTime + waitingTime);
    }

    function testVote() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 timeLimitExceedForVoting = waitingTime + 1 minutes;
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);
        Voting.Proposal memory testingProposalBeforeVoting = voting.getProposal(
            proposalId
        );

        // Act
        vm.warp(timeLimitExceedForVoting);
        vm.prank(VOTER);
        voting.vote(proposalId);
        voteCount++;
        Voting.Proposal memory testingProposalAfterVoting = voting.getProposal(
            proposalId
        );

        // Assert
        assertEq(
            testingProposalBeforeVoting.votingCount + voteCount,
            testingProposalAfterVoting.votingCount
        );
        assertEq(
            uint(testingProposalAfterVoting.status),
            uint(Voting.Status.ACTIVE)
        );
    }

    function testVoterCantVoteMoreThanOnce() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 timeLimitExceedForVoting = waitingTime + 1 minutes;
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);

        // Act
        vm.warp(timeLimitExceedForVoting);
        vm.prank(VOTER);
        voting.vote(proposalId);

        // Assert
        vm.prank(VOTER);
        vm.expectRevert(Voting.Voting__AlreadyVoted.selector);
        voting.vote(proposalId);
    }

    function testVoterCantVoteBeforeVotingTimeStart() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);

        // Act
        vm.prank(VOTER);
        vm.expectRevert(Voting.Voting__VotingNotStarted.selector);

        // Assert
        voting.vote(proposalId);
    }

    function testVoterCantVoteAfterVotingEnds() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 timeLimitExceedForVoting = waitingTime + votingTime + 1 minutes;
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);

        // Act
        vm.warp(timeLimitExceedForVoting);
        vm.prank(VOTER);
        vm.expectRevert(Voting.Voting__VotingEnded.selector);

        // Assert
        voting.vote(proposalId);
    }

    function testVoterCantVoteIfThereIsNoProposal() public {
        // Arrange
        uint256 proposalId = 1;

        // Act
        vm.prank(VOTER);
        vm.expectRevert(Voting.Voting__NoProposal.selector);

        // Assert
        voting.vote(proposalId);
    }

    function testExecuteProposal() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 timeLimitExceedForVoting = waitingTime + 1 minutes;
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);
        address VOTER2 = makeAddr("voter2");

        // Act
        vm.warp(timeLimitExceedForVoting);
        vm.prank(VOTER);
        voting.vote(proposalId);
        vm.prank(VOTER2);
        voting.vote(proposalId);
        vm.warp(votingTime + timeLimitExceedForVoting);

        // Assert
        voting.executeProposal(proposalId);
    }

    function testExecuteProposalNotPossibleIfConditionsNotMet() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
        uint256 timeLimitExceedForVoting = waitingTime + 1 minutes;
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);

        // Act
        vm.warp(timeLimitExceedForVoting);
        vm.prank(VOTER);
        voting.vote(proposalId);
        vm.warp(votingTime + timeLimitExceedForVoting);

        // Assert
        vm.expectRevert(Voting.Voting__ProposalNotExecutable.selector);
        voting.executeProposal(proposalId);
    }
    
    /////////////////////
    // Getters Testing //
    ////////////////////
    function testGetProposalRevertWithWrongId() public {
        // Arrange, Act
        uint256 proposalId = 1; // We haven't created any proposal so we will revert

        // Assert
        vm.expectRevert(Voting.Voting__NoProposal.selector);
        voting.getProposal(proposalId);
    }

    function testHasVoted() public {
        // Arrange
        string memory title = "Proposal 1 Testing";
             uint256 timeLimitExceedForVoting = waitingTime + 1 minutes;
        uint256 proposalId = 1;
        vm.prank(USER);
        voting.createProposal(title);

        // Act
        vm.warp(timeLimitExceedForVoting);
        vm.prank(VOTER);
        voting.vote(proposalId);

        // Assert
        bool checkHasVoted = voting.hasVoted(proposalId, VOTER);
        assertTrue(checkHasVoted);
    }

    function testHasVotedRevertIfThereIsNoProposal() public {
        // Arrange, Act
        uint256 proposalId = 1; // We haven't created any proposal so we will revert

        // Assert
        vm.expectRevert(Voting.Voting__NoProposal.selector);
        voting.hasVoted(proposalId, VOTER);
    }
}
