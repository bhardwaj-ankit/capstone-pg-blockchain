// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17.0;

/**
 * @title Job Portal Dapp
 * @author Ankit Bhardwaj
 * @dev Impelements Job portal smart contract
 */
contract JobPortal {
    struct Applicant {
        string name;
        string skill;
        uint256 jobsApplied;
    }

    struct Job {
        string title;
        string companyName;
    }

    address public admin;

    mapping(address => Applicant) public applicants;
    Job[] public jobs;
    address[] public applicantAddresses;

    modifier isAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action");
        _;
    }

    /**
     * @dev Creates a new job portal system'
     */
    constructor() {
        admin = msg.sender;
    }

    /**
     * @dev To add job for the Job Portal.
     * @param _title of the job
     * @param _copanyName of the job
     */
    function addJob(string memory _title, string memory _copanyName) public isAdmin {
        
        // To Check if the job is already added
        for (uint256 i = 0; i < jobs.length; i++) { 
            require(
                keccak256(bytes(jobs[i].title)) != keccak256(bytes(_title)),
                "Job is already added"
            );
        }

        jobs.push(Job({
            title: _title,
            companyName: _copanyName
        }));
    }

    /**
     * @dev To add applicant.
     * @param _name of the applicant
     * @param _skill of the applicant
     * @param _skill of the jobsApplied
     */
    function addApplicant(address _applicant, string memory _name, string memory _skill) public isAdmin {

    
        //To Check if a applicant with the same address is already present
        for (uint256 i = 0; i < applicantAddresses.length; i++) {
            address existingApplicantAddress = applicantAddresses[i];
            require(existingApplicantAddress != _applicant,"Applicant with same address is already registered");
            require(keccak256(bytes(applicants[existingApplicantAddress].name)) != keccak256(bytes(_name)),
                "Applicant is already present"
            );
        }

        applicants[_applicant].name = _name;
        applicants[_applicant].skill = _skill;
        applicants[_applicant].jobsApplied = 0;
        applicantAddresses.push(_applicant); // Add the applicant address
    }

    function applyJob(uint256 _jobId) public {
        Applicant storage sender = applicants[msg.sender];
        sender.jobsApplied = _jobId;
    }

    function getJobDetails(uint256 _jobId) public view returns (uint256, string memory, string memory) {
        require(_jobId < jobs.length, "Invalid job ID");

        Job memory job = jobs[_jobId];
        return (_jobId, job.title, job.companyName);
    }

    function getJobCount() public view returns (uint256) {
        return jobs.length;
    }

    function getAllJobsDetails() public view returns (Job[] memory) {
        Job[] memory jobDetails = new Job[](jobs.length);

        for (uint256 i = 0; i < jobs.length; i++) {
            jobDetails[i] = Job(
                jobs[i].title,
                jobs[i].companyName
                );
        }

        return jobDetails;

    }

    function getApplicantProfile(address _applicantAddress) public view returns (string memory, string memory, uint256) {
        Applicant memory applicant = applicants[_applicantAddress];
        return (applicant.name, applicant.skill, applicant.jobsApplied);
    }

    function getAllApplicantProfiles() public view returns (Applicant[] memory) {
        Applicant[] memory applicantProfiles = new Applicant[](applicantAddresses.length);

        for (uint256 i = 0; i < applicantAddresses.length; i++) {
            address applicantAddress = applicantAddresses[i];
            applicantProfiles[i] = applicants[applicantAddress];
        }

        return applicantProfiles;
    }

}