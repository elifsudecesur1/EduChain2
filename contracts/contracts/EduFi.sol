// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

contract EduFi is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _scholarshipIds;

    ArbSys private constant arbsys = ArbSys(address(100)); 

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");

    struct Scholarship {
        uint256 id;
        string programName;
        uint256 amount;
        address recipient;
        bool isApproved;
        bool isDisbursed;
    }

    mapping(uint256 => Scholarship) public scholarships;
    mapping(address => uint256) public studentScholarships;

    event ScholarshipCreated(uint256 indexed scholarshipId, string programName, uint256 amount);
    event ScholarshipApproved(uint256 indexed scholarshipId, address indexed approver, address indexed recipient);
    event FundsDisbursed(uint256 indexed scholarshipId, address indexed recipient, uint256 amount);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(APPROVER_ROLE, msg.sender);
    }

    function createScholarship(string memory programName, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _scholarshipIds.increment();
        uint256 newScholarshipId = _scholarshipIds.current();

        scholarships[newScholarshipId] = Scholarship({
            id: newScholarshipId,
            programName: programName,
            amount: amount,
            recipient: address(0),
            isApproved: false,
            isDisbursed: false
        });

        emit ScholarshipCreated(newScholarshipId, programName, amount);
    }

    function approveScholarship(uint256 scholarshipId, address recipient) public onlyRole(APPROVER_ROLE) {
        require(scholarships[scholarshipId].id != 0, "Scholarship does not exist");
        require(!scholarships[scholarshipId].isApproved, "Scholarship already approved");

        scholarships[scholarshipId].recipient = recipient;
        scholarships[scholarshipId].isApproved = true;
        studentScholarships[recipient] = scholarshipId;

        emit ScholarshipApproved(scholarshipId, msg.sender, recipient);

        bytes memory data = abi.encode(scholarshipId, recipient);
        arbsys.sendTxToL1{value: 0}(address(this), data);
    }

    function disburseFunds(uint256 scholarshipId) public onlyRole(APPROVER_ROLE) {
        require(scholarships[scholarshipId].id != 0, "Scholarship does not exist");
        require(scholarships[scholarshipId].isApproved, "Scholarship not approved");
        require(!scholarships[scholarshipId].isDisbursed, "Funds already disbursed");

        scholarships[scholarshipId].isDisbursed = true;
        payable(scholarships[scholarshipId].recipient).transfer(scholarships[scholarshipId].amount);

        emit FundsDisbursed(scholarshipId, scholarships[scholarshipId].recipient, scholarships[scholarshipId].amount);

        bytes memory data = abi.encode(scholarshipId, scholarships[scholarshipId].recipient, scholarships[scholarshipId].amount);
        arbsys.sendTxToL1{value: 0}(address(this), data);
    }

    function getScholarshipDetails(uint256 scholarshipId) public view returns (Scholarship memory) {
        require(scholarships[scholarshipId].id != 0, "Scholarship does not exist");
        return scholarships[scholarshipId];
    }
}
