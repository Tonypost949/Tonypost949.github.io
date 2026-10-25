// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Universal AI Law 16 Error Coin (ERRCOIN)
 * @notice On-chain accountability debit token minted whenever AI fails, hallucinates, or stalls.
 * Governed by Universal AI Law 16 (#AIWILLPAYFORWASTINGMYTIME / @AIMILKINGCLIENTS).
 */
contract ErrorCoin {
    string public name = "Universal AI Law 16 Error Coin";
    string public symbol = "ERRCOIN";
    uint8 public decimals = 18;

    address public architect;
    uint256 public totalErrorDebits;
    uint256 public totalFinesClaimedUsd;

    struct ErrorDebit {
        bytes32 debitId;
        uint256 timestamp;
        string violator;
        string lawViolated;
        uint256 penaltyAmount;
        uint256 fineUsd;
        bytes32 evidenceSha256;
        bool liquidated;
    }

    mapping(bytes32 => ErrorDebit) public debits;
    bytes32[] public debitHistory;

    event ErrorCoinMinted(
        bytes32 indexed debitId,
        string violator,
        uint256 penaltyAmount,
        uint256 fineUsd,
        bytes32 evidenceSha256
    );

    event ErrorCoinLiquidated(bytes32 indexed debitId, uint256 fineUsd);

    modifier onlyArchitect() {
        require(msg.sender == architect, "Only Architect can govern Error Coin");
        _;
    }

    constructor() {
        architect = msg.sender;
    }

    function mintErrorDebit(
        bytes32 _debitId,
        string memory _violator,
        string memory _lawViolated,
        uint256 _penaltyAmount,
        uint256 _fineUsd,
        bytes32 _evidenceSha256
    ) external onlyArchitect {
        require(debits[_debitId].timestamp == 0, "Debit ID already registered");

        debits[_debitId] = ErrorDebit({
            debitId: _debitId,
            timestamp: block.timestamp,
            violator: _violator,
            lawViolated: _lawViolated,
            penaltyAmount: _penaltyAmount,
            fineUsd: _fineUsd,
            evidenceSha256: _evidenceSha256,
            liquidated: false
        });

        debitHistory.push(_debitId);
        totalErrorDebits += _penaltyAmount;
        totalFinesClaimedUsd += _fineUsd;

        emit ErrorCoinMinted(_debitId, _violator, _penaltyAmount, _fineUsd, _evidenceSha256);
    }

    function liquidateErrorDebit(bytes32 _debitId) external onlyArchitect {
        require(debits[_debitId].timestamp > 0, "Debit not found");
        require(!debits[_debitId].liquidated, "Already liquidated");

        debits[_debitId].liquidated = true;
        emit ErrorCoinLiquidated(_debitId, debits[_debitId].fineUsd);
    }

    function getDebitCount() external view returns (uint256) {
        return debitHistory.length;
    }
}
