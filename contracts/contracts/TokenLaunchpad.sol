// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// ArbSys contract manually defined
interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

interface zkVerifier {
    function verifyProof(bytes memory proofData) external view returns (bool);
}

contract TokenLaunchpad is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _launchpadIds;

    ArbSys private constant arbsys = ArbSys(address(100));
    zkVerifier public zkVerifierInstance; 

    struct Launchpad {
        uint256 id;
        string name;
        uint256 totalTokens;
        uint256 tokenPrice;
        uint256 soldTokens;
        address owner;
        bool isCompleted;
        bool isVerified;
    }

    mapping(uint256 => Launchpad) public launchpads;

    event LaunchpadCreated(uint256 indexed launchpadId, string name, uint256 totalTokens, uint256 tokenPrice, address indexed owner);
    event TokensPurchased(uint256 indexed launchpadId, address indexed buyer, uint256 amount);
    event LaunchpadFinalized(uint256 indexed launchpadId);

    constructor(address _zkVerifier) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        zkVerifierInstance = zkVerifier(_zkVerifier); 
    }

    function createLaunchpad(string memory name, uint256 totalTokens, uint256 tokenPrice, bytes memory proofData) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(zkVerifierInstance.verifyProof(proofData), "Invalid ZK proof");

        _launchpadIds.increment();
        uint256 newLaunchpadId = _launchpadIds.current();

        launchpads[newLaunchpadId] = Launchpad({
            id: newLaunchpadId,
            name: name,
            totalTokens: totalTokens,
            tokenPrice: tokenPrice,
            soldTokens: 0,
            owner: msg.sender,
            isCompleted: false,
            isVerified: false
        });

        emit LaunchpadCreated(newLaunchpadId, name, totalTokens, tokenPrice, msg.sender);

        // Send data from L2 to L1
        bytes memory l1Data = abi.encode(newLaunchpadId, name, totalTokens, tokenPrice);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function purchaseTokens(uint256 launchpadId, uint256 amount) public payable {
        Launchpad storage launchpad = launchpads[launchpadId];
        require(launchpad.id != 0, "Launchpad does not exist");
        require(!launchpad.isCompleted, "Launchpad is completed");
        require(launchpad.soldTokens + amount <= launchpad.totalTokens, "Not enough tokens available");
        require(msg.value == amount * launchpad.tokenPrice, "Incorrect ETH amount sent");

        launchpad.soldTokens += amount;

        emit TokensPurchased(launchpadId, msg.sender, amount);

        bytes memory l1Data = abi.encode(launchpadId, msg.sender, amount);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function finalizeLaunchpad(uint256 launchpadId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        Launchpad storage launchpad = launchpads[launchpadId];
        require(launchpad.id != 0, "Launchpad does not exist");
        require(!launchpad.isCompleted, "Launchpad is already completed");

        launchpad.isCompleted = true;

        emit LaunchpadFinalized(launchpadId);

        bytes memory l1Data = abi.encode(launchpadId, launchpad.totalTokens);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }
}
