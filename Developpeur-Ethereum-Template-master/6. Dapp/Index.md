======= Context.sol:Context =======
Developer Documentation
{
  "details": "Provides information about the current execution context, including the sender of the transaction and its data. While these are generally available via msg.sender and msg.data, they should not be accessed in such a direct manner, since when dealing with meta-transactions the account sending and paying for execution may not be the actual sender (as far as an application is concerned). This contract is only required for intermediate, library-like contracts.",
  "kind": "dev",
  "methods": {},
  "version": 1
}
User Documentation
{
  "kind": "user",
  "methods": {},
  "version": 1
}

======= Ownable.sol:Ownable =======
Developer Documentation
{
  "details": "Contract module which provides a basic access control mechanism, where there is an account (an owner) that can be granted exclusive access to specific functions. By default, the owner account will be the one that deploys the contract. This can later be changed with {transferOwnership}. This module is used through inheritance. It will make available the modifier `onlyOwner`, which can be applied to your functions to restrict their use to the owner.",
  "kind": "dev",
  "methods":
  {
    "constructor":
    {
      "details": "Initializes the contract setting the deployer as the initial owner."
    },
    "owner()":
    {
      "details": "Returns the address of the current owner."
    },
    "renounceOwnership()":
    {
      "details": "Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner."
    },
    "transferOwnership(address)":
    {
      "details": "Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner."
    }
  },
  "version": 1
}
User Documentation
{
  "kind": "user",
  "methods": {},
  "version": 1
}

======= Voting.sol:Voting =======
Developer Documentation
{
  "details": "This contract handles tVoting Dapp within a small organization.  Voters, all of whom the organization knows, are white-listed through their Ethereum address,  can submit new proposals during a proposal registration session,  and can vote on the proposals during the voting session.",
  "kind": "dev",
  "methods":
  {
    "addProposal(string)":
    {
      "details": "create proposal and add event proposal registred",
      "params":
      {
        "_desc": "description of proposal"
      }
    },
    "addVoter(address)":
    {
      "details": "create voter and add event Voter Registred ",
      "params":
      {
        "_addr": "address for new voter"
      }
    },
    "endProposalsRegistering()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "endVotesTallied()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "endVotingSession()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "getCurrentWorkflowStatus()":
    {
      "details": "get  current status",
      "returns":
      {
        "_0": "WorkflowStatus workflow status"
      }
    },
    "getOneProposal(uint256)":
    {
      "details": "view to get a proposal by index",
      "params":
      {
        "_id": "index from proposal array"
      },
      "returns":
      {
        "_0": "Proposal proposal from index"
      }
    },
    "getProposals()":
    {
      "details": "return a proposal array",
      "returns":
      {
        "_0": "Proposal[] list of proposals"
      }
    },
    "getVoter(address)":
    {
      "details": "view to verify if for the address we have a voter with information (registred,voted and proposal)",
      "params":
      {
        "_addr": "to verify address "
      },
      "returns":
      {
        "_0": "Voter info voter"
      }
    },
    "getVotersAdresses()":
    {
      "details": "view to get list voter",
      "returns":
      {
        "_0": "address[] list address"
      }
    },
    "getWinningProposal()":
    {
      "details": "view to get a proposal by index",
      "returns":
      {
        "_0": "Proposal proposal from index"
      }
    },
    "owner()":
    {
      "details": "Returns the address of the current owner."
    },
    "renounceOwnership()":
    {
      "details": "Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner."
    },
    "setVote(uint256)":
    {
      "details": "verify workflowstatus and if the proposal exist and increment the proposal votecount",
      "params":
      {
        "_id": "proposal id "
      }
    },
    "startProposalsRegistering()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "startVotingSession()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "tallyVotes()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "transferOwnership(address)":
    {
      "details": "Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner."
    },
    "viewTallyVotes()":
    {
      "details": "verify workflowstatus befor to change and add an event"
    },
    "vote(uint256)":
    {
      "details": "add a new vote and calculate the vote in the lead and add event",
      "params":
      {
        "_proposalId": "index from proposal array"
      }
    }
  },
  "title": "Voting",
  "version": 1
}

User Documentation
{
  "kind": "user",
  "methods":
  {
    "addProposal(string)":
    {
      "notice": "add a new proposal for only voter"
    },
    "addVoter(address)":
    {
      "notice": "register a voter by admin "
    },
    "endProposalsRegistering()":
    {
      "notice": "change status workflow  ProposalsRegistrationEnded by admin"
    },
    "endVotesTallied()":
    {
      "notice": "change status workflow  VotesTallied by admin"
    },
    "endVotingSession()":
    {
      "notice": "change status workflow  VotingSessionEnded by admin"
    },
    "getCurrentWorkflowStatus()":
    {
      "notice": "get  current status"
    },
    "getOneProposal(uint256)":
    {
      "notice": "get  proposal by index for only voter"
    },
    "getProposals()":
    {
      "notice": "list all proposal"
    },
    "getVoter(address)":
    {
      "notice": "get  info voter by address for only voter"
    },
    "getVotersAdresses()":
    {
      "notice": "get  list address of voters"
    },
    "getWinningProposal()":
    {
      "notice": "get  proposal by index for only voter"
    },
    "setVote(uint256)":
    {
      "notice": "add a new vote for one proposal by only voter"
    },
    "startProposalsRegistering()":
    {
      "notice": "change status workflow  ProposalsRegistrationStarted by admin"
    },
    "startVotingSession()":
    {
      "notice": "change status workflow  VotingSessionStarted by admin"
    },
    "tallyVotes()":
    {
      "notice": "tally vote by admin (deprecated because risk DoS Gas Limit attack if we have a lot of user and proposal)"
    },
    "viewTallyVotes()":
    {
      "notice": "tally vote visible "
    },
    "vote(uint256)":
    {
      "notice": "add a new vote for only voter"
    }
  },
  "version": 1
}
