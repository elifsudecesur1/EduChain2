// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface ArbSys {
    function sendTxToL1(address destination, bytes calldata data) external payable returns (uint256);
}

contract BorrowLend is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _loanOfferIds;

    ArbSys private constant arbsys = ArbSys(address(100)); 

    struct LoanOffer {
        uint256 id;
        address lender;
        uint256 amount;
        uint256 interestRate;
        address borrower;
        bool isAccepted;
        bool isVerified;
    }

    mapping(uint256 => LoanOffer) public loanOffers;

    event LoanOfferCreated(uint256 indexed loanOfferId, address indexed lender, uint256 amount, uint256 interestRate);
    event LoanOfferAccepted(uint256 indexed loanOfferId, address indexed borrower);
    event LoanRepaid(uint256 indexed loanOfferId, address indexed borrower);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createLoanOffer(uint256 amount, uint256 interestRate) public {
        _loanOfferIds.increment();
        uint256 newLoanOfferId = _loanOfferIds.current();

        loanOffers[newLoanOfferId] = LoanOffer({
            id: newLoanOfferId,
            lender: msg.sender,
            amount: amount,
            interestRate: interestRate,
            borrower: address(0),
            isAccepted: false,
            isVerified: false
        });

        emit LoanOfferCreated(newLoanOfferId, msg.sender, amount, interestRate);

        bytes memory l1Data = abi.encode(newLoanOfferId, amount, interestRate);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function acceptLoanOffer(uint256 loanOfferId) public payable {
        LoanOffer storage loanOffer = loanOffers[loanOfferId];
        require(loanOffer.id != 0, "Loan offer does not exist");
        require(!loanOffer.isAccepted, "Loan offer is already accepted");
        require(msg.value == loanOffer.amount, "Incorrect ETH amount sent");

        loanOffer.borrower = msg.sender;
        loanOffer.isAccepted = true;
        loanOffer.isVerified = true; 

        payable(loanOffer.lender).transfer(loanOffer.amount);

        emit LoanOfferAccepted(loanOfferId, msg.sender);

        bytes memory l1Data = abi.encode(loanOfferId, msg.sender);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }

    function repayLoan(uint256 loanOfferId) public payable {
        LoanOffer storage loanOffer = loanOffers[loanOfferId];
        require(loanOffer.borrower == msg.sender, "Only borrower can repay the loan");
        require(msg.value == loanOffer.amount + (loanOffer.amount * loanOffer.interestRate / 100), "Incorrect repayment amount");

        payable(loanOffer.lender).transfer(msg.value);

        emit LoanRepaid(loanOfferId, msg.sender);

        bytes memory l1Data = abi.encode(loanOfferId, msg.sender, loanOffer.amount);
        arbsys.sendTxToL1{value: 0}(address(this), l1Data);
    }
}
