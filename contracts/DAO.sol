// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DAOToken.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAO is Ownable {
    // The DAO token contract
    DAOToken public daoToken;

    uint256 public total;

    // Proposal struct
    struct Proposal {
        string title;
        string description;
        uint256 minVote;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        mapping (address => uint256) voters;
    }

    // Array of all proposals
    mapping (uint256 => Proposal) public proposals;

    // Event for a new proposal
    event NewProposal(uint256 indexed proposalId, string title, string description, uint256 minVote, uint256 endTime);

    // Event for a vote
    event Vote(uint256 indexed proposalId, address voter, bool vote, uint256 amount);

    constructor(DAOToken _daoToken) Ownable (msg.sender) {
        daoToken = _daoToken;
    }

    // Function to create a new proposal
    function createProposal(
        string memory _title, 
        string memory _description, 
        uint256 _minVote,
        uint256 _endtime
    ) external onlyOwner returns (uint256) {

        uint256 proposalId = total++;
        Proposal storage proposal = proposals[proposalId];
        proposal.title = _title;
        proposal.description = _description;
        proposal.minVote = _minVote;
        proposal.endTime = _endtime;
        proposal.yesVotes = 0;
        proposal.noVotes = 0;
    
        emit NewProposal(proposalId, _title, _description, _minVote, _endtime);

        return proposalId;
    }
    
    // Function to vote on a proposal
    function vote(
        uint256 _proposalId, 
        bool _support
    ) external {
        Proposal storage proposal = proposals[_proposalId];
        require(daoToken.balanceOf(msg.sender) >= proposal.minVote, "Insufficient tokens to vote");
        require(block.timestamp <= proposal.endTime, "It was expired");

        require(proposal.voters[msg.sender] <= 0, "You have already voted on this proposal");

        if (proposal.voters[msg.sender] > 0) {

        }
        else {
            uint256 voterWeight = daoToken.balanceOf(msg.sender);
             if (_support) {
                proposal.yesVotes += voterWeight;
            } else {
                proposal.noVotes += voterWeight;
            }
            proposal.voters[msg.sender] = voterWeight;
        }
        emit Vote(_proposalId, msg.sender, _support, daoToken.balanceOf(msg.sender));
    }

    // Fallback function to accept Ether
    receive() external payable {}
}