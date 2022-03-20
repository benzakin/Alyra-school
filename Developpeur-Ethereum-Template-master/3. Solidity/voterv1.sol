// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
//V2:0x17eC74C24126c63ae29ffa83fD45B8AC8393c49b
//add voters:
/// @title Voting 
//["0xA144165B0fd19D31b51A1AF326Eace56503B6216","0xf1f0017459286b78A06E698C155c947f6c6BeAB3"]
contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
        uint proposalId;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied //comptage des votes
    }

    WorkflowStatus public stateVote;

    mapping(address => Voter) public voters;

    Proposal[] private proposals;
  
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

/*
    constructor (){
                stateVote = WorkflowStatus.RegisteringVoters;
                addVoter(msg.sender);
                emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters,WorkflowStatus.RegisteringVoters);
    }
 */

    modifier onlyWhiteList(address userAddress){
        require(getWhitelistStatus(userAddress),"User address is not allow!");
        _;
    }
 
    function addRegisteringVoters(address addressVoter) private  {
        //require(stateVote != WorkflowStatus.RegisteringVoters,"Registering is not allow!");
        voters[addressVoter].isRegistered = true;
        voters[addressVoter].hasVoted = false;
        emit VoterRegistered(addressVoter);
    }
 
    //L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum
    //Pour économiser des frais de gaz plutot que 1 par 1
    //ex : ["0xA144165B0fd19D31b51A1AF326Eace56503B6216","0xf1f0017459286b78A06E698C155c947f6c6BeAB3"]
    function addListRegisteringVoters(address[] memory listAddressVoters) public onlyOwner {
        require(stateVote == WorkflowStatus.RegisteringVoters,"Registering is not allow");
        for (uint nbVoters = 0; nbVoters < listAddressVoters.length; nbVoters++) {
            addRegisteringVoters(listAddressVoters[nbVoters]);
        }
    }

    //L'administrateur du vote commence la session d'enregistrement de la proposition
    function proposalsRegistrationStarted() external onlyOwner {
        require(stateVote == WorkflowStatus.RegisteringVoters,"Proposals Registration Started is not allow!");
        stateVote = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted,WorkflowStatus.ProposalsRegistrationEnded);
    }

    function getWhitelistStatus(address addressVoters) public view returns(bool){
        return voters[addressVoters].isRegistered;
    }

    //Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    function addProposals(uint proposalId,string memory description) external  onlyWhiteList(msg.sender){
        require(stateVote == WorkflowStatus.ProposalsRegistrationStarted,"Add Proposal is not allow!");
        proposals.push(Proposal(description,0,proposalId));
        emit ProposalRegistered(proposalId);
    }

    function getListProposals() external view returns (Proposal[] memory){
        return proposals;
    }

    //L'administrateur de vote met fin à la session d'enregistrement des propositions.
    function proposalsRegistrationEnded() external onlyOwner {
        require(stateVote == WorkflowStatus.ProposalsRegistrationStarted,"Proposals Registration Ended is not allow!");
        stateVote = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded,WorkflowStatus.ProposalsRegistrationEnded);
    }

    //L'administrateur du vote commence la session de vote.
    function sessionVotingStarted() external onlyOwner {
        require(stateVote == WorkflowStatus.ProposalsRegistrationEnded,"Voting Session Start is not allow!");
        stateVote = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded,WorkflowStatus.VotingSessionStarted);
    }

    //L'administrateur du vote met fin à la session de vote.
    function sessionVotingEnded() external onlyOwner {
        require(stateVote == WorkflowStatus.VotingSessionStarted,"Voting Session End is not allow!");
        //stateVote = WorkflowStatus.VotingSessionEnded;
        stateVote = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted,WorkflowStatus.VotingSessionEnded);
    }

    // function getStateVote() public view returns(WorkflowStatus){
    //     return stateVote ;
    // }

    //Les électeurs inscrits votent pour leurs propositions préférées.
    function vote(uint proposal) external onlyWhiteList(msg.sender){
        require(stateVote == WorkflowStatus.VotingSessionStarted,"Voting is not allow");
        Voter storage sender = voters[msg.sender];
        require(!sender.hasVoted , "Already voted");
        sender.hasVoted = true;
        sender.votedProposalId= proposal;

        proposals[proposal].voteCount += 1;
        emit Voted(msg.sender,proposal);
    }

    function getChoiceVoter(address addressVoter) public view returns(string memory){
       return proposals[voters[addressVoter].votedProposalId].description;
    }

    function winningProposal() private view returns(uint winningProposalIndex)
    {
       uint winningVoteCount = 0;
        for (uint proposal = 0; proposal < proposals.length; proposal++) {
            if (proposals[proposal].voteCount > winningVoteCount) {
                winningVoteCount = proposals[proposal].voteCount;
                winningProposalIndex = proposal;
            }
        }
    }

    function getWinner() external view returns(string memory)
    {
       //require(stateVote != WorkflowStatus.VotesTallied,"Voting Session is not finished");
       if (stateVote != WorkflowStatus.VotesTallied) 
        return "Voting Session is not finished";
       else
        return proposals[winningProposal()].description;
    }

}