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

contract Earnings is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _serviceIds;

    ArbSys private constant arbsys = ArbSys(address(100)); 
    ZKVerifier public zkVerifier; 

    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    struct Service {
        uint256 id;
        string description;
        address provider;
        uint256 price;
        bool isCompleted;
        bool isVerified;
    }

    mapping(uint256 => Service) public services;

    event ServiceCreated(uint256 indexed serviceId, string description, address indexed provider, uint256 price);
    event ServiceCompleted(uint256 indexed serviceId);
    event ServiceVerified(uint256 indexed serviceId, address indexed verifier);

    constructor(address _zkVerifierAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(VERIFIER_ROLE, msg.sender); 
        zkVerifier = ZKVerifier(_zkVerifierAddress);
    }

    function createService(string memory description, uint256 price, bytes memory proofData) public {
        require(zkVerifier.verifyProof(proofData), "Invalid ZK proof");

        _serviceIds.increment();
        uint256 newServiceId = _serviceIds.current();

        services[newServiceId] = Service({
            id: newServiceId,
            description: description,
            provider: msg.sender,
            price: price,
            isCompleted: false,
            isVerified: false
        });

        emit ServiceCreated(newServiceId, description, msg.sender, price);

        bytes memory l1Data = abi.encode(newServiceId, description, price);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function completeService(uint256 serviceId) public {
        require(services[serviceId].provider == msg.sender, "Only service provider can complete");

        services[serviceId].isCompleted = true;

        emit ServiceCompleted(serviceId);

        bytes memory l1Data = abi.encode(serviceId, services[serviceId].provider);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function verifyService(uint256 serviceId) public onlyRole(VERIFIER_ROLE) {
        require(services[serviceId].isCompleted, "Service must be completed first");

        services[serviceId].isVerified = true;

        emit ServiceVerified(serviceId, msg.sender);

        bytes memory l1Data = abi.encode(serviceId, msg.sender);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function withdrawEarnings(uint256 serviceId) public {
        require(services[serviceId].provider == msg.sender, "Only service provider can withdraw");
        require(services[serviceId].isVerified, "Service must be verified before withdrawal");

        payable(msg.sender).transfer(services[serviceId].price);

        // L2'den L1'e veri gönder
        bytes memory l1Data = abi.encode(serviceId, msg.sender);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function getService(uint256 serviceId) public view returns (Service memory) {
        require(services[serviceId].id != 0, "Service does not exist");
        return services[serviceId];
    }
}
