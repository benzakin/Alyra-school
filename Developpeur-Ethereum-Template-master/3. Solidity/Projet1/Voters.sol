// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Voting 
contract Voting is Ownable {

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
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
    mapping(uint => Proposal) public proposals;

    Proposal[] public arrayProposals;
   
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    modifier onlyWhiteList(address userAddress){
        require(getWhitelistStatus(userAddress),"User address is not allow!");
        _;
    }

    constructor (){
        stateVote = WorkflowStatus.RegisteringVoters;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters,WorkflowStatus.RegisteringVoters);
    }

    function addRegisteringVoters(address addressVoter) private  {
        voters[addressVoter].isRegistered = true;
        voters[addressVoter].hasVoted = false;
        emit VoterRegistered(addressVoter);
    }
 
    //L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum
     function addListRegisteringVoters(address[] memory listAddressVoters) external onlyOwner {
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
    function addProposals(string memory description) public  onlyWhiteList(msg.sender){
        require(stateVote == WorkflowStatus.ProposalsRegistrationStarted,"Add Proposal is not allow!");
        
        Proposal memory currentProposal = Proposal(description,0);
 
        arrayProposals.push(currentProposal);
        emit ProposalRegistered(arrayProposals.length-1);
    }
  
      //Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    function addListProposals(string[] memory listDescription) external  onlyWhiteList(msg.sender){
        require(stateVote == WorkflowStatus.ProposalsRegistrationStarted,"Add Proposal is not allow!");
         for (uint nbProposal = 0; nbProposal < listDescription.length; nbProposal++) {
            addProposals(listDescription[nbProposal]);
         }
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
        stateVote = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted,WorkflowStatus.VotingSessionEnded);
    }

    //L'administrateur du vote comptabilise les votes.
     function sessionVotesTallied() external onlyOwner {
        require(stateVote == WorkflowStatus.VotingSessionEnded,"Session Votes Tallied is not allow!");
        stateVote = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted,WorkflowStatus.VotesTallied);
    }

     //Les électeurs inscrits votent pour leur proposition préférée.
    function vote(uint proposalId) external onlyWhiteList(msg.sender){
        require(stateVote == WorkflowStatus.VotingSessionStarted,"Voting is not allow");
        Voter storage sender = voters[msg.sender];
        require(!sender.hasVoted , "Already voted");
        sender.hasVoted = true;
        sender.votedProposalId = proposalId;

        arrayProposals[proposalId].voteCount += 1;
        proposals[proposalId].voteCount += 1;

        emit Voted(msg.sender,proposalId);
    }

    //Chaque électeur peut voir les votes des autres
    function getChoiceVoter(address addressVoter) public view onlyWhiteList(msg.sender) returns(string memory){
       return arrayProposals[voters[addressVoter].votedProposalId].description;
    }

    //recupere l'index de la proposition gagnante
    function winningProposal() private view returns(uint winningProposalIndex)
    {
       uint winningVoteCount = 0;
        for (uint proposalId = 0; proposalId < arrayProposals.length; proposalId++) {
            if (arrayProposals[proposalId].voteCount > winningVoteCount) {
                winningVoteCount = arrayProposals[proposalId].voteCount;
                winningProposalIndex = proposalId;
            }
        }
                      
        return winningProposalIndex;
     }

    //retourne la description de la proposition gagnante
    function getWinner() external view returns(string memory)
    {
       require(stateVote == WorkflowStatus.VotesTallied,"Voting Session is not finished");
       if (stateVote != WorkflowStatus.VotesTallied) 
        return "Voting Session is not finished";
       else
        return arrayProposals[winningProposal()].description;
    } 

    //liste les propositions avec le nb de votes par proposition
    function getProposals() external view returns (Proposal[] memory)
    {
        return arrayProposals;
    }
}
