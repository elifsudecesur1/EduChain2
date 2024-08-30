// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

contract VerifierManagement is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _verifierIds;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    ArbSys private constant arbsys = ArbSys(address(100)); 

    struct Verifier {
        uint256 id;
        address account;
        bool isActive;
        uint256 rewards;
    }

    mapping(uint256 => Verifier) public verifiers;
    mapping(address => uint256) public verifierIds;

    event VerifierAdded(uint256 indexed verifierId, address indexed account);
    event VerifierRemoved(uint256 indexed verifierId, address indexed account);
    event VerifierRewarded(uint256 indexed verifierId, uint256 amount);

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function addVerifier(address account) public onlyRole(ADMIN_ROLE) {
        require(verifierIds[account] == 0, "Verifier already exists");

        _verifierIds.increment();
        uint256 newVerifierId = _verifierIds.current();

        verifiers[newVerifierId] = Verifier({
            id: newVerifierId,
            account: account,
            isActive: true,
            rewards: 0
        });

        verifierIds[account] = newVerifierId;

        grantRole(VERIFIER_ROLE, account);

        emit VerifierAdded(newVerifierId, account);

        bytes memory data = abi.encode(newVerifierId, account);
        arbsys.sendTxToL1{value: 0}(address(this), data);
    }

    function removeVerifier(uint256 verifierId) public onlyRole(ADMIN_ROLE) {
        require(verifiers[verifierId].id != 0, "Verifier does not exist");

        Verifier memory verifier = verifiers[verifierId];

        revokeRole(VERIFIER_ROLE, verifier.account);
        delete verifiers[verifierId];
        delete verifierIds[verifier.account];

        emit VerifierRemoved(verifierId, verifier.account);

        bytes memory data = abi.encode(verifierId, verifier.account);
        arbsys.sendTxToL1{value: 0}(address(this), data);
    }

    function rewardVerifier(uint256 verifierId, uint256 amount) public onlyRole(ADMIN_ROLE) {
        require(verifiers[verifierId].id != 0, "Verifier does not exist");

        Verifier storage verifier = verifiers[verifierId];
        verifier.rewards += amount;

        emit VerifierRewarded(verifierId, amount);

        bytes memory data = abi.encode(verifierId, amount);
        arbsys.sendTxToL1{value: 0}(address(this), data);
    }

    function getVerifier(uint256 verifierId) public view returns (Verifier memory) {
        require(verifiers[verifierId].id != 0, "Verifier does not exist");
        return verifiers[verifierId];
    }
}
