// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// ArbSys kontratını manuel olarak tanımlıyoruz
interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

// ZKVerifier interface tanımı (örnek)
interface ZKVerifier {
    function verifyProof(bytes memory proofData) external view returns (bool);
}

contract Restaking is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _stakeIds;

    ArbSys private constant arbsys = ArbSys(address(100)); // Arbitrum'da ArbSys kontratı
    ZKVerifier public zkVerifier; // ZKVerifier kontratı

    struct Stake {
        uint256 id;
        address staker;
        uint256 amount;
        uint256 stakingTime;
        bool isVerified;
    }

    mapping(uint256 => Stake) public stakes;
    IERC20 public stakingToken;

    event TokensStaked(uint256 indexed stakeId, address indexed staker, uint256 amount);
    event TokensRestaked(uint256 indexed stakeId, address indexed staker, uint256 amount);
    event TokensUnstaked(uint256 indexed stakeId, address indexed staker, uint256 amount);
    event RewardsClaimed(uint256 indexed stakeId, address indexed staker, uint256 rewards);

    constructor(IERC20 _stakingToken, address _zkVerifierAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        stakingToken = _stakingToken;
        zkVerifier = ZKVerifier(_zkVerifierAddress);
    }

    function stakeTokens(uint256 amount, bytes memory proofData) public {
        require(zkVerifier.verifyProof(proofData), "Invalid ZK proof");
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        _stakeIds.increment();
        uint256 newStakeId = _stakeIds.current();

        stakes[newStakeId] = Stake({
            id: newStakeId,
            staker: msg.sender,
            amount: amount,
            stakingTime: block.timestamp,
            isVerified: true
        });

        emit TokensStaked(newStakeId, msg.sender, amount);

        bytes memory l1Data = abi.encode(newStakeId, amount);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function restakeTokens(uint256 stakeId, uint256 amount) public {
        Stake storage stake = stakes[stakeId];
        require(stake.staker == msg.sender, "Only staker can restake");

        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        stake.amount += amount;
        stake.stakingTime = block.timestamp;

        emit TokensRestaked(stakeId, msg.sender, amount);

        bytes memory l1Data = abi.encode(stakeId, amount);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function unstakeTokens(uint256 stakeId) public {
        Stake storage stake = stakes[stakeId];
        require(stake.staker == msg.sender, "Only staker can unstake");

        uint256 amount = stake.amount;
        delete stakes[stakeId];

        require(stakingToken.transfer(msg.sender, amount), "Token transfer failed");

        emit TokensUnstaked(stakeId, msg.sender, amount);

        bytes memory l1Data = abi.encode(stakeId, amount);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function claimRewards(uint256 stakeId) public {
        Stake storage stake = stakes[stakeId];
        require(stake.staker == msg.sender, "Only staker can claim rewards");

        uint256 rewards = calculateRewards(stake.amount, stake.stakingTime);

        require(stakingToken.transfer(msg.sender, rewards), "Reward transfer failed");

        emit RewardsClaimed(stakeId, msg.sender, rewards);

        bytes memory l1Data = abi.encode(stakeId, rewards);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function calculateRewards(uint256 amount, uint256 stakingTime) internal view returns (uint256) {
        uint256 duration = block.timestamp - stakingTime;
        return (amount * duration) / 10000; 
    }
}
