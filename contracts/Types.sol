// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.25 <0.9.0;

/**
 * @title Types
 * @author Suresh Konakanchi
 * @dev All custom types that we have used in E-Voting will be declared here
 */
library Types {
    struct Voter {
        uint256 voterId; // voter unique ID
        string weight;
        string Vname;
        uint8 age;
        uint256 votedTo; // id of the candidate
    }

    struct Admin {
        uint256 adminId; // unique admin id 
        bool isActive;
        string name;
    }

    struct Candidate {
        string Cname;
        uint256 candidateId; // unique ID of candidate
        string proposal;
        address CEAddress;
    }

    struct Results {
        string Cname;
        uint256 voteCount; // number of accumulated votes
        uint256 candidateId; // unique ID of candidate
    }
}