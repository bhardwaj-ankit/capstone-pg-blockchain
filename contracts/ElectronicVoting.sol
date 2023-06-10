// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.25 <0.9.0;

import "./Types.sol";

/**
 * @title Electronic Voting System
 * @author Ankit Bhardwaj
 * @dev Impelements replacement for traditional electronic voting 
 * solutions with distributed, non-repudiation, and security 
 * protection characteristics
 */
contract ElectronicVoting {

    struct Candidate {
        string Cname;
        uint256 candidateId; // unique ID of candidate
        string proposal;
        uint256 voteCount;
        uint256 rank;
    }

    struct Voter {
        address delegate;
        bool voted;
        uint256 vote;
        uint256 voterId; // voter unique ID
        uint weight;
        string Vname;
        uint8 age;
        uint256 votedTo; // id of the candidate
        address VEAddress;
    }
    
    address public admin;
    bool public electionStarted;
    bool public electionEnded;

    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    address[] public voterAddresses;

    /**
     * @dev Creates a new voting system to choose one of 'candidates'
     */
     constructor() {
        admin = msg.sender;
        electionStarted = false;
        electionEnded = false;
    }

    /**
     * @dev To find eligibility of the voter.
     * @param _Cname of the current voter
     * @param _proposal of the current voter
     * @param _owner of the current voter
     */
    function addCandidate(string memory _Cname, string memory _proposal, address _owner)
        public
        isAdmin
        votingIsStarted
    {
        Candidate storage candidate = cand[_owner];
        candidate.Cname = _Cname;
        candidate.proposal = _proposal;
        candidate.candidateId = ++cint;

        candidates.push(candidate);
    }

    /**
     * @dev To find eligibility of the voter.
     * @param _Vname of the current voter
     * @param vEAddress of the current voter
     * @param _owner of the current voter
     */
    function addVoter(string memory _Vname, address vEAddress, address _owner)
        public
        isAdmin
        votingIsStarted
    {
        Voter storage vtr = voter[_owner];
        vtr.Vname = _Vname;
        vtr.VEAddress = vEAddress;
        vtr.voterId = ++vint;
        vtr.weight = 0;
        vtr.votedTo = 0;
        vtr.age = 19;

        voters.push(vtr);
    }

    /**
     * @dev To start voting
     */
    function startElection(address owner)
        public
        isAdmin
    {
        require(msg.sender == owner);
        votingStarted = "ONGOING";
    }

    /**
     * @dev Display candidate profile.
     * @param candidateId candidate id of the candidate
     */
    function displayCandidateProfile(uint256 candidateId)
        public
        view
        returns (uint256 candId, string memory proposal, string memory candidateName)
    {
        Candidate memory candidate_ = candWithId[candidateId];
        candId = candidateId;
        proposal = candidate_.proposal;
        candidateName = candidate_.Cname;
    }


    /**
     * @dev Get election result candidate wise.
     * @param candidateId candidate id of the candidate
     */
    function getCandidateElectionEsult(uint256 candidateId)
        public
        view
        returns (uint256 candId, string memory candidateName, uint256 votes)
    {
        Candidate storage candidate_ = candWithId[candidateId];
    
        candId = candidateId;
        candidateName = candidate_.Cname;
        votes = votesCount[candidateId];
    }

    /**
     * @dev Give your vote to candidate.
     * @param candidateId of the candidate
     * @param vEAddress of the voter to avoid re-entry
     */
    function vote(
        uint256 candidateId,
        address vEAddress
    )
        public
        votingIsStarted()
        isVoterEligible(vEAddress)
    {
        // updating the current voter values
        voter[vEAddress].votedTo = candidateId;

        // updates the votes of the candidate
        uint256 voteCount_ = votesCount[candidateId];
        votesCount[candidateId] = voteCount_ + 1;
    }

    /**
     * @dev To End voting
     */
    function endElection(address owner)
        public
        isAdmin
    {
        require(msg.sender == owner);
        votingStarted = "ENDED";
    }

    /**
     * @dev To find eligibility of the voter.
     * @param vEAddress of the current voter
     */
    modifier  isVoterEligible(address vEAddress)
    {
        Voter storage voter_ = voter[vEAddress];
        require(voter_.age >= 18);
        require(voter_.votedTo == 0);
        require(voter_.weight == 1);
        _;
    }

    /**
     * @dev sends the winner
     */
    function getWinner()
        public
        view
        returns (uint winningVoteCount, uint256 winnerId, string memory winnerName)
    {
        for (uint p = 0; p < candidates.length; p++) {
            Candidate storage candidate_ = candidates[p];
            if (votesCount[candidate_.candidateId] > winningVoteCount) {
                winningVoteCount = votesCount[candidate_.candidateId];
                winnerId = candidate_.candidateId;
                winnerName = candidate_.Cname;
            }
        }
    }

    /** 
     * @dev Give 'voter' the right to vote on this ballot. May only be called by 'admin'.
     * @param voterId id of voter
     */
    function giveRightToVote(uint256 voterId) public {
        require(
            msg.sender == admin,
            "Only admin can give right to vote."
        );
        require(
            voterWithId[voterId].votedTo != 0,
            "The voter already voted."
        );
        require(voterWithId[voterId].weight == 0);
        voters[voterId].weight = 1;
    }

    /**
     * @dev Display candidate profile.
     * @param vEAddress ethereum address of the voter
     */
    function displayVoterProfile(address vEAddress)
        public
        view
        returns (string memory voterName, uint256 votedCandidate, bool voterIsDelegated)
    {
        Voter memory voter_ = voter[vEAddress];
        voterName = voter_.Vname;
        votedCandidate = voter_.votedTo;
        voterIsDelegated = voter_.weight == 1;
    }

    /**
     * @notice To check if the voting is open
     */
    modifier votingIsStarted() 
    {
        require(keccak256(bytes(votingStarted)) == "ONGOING");
        _;
    }

    /**
     * @notice To check if the user is Admin or not
     */
    modifier isAdmin() {
        require(msg.sender == admin);
        _;
    }
}