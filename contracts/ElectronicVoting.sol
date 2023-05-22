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
    Types.Candidate[] public candidates;
    mapping(uint256 => Types.Voter) voter;
    mapping(uint256 => Types.Candidate) candidate;
    mapping(uint256 => uint256) internal votesCount;

    address admin;
    uint256 private votingStartTime;
    uint256 private votingEndTime;

    /**
     * @dev Creates a new voting system to choose one of 'candidates'
     * @param startTime_ Voting start time
     * @param endTime_ Voting end time
     */
    constructor(uint256 startTime_, uint256 endTime_) {
        votingStartTime = startTime_;
        votingEndTime = endTime_;
        admin = msg.sender;
    }

    /**
     * @dev Get candidate list.
     * @return candidatesList_ All the candidates who participate in the election
     */
    function getCandidateList()
        public
        view
        returns (Types.Candidate[] memory)
    {
        uint256 _politicianOfMyConstituencyLength = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            _politicianOfMyConstituencyLength++;
        }
        Types.Candidate[] memory cc = new Types.Candidate[](
            _politicianOfMyConstituencyLength
        );

        uint256 _indx = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            
                cc[_indx] = candidates[i];
                _indx++;
        }
        return cc;
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
        Types.Voter storage voter_ = voter[voterId];
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
     * @param voterId of the voter to avoid re-entry
     * @param currentTime_ To check if the election has started or not
     */
    function vote(
        uint256 candidateId,
        uint256 voterId,
        uint256 currentTime_
    )
        public
        votingLinesAreOpen(currentTime_)
        isEligibleVote(voterId, candidateId)
    {
        // updating the current voter values
        voter[voterId].votedTo = candidateId;

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
     * @param currentTime_ Current epoch time of length 10.
     * @return candidateList_ List of Candidate objects with votes count
     */
    function getResults(uint256 currentTime_)
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
                candidateId: candidates[i].candidateId,
                voteCount: votesCount[candidates[i].candidateId]
            });
        }
        return resultsList_;
    }

    /**
     * @notice To check if the voting is open
     * @param currentTime_ Current epoch time of the voter
     */
    modifier votingLinesAreOpen(uint256 currentTime_) {
        require(currentTime_ >= votingStartTime);
        require(currentTime_ <= votingEndTime);
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