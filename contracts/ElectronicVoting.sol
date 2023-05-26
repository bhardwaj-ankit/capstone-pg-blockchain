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
        address CEAddress;
    }

    struct Voter {
        uint256 voterId; // voter unique ID
        string weight;
        string Vname;
        uint8 age;
        uint256 votedTo; // id of the candidate
        address VEAddress;
    }

    struct CandidateResult {
        uint256 candidateId;
        string candidateName;
        uint256 votesCount;
    }

    mapping(address => Candidate) cand;
    mapping(address => Voter) voter;
    mapping(uint256 => uint256) internal votesCount;

    Types.Candidate[] public candidates;
    Types.Voter[] public voters;

    address admin;
    uint256 private votingStartTime;
    uint256 private votingEndTime;
    bool private votingStarted;

    /**
     * @dev Creates a new voting system to choose one of 'candidates'
     * @param startTime_ Voting start time
     * @param endTime_ Voting end time
     */
    constructor(uint256 startTime_, uint256 endTime_) {
        votingStartTime = startTime_;
        votingEndTime = endTime_;
        votingStarted = false;
        admin = msg.sender;
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
        Candidate[_owner] = cand(_Cname, _proposal);
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
        Voter[_owner] = cand(_Vname, vEAddress);
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
     * @return candidatesList_ All the candidates who participate in the election
     */
    function getCandidateElectionEsult(uint256 candidateId)
        public
        view
        returns (CandidateResult memory)
    {
        Candidate storage candidate_ = cand[candidateId];
    
        Candidate memory cc = new Candidate(
            candidateId, candidate_.Cname, candidate_.proposal
        );
        return cc;
    }

    /**
     * @dev sends all candidate list with their votes count
     * @param currentTime_ Current epoch time of length 10.
     * @return candidateList_ List of Candidate objects with votes count
     */
    function getWinner()
        public
        view
        returns (Types.Results[] memory)
    {
        require(votingEndTime < currentTime_);
        Types.Results[] memory resultsList_ = new Types.Results[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] = Types.Results({
                name: candidates[i].name,
                partyShortcut: candidates[i].partyShortcut,
                partyFlag: candidates[i].partyFlag,
                nominationNumber: candidates[i].nominationNumber,
                stateCode: candidates[i].stateCode,
                constituencyCode: candidates[i].constituencyCode,
                voteCount: votesCount[candidates[i].nominationNumber]
            });
        }
        return resultsList_;
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
     * @dev Get election result candidate wise.
     * @param candidateId candidate id of the candidate
     * @return candidatesList_ All the candidates who participate in the election
     */
    function getCandidateElectionEsult(uint256 candidateId)
        public
        view
        returns (CandidateResult memory)
    {
        Candidate storage candidate_ = cand[candidateId];
    
        CandidateResult memory cr = new CandidateResult(
            candidateId, candidate_.Cname, votesCount[candidateId]
        );
        return cr;
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
        isEligibleVote(vEAddress)
    {
        // updating the current voter values
        voter[vEAddress].votedTo = candidateId;

        // updates the votes of the candidate
        uint256 voteCount_ = votesCount[candidateId];
        votesCount[candidateId] = voteCount_ + 1;
    }

    /**
     * @dev To find eligibility of the voter.
     * @param voterId of the current voter
     * @return voterEligible_ Whether the voter with provided voterId is eligible or not
     */
    function isVoterEligible(uint256 voterId)
        public
        view
        returns (bool voterEligible_)
    {
        Voter storage voter_ = voter[voterId];
        if (voter_.age >= 18 && voter_.votedTo == 0) voterEligible_ = true;
    }

    /**
     * @dev Know whether the voter casted their vote or not. If casted get candidate object.
     * @param voterId Aadhar number of the current voter
     * @return userVoted_ Boolean value which gives whether current voter casted vote or not
     * @return candidate_ Candidate details to whom voter casted his/her vote
     */
    function didCurrentVoterVoted(uint256 voterId)
        public
        view
        returns (bool userVoted_, Types.Candidate memory candidate_)
    {
        userVoted_ = (voter[voterId].votedTo != 0);
        if (userVoted_)
            candidate_ = candidate[voter[voterId].votedTo];
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
        isEligibleVote(vEAddress)
    {
        // updating the current voter values
        voter[vEAddress].votedTo = candidateId;

        // updates the votes of the candidate
        uint256 voteCount_ = votesCount[candidateId];
        votesCount[candidateId] = voteCount_ + 1;
    }

    /**
     * @dev Gives ending epoch time of voting
     * @return endTime_ When the voting ends
     */
    function getVotingEndTime() public view returns (uint256 endTime_) {
        endTime_ = votingEndTime;
    }

    /**
     * @dev used to update the voting start & end times
     * @param startTime_ Start time that needs to be updated
     * @param currentTime_ Current time that needs to be updated
     */
    function updateVotingStartTime(uint256 startTime_, uint256 currentTime_)
        public
        isAdmin
    {
        require(votingStartTime > currentTime_);
        votingStartTime = startTime_;
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
            voter[voterId].votedTo != 0,
            "The voter already voted."
        );
        require(voter[voterId].weight == 0);
        voters[voter].weight = 1;
    }

    /**
     * @dev To extend the end of the voting
     * @param endTime_ End time that needs to be updated
     * @param currentTime_ Current time that needs to be updated
     */
    function extendVotingTime(uint256 endTime_, uint256 currentTime_)
        public
        isAdmin
    {
        require(votingStartTime < currentTime_);
        require(votingEndTime > currentTime_);
        votingEndTime = endTime_;
    }

    /**
     * @dev sends all candidate list with their votes count
     * @param candidateId Current epoch time of length 10.
     * @return CandidateResult List of Candidate objects with votes count
     */
    function getResults(uint256 candidateId)
        public
        view
        returns (CandidateResult memory)
    {
        require(votingEndTime < currentTime_);
        Types.Results[] memory resultsList_ = new Types.Results[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] = Types.Results({
                name: candidates[i].name,
                candidateId: candidates[i].candidateId,
                voteCount: votesCount[candidates[i].candidateId]
            });
        }
        return resultsList_;
    }

    /**
     * @notice To check if the voting is open
     */
    modifier votingIsStarted() 
    {
        require(votingStarted == "ONGOING");
        _;
    }

    /**
     * @notice To check if the voter's age is greater than or equal to 18
     * @param voterId of the current voter
     * @param candidateId Nomination number of the candidate
     */
    modifier isEligibleVote(uint256 voterId, uint256 candidateId) {
        Types.Voter memory voter_ = voter[voterId];
        Types.Candidate memory candidate_ = candidate[candidateId];
        require(voter_.age >= 18);
        require(voter_.votedTo == 0);
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