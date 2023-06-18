// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17.0;

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
        string proposal;
        uint256 voteCount;
        uint256 rank;
    }

    struct Voter {
        string Vname;
        address delegate;
        bool voted;
        uint256 vote;
        uint16 age;
    }

    address public admin;
    bool public electionStarted;
    bool public electionEnded;

    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    address[] public voterAddresses;

    modifier isAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    modifier isElectionInProgress() {
        require(electionStarted && !electionEnded, "Election is still in progress");
        _;
    }

    /**
     * @dev Creates a new voting system to choose one of 'candidates'
     */
    constructor() {
        admin = msg.sender;
        electionStarted = false;
        electionEnded = false;
    }

    /**
     * @dev To add candidate for the election.
     * @param _name of the candidate
     * @param _proposal of the candidate
     */
    function addCandidate(string memory _name, string memory _proposal) public isAdmin {
        require(!electionStarted, "Election has already started");

        // To Check if the candidate is already added
        for (uint256 i = 0; i < candidates.length; i++) { 
            require(
                keccak256(bytes(candidates[i].Cname)) != keccak256(bytes(_name)),
                "Candidate is already added"
            );
        }

        candidates.push(Candidate({
            Cname: _name,
            proposal: _proposal,
            voteCount: 0,
            rank: 0
        }));
    }

    /**
     * @dev To add voter.
     * @param _voter address of the voter
     * @param _voterName of the voter
     */
    function addVoter(address _voter, string memory _voterName) public isAdmin {
        require(!electionStarted, "Election has already started");
        require(voters[_voter].voted == false, "ETH Address is already added as a voter");
    
        //To Check if a voter with the same address is already present
        for (uint256 i = 0; i < voterAddresses.length; i++) {
            address existingVoterAddress = voterAddresses[i];
            require(existingVoterAddress != _voter,"Voter with same address is already registered");
            require(keccak256(bytes(voters[existingVoterAddress].Vname)) != keccak256(bytes(_voterName)),
                "Voter with the same name is already present"
            );
        }

        voters[_voter].Vname = _voterName;
        voters[_voter].voted = false;
        voters[_voter].vote = 0;
        voterAddresses.push(_voter); // Add the voter address
    }

      /**
     * @dev To start voting
     */
    function startElection() public isAdmin {
        require(!electionStarted, "Election has already started");
        electionStarted = true;
    }

    function delegateVote(address _delegate) public isElectionInProgress {
        require(voters[msg.sender].voted == false, "You have already voted");
        require(_delegate != msg.sender, "Self-delegation is not allowed");

        voters[msg.sender].delegate = _delegate;
    }

    function castVote(uint256 _candidateId) public isElectionInProgress {
        Voter storage sender = voters[msg.sender];
        require(sender.voted == false, "You have already voted");
        require(_candidateId < candidates.length, "Invalid candidate ID");

        sender.voted = true;
        sender.vote = _candidateId;
        candidates[_candidateId].voteCount++;

        updateRanks(); // Call the updateRanks function after each vote is casted
    }

    function castDelegateVote(uint256 _candidateId) public isElectionInProgress {
        Voter storage sender = voters[msg.sender];
        // require(sender.delegate != null, "No Delegate found");
        require(_candidateId < candidates.length, "Invalid candidate ID");

        sender.voted = true;
        sender.vote = _candidateId;
        candidates[_candidateId].voteCount++;

        updateRanks(); // Call the updateRanks function after each vote is casted
    }

    /**
     * @dev To start voting
     */
    function endElection() public isAdmin {
        require(electionStarted && !electionEnded, "Election is not in progress");
        
        // Assign ranks to candidates based on vote count
        updateRanks();

        electionEnded = true;
        electionStarted = false;
    }

    function getWinner() public view returns (string memory, uint256, uint256) {
        require(electionEnded, "Election is still ongoing");
        
        Candidate memory winner;
        uint256 maxVotes = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winner = candidates[i];
            }
        }

        return (winner.Cname, maxVotes, winner.voteCount);
    }

    function getCandidateDetails(uint256 _candidateId) public view returns (uint256, string memory, string memory) {
        require(_candidateId < candidates.length, "Invalid candidate ID");

        Candidate memory candidate = candidates[_candidateId];
        return (_candidateId, candidate.Cname, candidate.proposal);
    }
    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function getAllCandidatesDetails() public view returns (Candidate[] memory) {
        Candidate[] memory candidateDetails = new Candidate[](candidates.length);

        for (uint256 i = 0; i < candidates.length; i++) {
            candidateDetails[i] = Candidate(
                candidates[i].Cname,
                candidates[i].proposal,
                candidates[i].voteCount,
                candidates[i].rank
                );
        }

        return candidateDetails;

    }

    function getVotesForCandidate(uint256 _candidateId) public view returns (uint256) {
        require(_candidateId < candidates.length, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }

    function getVoterProfile(address _voterAddress) public view returns (string memory, uint256, bool) {
        Voter memory voter = voters[_voterAddress];
        return (voter.Vname, voter.vote, voter.delegate != address(0));
    }

    function getAllVoterProfiles() public view returns (Voter[] memory) {
        Voter[] memory voterProfiles = new Voter[](voterAddresses.length);

        for (uint256 i = 0; i < voterAddresses.length; i++) {
            address voterAddress = voterAddresses[i];
            voterProfiles[i] = voters[voterAddress];
        }

        return voterProfiles;
    }

    // Private function to update ranks
    function updateRanks() private {
        uint256 currentRank = 1;
        uint256 currentVoteCount = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > currentVoteCount) {
                currentVoteCount = candidates[i].voteCount;
                candidates[i].rank = currentRank;
            } else if (candidates[i].voteCount < currentVoteCount) {
                currentVoteCount = candidates[i].voteCount;
                currentRank++;
                candidates[i].rank = currentRank;
            } else {
                candidates[i].rank = currentRank;
            }
        }
    }

}