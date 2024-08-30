// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

interface IZKVerifier {
    function verifyProof(bytes memory proofData) external view returns (bool);
}

contract ProfileManagement is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _profileIds;

    ArbSys private constant arbsys = ArbSys(address(100)); 
    IZKVerifier public zkVerifier;

    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    struct Profile {
        uint256 id;
        address user;
        string data;
        bool isVerified;
    }

    mapping(uint256 => Profile) public profiles;

    event ProfileCreated(uint256 indexed profileId, address indexed user, string data);
    event ProfileVerified(uint256 indexed profileId, address indexed verifier);

    constructor(address zkVerifierAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(VERIFIER_ROLE, msg.sender);
        zkVerifier = IZKVerifier(zkVerifierAddress);
    }

    function createProfile(string memory data, bytes memory proofData) public {
        require(zkVerifier.verifyProof(proofData), "Invalid ZK proof");

        _profileIds.increment();
        uint256 newProfileId = _profileIds.current();

        profiles[newProfileId] = Profile({
            id: newProfileId,
            user: msg.sender,
            data: data,
            isVerified: false
        });

        emit ProfileCreated(newProfileId, msg.sender, data);

        bytes memory l1Data = abi.encode(newProfileId, data);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function verifyProfile(uint256 profileId) public onlyRole(VERIFIER_ROLE) {
        require(profiles[profileId].id != 0, "Profile does not exist");
        require(!profiles[profileId].isVerified, "Profile already verified");

        profiles[profileId].isVerified = true;

        emit ProfileVerified(profileId, msg.sender);

        // L2'den L1'e veri gönder
        bytes memory l1Data = abi.encode(profileId, msg.sender);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function getProfile(uint256 profileId) public view returns (Profile memory) {
        require(profiles[profileId].id != 0, "Profile does not exist");
        return profiles[profileId];
    }
}
