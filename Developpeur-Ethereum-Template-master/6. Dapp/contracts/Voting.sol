// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";


/**
 * @title Voting
 * @dev This contract handles tVoting Dapp within a small organization. 
 * Voters, all of whom the organization knows, are white-listed through their Ethereum address, 
 * can submit new proposals during a proposal registration session, 
 * and can vote on the proposals during the voting session.
 */
contract Voting is Ownable {

    // arrays for draw, uint for single
    // uint[] winningProposalsID;
    // Proposal[] public winningProposals;
    uint public winningProposalID;
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum  WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public workflowStatus;
    Proposal[] proposalsArray;
    mapping (address => Voter) voters;
    address[] private votersAddresses;

    event VoterRegistered(address _voterAddress); 
    event WorkflowStatusChange(WorkflowStatus _previousStatus, WorkflowStatus _newStatus);
    event ProposalRegistered(uint _proposalId);
    event Voted (address _voter, uint _proposalId);

    modifier onlyVoters() {
        require(voters[msg.sender].isRegistered, "You're not a voter");
        _;
    }
    
    /// @notice get  info voter by address for only voter
    /// @dev view to verify if for the address we have a voter with information (registred,voted and proposal)
    /// @param _addr to verify address 
    /// @return Voter info voter
    function getVoter(address _addr) external onlyVoters view returns (Voter memory) {
        return voters[_addr];
    }
    
    /// @notice get  proposal by index for only voter
    /// @dev view to get a proposal by index
    /// @param _id index from proposal array
    /// @return Proposal proposal from index
    function getOneProposal(uint _id) external onlyVoters view returns (Proposal memory) {
        return proposalsArray[_id];
    }

 
    // ::::::::::::: REGISTRATION ::::::::::::: // 

    /// @notice register a voter by admin 
    /// @dev create voter and add event Voter Registred 
    /// @param _addr address for new voter
    function addVoter(address _addr) external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
        require(voters[_addr].isRegistered != true, 'Already registered');
    
        voters[_addr].isRegistered = true;

        votersAddresses.push(_addr);

        emit VoterRegistered(_addr);
    }
 
    /* facultatif
     * function deleteVoter(address _addr) external onlyOwner {
     *   require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
     *   require(voters[_addr].isRegistered == true, 'Not registered.');
     *   voters[_addr].isRegistered = false;
     *  emit VoterRegistered(_addr);
    }*/

    // ::::::::::::: PROPOSAL ::::::::::::: // 

    /// @notice add a new proposal for only voter
    /// @dev create proposal and add event proposal registred
    /// @param _desc description of proposal
    function addProposal(string memory _desc) external onlyVoters {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Proposals are not allowed yet');
        require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")), 'Vous ne pouvez pas ne rien proposer'); // facultatif
        // voir que desc est different des autres

        Proposal memory proposal;
        proposal.description = _desc;
        proposalsArray.push(proposal);
        emit ProposalRegistered(proposalsArray.length-1);
    }

    // ::::::::::::: VOTE ::::::::::::: //
    /// @notice add a new vote for one proposal by only voter
    /// @dev verify workflowstatus and if the proposal exist and increment the proposal votecount
    /// @param _id proposal id 
    function setVote( uint _id) external onlyVoters {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        require(voters[msg.sender].hasVoted != true, 'You have already voted');
        require(_id < proposalsArray.length, 'Proposal not found'); // pas obligé, et pas besoin du >0 car uint

        voters[msg.sender].votedProposalId = _id;
        voters[msg.sender].hasVoted = true;
        proposalsArray[_id].voteCount++;

        emit Voted(msg.sender, _id);
    }

    // ::::::::::::: STATE ::::::::::::: //

    /* on pourrait factoriser tout ça: par exemple:
    *
    *  modifier checkWorkflowStatus(uint  _num) {
    *    require (workflowStatus=WorkflowStatus(uint(_num)-1), "bad workflowstatus");
    *    require (_num != 5, "il faut lancer tally votes");
    *    _;
    *  }
    *
    *  function setWorkflowStatus(uint _num) public checkWorkflowStatus(_num) onlyOwner {
    *    WorkflowStatus old = workflowStatus;
    *    workflowStatus = WorkflowStatus(_num);
    *    emit WorkflowStatusChange(old, workflowStatus);
    *   } 
    *
    *  ou plus simplement:
    *  function nextWorkflowStatus() onlyOwner{
    *    require (uint(workflowStatus)!=4, "il faut lancer tallyvotes");
    *    WorkflowStatus old = workflowStatus;
    *    workflowStatus= WorkflowStatus(uint (workflowStatus) + 1);
    *    emit WorkflowStatusChange(old, workflowStatus);
    *  }
    *
    */ 


    /// @notice change status workflow  ProposalsRegistrationStarted by admin
    /// @dev verify workflowstatus befor to change and add an event
    function startProposalsRegistering() external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Registering proposals cant be started now');
        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    /// @notice change status workflow  ProposalsRegistrationEnded by admin
    /// @dev verify workflowstatus befor to change and add an event
    function endProposalsRegistering() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Registering proposals havent started yet');
        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    /// @notice change status workflow  VotingSessionStarted by admin
    /// @dev verify workflowstatus befor to change and add an event
    function startVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, 'Registering proposals phase is not finished');
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    /// @notice change status workflow  VotingSessionEnded by admin
    /// @dev verify workflowstatus befor to change and add an event
    function endVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    /* function tallyVotesDraw() external onlyOwner {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
        uint highestCount;
        uint[5]memory winners; // egalite entre 5 personnes max
        uint nbWinners;
        for (uint i = 0; i < proposalsArray.length; i++) {
            if (proposalsArray[i].voteCount == highestCount) {
                winners[nbWinners]=i;
                nbWinners++;
            }
            if (proposalsArray[i].voteCount > highestCount) {
                delete winners;
                winners[0]= i;
                highestCount = proposalsArray[i].voteCount;
                nbWinners=1;
            }
        }
        for(uint j=0;j<nbWinners;j++){
            winningProposalsID.push(winners[j]);
            winningProposals.push(proposalsArray[winners[j]]);
        }
        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    } */


   // ::::::::::::: SOLUTION 1 but risk DoS Gas Limit attack ::::::::::::: //

    /// @notice tally vote by admin (deprecated because risk DoS Gas Limit attack if we have a lot of user and proposal)
    /// @dev verify workflowstatus befor to change and add an event
    function tallyVotes() external onlyOwner {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
       uint _winningProposalId;
      for (uint256 p = 0; p <= proposalsArray.length; p++) {
           if (proposalsArray[p].voteCount > proposalsArray[_winningProposalId].voteCount) {
               _winningProposalId = p;
          }
       }
       winningProposalID = _winningProposalId;
       
       workflowStatus = WorkflowStatus.VotesTallied;
       emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }

   // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: // 

   // ::::::::::::: SOLUTION 2 but have to recalculate the winner each time (slow response) ::::::::::::: //

    /// @notice change status workflow  VotesTallied by admin
    /// @dev verify workflowstatus befor to change and add an event
    function endVotesTallied() external onlyOwner {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
       workflowStatus = WorkflowStatus.VotesTallied;
       emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

    }
    /// @notice tally vote visible 
    /// @dev verify workflowstatus befor to change and add an event
   function viewTallyVotes() external view  returns (uint ) {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
       uint _winningProposalId;
      for (uint256 p = 0; p < proposalsArray.length; p++) {
           if (proposalsArray[p].voteCount > proposalsArray[_winningProposalId].voteCount) {
               _winningProposalId = p;
          }
       }
      
      return _winningProposalId;
       
    }
    // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: // 

   // ::::::::::::: SOLUTION 3 for each new vote calculate the vote in the lead ::::::::::::: //
    /// @notice add a new vote for only voter
    /// @dev add a new vote and calculate the vote in the lead and add event
    /// @param _proposalId index from proposal array
    function vote(uint _proposalId)  external onlyVoters {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        require(voters[msg.sender].isRegistered, "You are not allowed to vote");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        proposalsArray[_proposalId].voteCount += 1;
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
 
        if (proposalsArray[_proposalId].voteCount > proposalsArray[winningProposalID].voteCount) {
            winningProposalID = _proposalId;
        }
 
        emit Voted(msg.sender, _proposalId);
    }
   // ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: // 

    /// @notice get  proposal by index for only voter
    /// @dev view to get a proposal by index
    /// @return Proposal proposal from index
    function getWinningProposal() public view returns (Proposal memory) {
        require(workflowStatus == WorkflowStatus.VotesTallied,"Vote need to be Tallied");

        return proposalsArray[winningProposalID];
    }

    /// @notice get  list address of voters
    /// @dev view to get list voter
    /// @return address[] list address
    function getVotersAdresses() public view returns (address[] memory) {
        return votersAddresses;
    }

    /// @notice get  current status
    /// @dev get  current status
    /// @return WorkflowStatus workflow status
    function getCurrentWorkflowStatus() public view returns (WorkflowStatus) {
        return workflowStatus;
    }

    /// @notice list all proposal
    /// @dev return a proposal array
    /// @return Proposal[] list of proposals
    function getProposals() public view returns (Proposal[] memory) {
        return proposalsArray;
    }

}