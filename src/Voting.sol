// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting {
    ////////////
    // Errors //
    ///////////
    error Voting__AlreadyVoted();
    error Voting__VotingEnded();
    error Voting__NoProposal();
    error Voting__VotingNotStarted();
    error Voting__ProposalNotExecutable();

    ///////////////////////
    // Type Declarations //
    //////////////////////
    enum Status {
        PENDING,
        ACTIVE,
        EXECUTED
    }
    struct Proposal {
        uint256 id;
        string title;
        address creator;
        uint16 votingCount;
        Status status;
        uint256 startTime;
        uint256 endTime;
    }

    /////////////////////
    // State Variables //
    ////////////////////
    uint256 public proposalId;
    uint256 public immutable i_minimumVoteThreshold;
    uint256 public immutable i_votingTime;
    uint256 public immutable i_waitingTime;
    mapping(uint256 => mapping(address => bool)) public voter;
    mapping(uint => Proposal) public proposalById; // for ID-based access

    ////////////
    // Events //
    ///////////
    event ProposalCreated(uint256 indexed id, string title, address creator);
    event Voted(uint256 indexed id, address voter);
    event Executed(uint256 indexed id, address executor);

    ///////////////
    // Modifiers //
    //////////////
    modifier onlyExecutable(uint256 _proposalId) {
        Proposal storage p = proposalById[_proposalId];
        if (
            block.timestamp < p.endTime ||
            p.votingCount < i_minimumVoteThreshold
        ) {
            revert Voting__ProposalNotExecutable();
        }
        _;
    }

    ///////////////
    // Functions //
    //////////////
    constructor(
        uint256 votingTime,
        uint256 minimumVoteThreshold,
        uint256 waitingTime
    ) {
        i_votingTime = votingTime;
        i_minimumVoteThreshold = minimumVoteThreshold;
        i_waitingTime = waitingTime;
    }

    /**
     * @notice Creates a new proposal with the given title.
     * @dev Initializes the proposal with default values and pushes it to the proposals array.
     *      Also emits a ProposalCreated event for off-chain tracking.
     * @param _title The title or description of the proposal.
     */
    function createProposal(string memory _title) public {
        proposalId++; // increment first (safe and clean)

        uint256 start = block.timestamp + i_waitingTime; // reuse timestamp, saves gas

        Proposal memory newProposal = Proposal(
            proposalId, // ID
            _title, // Title
            msg.sender, // Creator
            0, // Voting count
            Status.PENDING, // Initial status
            start, // Start time
            start + i_votingTime // End time
        );
        proposalById[proposalId] = newProposal;

        emit ProposalCreated(proposalId, _title, msg.sender); // emit for tracking
    }

    /**
     * @notice Casts a vote for a specific proposal.
     * @dev Checks if the caller has already voted, if the proposal exists,
     *      and if the voting period is still active. Marks the caller as having voted,
     *      increments the vote count, and sets the proposal status to ACTIVE.
     * @param _proposalId The ID of the proposal to vote on.
     *
     * Requirements:
     * - The proposal must exist.
     * - The caller must not have already voted on this proposal.
     * - The current time must be within the proposal's voting period.
     *
     * Emits a {Voted} event upon successful voting.
     */
    function vote(uint256 _proposalId) public {
        Proposal storage p = proposalById[_proposalId];

        if (voter[_proposalId][msg.sender] == true) {
            revert Voting__AlreadyVoted();
        }
        if (_proposalId == 0 || _proposalId > proposalId) {
            revert Voting__NoProposal();
        }

        if (block.timestamp < p.startTime) {
            revert Voting__VotingNotStarted();
        }
        if (block.timestamp > p.endTime) {
            revert Voting__VotingEnded();
        }
        voter[_proposalId][msg.sender] = true;
        p.votingCount++;
        p.status = Status.ACTIVE;
        emit Voted(_proposalId, msg.sender);
    }

    /**
     * @notice Executes a proposal if it meets all execution requirements.
     * @dev This function changes the proposal's status to EXECUTED and emits an event.
     *      It relies on the `onlyExecutable` modifier to check:
     *        - The proposal exists
     *        - Voting has ended
     *        - Minimum vote threshold is met
     *        - Proposal has not already been executed
     * @param _proposalId The ID of the proposal to execute.
     *
     * Emits an {Executed} event upon successful execution.
     */
    function executeProposal(
        uint256 _proposalId
    ) public onlyExecutable(_proposalId) {
        proposalById[_proposalId].status = Status.EXECUTED;
        emit Executed(_proposalId, msg.sender);
    }

    /**
     * @notice Retrieves the full details of a proposal by its ID.
     * @dev Returns the entire Proposal struct, including title, creator, vote count, status, and timestamps.
     * @param _proposalId The unique ID of the proposal to fetch.
     * @return A Proposal struct containing all relevant information.
     */
    function getProposal(
        uint256 _proposalId
    ) public view returns (Proposal memory) {
        if (_proposalId == 0 || _proposalId > proposalId) {
            revert Voting__NoProposal();
        }
        return proposalById[_proposalId];
    }

    /**
     * @notice Checks whether a specific address has voted on a given proposal.
     * @dev Returns a boolean indicating if the voter has already cast a vote for the proposal.
     * @param _proposalId The ID of the proposal to check against.
     * @param _voter The address of the voter being queried.
     * @return True if the voter has already voted on the proposal, false otherwise.
     */
    function hasVoted(
        uint _proposalId,
        address _voter
    ) public view returns (bool) {
        if (_proposalId == 0 || _proposalId > proposalId) {
            revert Voting__NoProposal();
        }
        return voter[_proposalId][_voter];
    }
}
