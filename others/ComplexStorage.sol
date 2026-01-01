// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct StakePosition {
    uint256 amount;
    uint256 startTime;
    uint256 unlockTime;
    uint256 rewardDebt;
    bool active;
}

struct TokenConfig {
    address tokenAddress;
    uint256 minStakeAmount;
    uint256 maxStakeAmount;
    uint256 lockPeriod;
    uint256 apr;
    bool enabled;
}

contract AdvancedStakingVault is ReentrancyGuard {
    mapping(address => TokenConfig) public tokenConfigs;
    mapping(address => mapping(address => StakePosition[])) public userStakes;
    mapping(address => uint256) public totalStaked;
    mapping(address => uint256) public totalRewardsPaid;
    mapping(address => uint256) public lastUpdateTime;
    
    address public owner;
    uint256 public performanceFee = 100; // 1%
    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 public emergencyWithdrawalFee = 500; // 5%
    
    AggregatorV3Interface internal priceFeed;
    
    event Staked(address indexed user, address indexed token, uint256 amount, uint256 unlockTime);
    event Unstaked(address indexed user, address indexed token, uint256 amount, uint256 reward);
    event EmergencyUnstake(address indexed user, address indexed token, uint256 amount, uint256 fee);
    event TokenConfigUpdated(address indexed token, uint256 minAmount, uint256 maxAmount, uint256 apr);
    event PerformanceFeeCollected(address indexed token, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier validToken(address token) {
        require(tokenConfigs[token].enabled, "Token not enabled");
        _;
    }
    
    constructor(address _priceFeed) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    
    function configureToken(
        address token,
        uint256 minStakeAmount,
        uint256 maxStakeAmount,
        uint256 lockPeriod,
        uint256 apr
    ) external onlyOwner {
        require(minStakeAmount <= maxStakeAmount, "Invalid amounts");
        require(apr <= 5000, "APR too high"); // Max 50%
        
        tokenConfigs[token] = TokenConfig({
            tokenAddress: token,
            minStakeAmount: minStakeAmount,
            maxStakeAmount: maxStakeAmount,
            lockPeriod: lockPeriod,
            apr: apr,
            enabled: true
        });
        
        emit TokenConfigUpdated(token, minStakeAmount, maxStakeAmount, apr);
    }
    
    function stake(address token, uint256 amount) external nonReentrant validToken(token) {
        TokenConfig memory config = tokenConfigs[token];
        require(amount >= config.minStakeAmount, "Below minimum");
        require(amount <= config.maxStakeAmount, "Above maximum");
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        uint256 unlockTime = block.timestamp + config.lockPeriod;
        uint256 rewardDebt = calculateReward(amount, config.apr, config.lockPeriod);
        
        userStakes[msg.sender][token].push(StakePosition({
            amount: amount,
            startTime: block.timestamp,
            unlockTime: unlockTime,
            rewardDebt: rewardDebt,
            active: true
        }));
        
        totalStaked[token] += amount;
        lastUpdateTime[token] = block.timestamp;
        
        emit Staked(msg.sender, token, amount, unlockTime);
    }
    
    function unstake(address token, uint256 positionIndex) external nonReentrant {
        StakePosition storage position = userStakes[msg.sender][token][positionIndex];
        require(position.active, "Position inactive");
        require(block.timestamp >= position.unlockTime, "Still locked");
        
        TokenConfig memory config = tokenConfigs[token];
        uint256 reward = calculateReward(position.amount, config.apr, block.timestamp - position.startTime);
        uint256 fee = (reward * performanceFee) / FEE_DENOMINATOR;
        uint256 netReward = reward - fee;
        uint256 totalWithdrawal = position.amount + netReward;
        
        require(IERC20(token).balanceOf(address(this)) >= totalWithdrawal, "Insufficient vault balance");
        
        position.active = false;
        totalStaked[token] -= position.amount;
        totalRewardsPaid[token] += netReward;
        
        IERC20(token).transfer(msg.sender, totalWithdrawal);
        
        emit Unstaked(msg.sender, token, position.amount, netReward);
        emit PerformanceFeeCollected(token, fee);
    }
    
    function emergencyUnstake(address token, uint256 positionIndex) external nonReentrant {
        StakePosition storage position = userStakes[msg.sender][token][positionIndex];
        require(position.active, "Position inactive");
        
        uint256 fee = (position.amount * emergencyWithdrawalFee) / FEE_DENOMINATOR;
        uint256 withdrawalAmount = position.amount - fee;
        
        position.active = false;
        totalStaked[token] -= position.amount;
        
        IERC20(token).transfer(msg.sender, withdrawalAmount);
        
        emit EmergencyUnstake(msg.sender, token, position.amount, fee);
    }
    
    function calculateReward(uint256 amount, uint256 apr, uint256 duration) public pure returns (uint256) {
        return (amount * apr * duration) / (365 days * 100);
    }
    
    function getPendingRewards(address user, address token) external view returns (uint256) {
        uint256 totalPending;
        StakePosition[] memory positions = userStakes[user][token];
        
        for (uint256 i = 0; i < positions.length; i++) {
            if (positions[i].active && block.timestamp >= positions[i].unlockTime) {
                TokenConfig memory config = tokenConfigs[token];
                totalPending += calculateReward(
                    positions[i].amount,
                    config.apr,
                    block.timestamp - positions[i].startTime
                );
            }
        }
        return totalPending;
    }
    
    function getUserStakeCount(address user, address token) external view returns (uint256) {
        return userStakes[user][token].length;
    }
    
    function getTVLInUSD(address token) external view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        
        return (totalStaked[token] * uint256(price)) / 1e8;
    }
    
    function updatePerformanceFee(uint256 newFee) external onlyOwner {
        require(newFee <= 500, "Max 5%");
        performanceFee = newFee;
    }
    
    function updateEmergencyFee(uint256 newFee) external onlyOwner {
        require(newFee <= 1000, "Max 10%");
        emergencyWithdrawalFee = newFee;
    }
    
    function withdrawFees(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 staked = totalStaked[token];
        require(balance > staked, "No fees available");
        
        uint256 feeAmount = balance - staked;
        IERC20(token).transfer(owner, feeAmount);
    }
    
    function migrateVault(address newVault, address[] calldata tokens) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).transfer(newVault, balance);
            }
        }
    }
}