// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

interface ZKVerifier {
    function verifyProof(bytes memory proofData) external view returns (bool);
}

contract JobListing is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _jobIds;

    ArbSys private constant arbsys = ArbSys(address(100)); 
    ZKVerifier public zkVerifier; 

    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    struct Job {
        uint256 id;
        string title;
        string description;
        address employer;
        uint256 reward;
        bool isCompleted;
        bool isVerified;
    }

    mapping(uint256 => Job) public jobs;

    event JobCreated(uint256 indexed jobId, string title, address indexed employer, uint256 reward);
    event JobCompleted(uint256 indexed jobId);
    event JobVerified(uint256 indexed jobId, address indexed verifier);

    constructor(address zkVerifierAddress) {
        zkVerifier = ZKVerifier(zkVerifierAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(VERIFIER_ROLE, msg.sender);
    }

    function createJob(string memory title, string memory description, uint256 reward, bytes memory proofData) public {
        require(zkVerifier.verifyProof(proofData), "Invalid ZK proof");

        _jobIds.increment();
        uint256 newJobId = _jobIds.current();

        jobs[newJobId] = Job({
            id: newJobId,
            title: title,
            description: description,
            employer: msg.sender,
            reward: reward,
            isCompleted: false,
            isVerified: false
        });

        emit JobCreated(newJobId, title, msg.sender, reward);

        bytes memory l1Data = abi.encode(newJobId, title, reward);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function completeJob(uint256 jobId) public {
        require(jobs[jobId].employer == msg.sender, "Only employer can complete");

        jobs[jobId].isCompleted = true;

        emit JobCompleted(jobId);

        bytes memory l1Data = abi.encode(jobId, jobs[jobId].employer);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function verifyJob(uint256 jobId) public onlyRole(VERIFIER_ROLE) {
        require(jobs[jobId].isCompleted, "Job must be completed first");

        jobs[jobId].isVerified = true;

        emit JobVerified(jobId, msg.sender);

        bytes memory l1Data = abi.encode(jobId, msg.sender);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function getJob(uint256 jobId) public view returns (Job memory) {
        require(jobs[jobId].id != 0, "Job does not exist");
        return jobs[jobId];
    }
}
