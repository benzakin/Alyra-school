import React, { Component } from "react";
import 'bootstrap/dist/css/bootstrap.min.css';
import VotingContract from "./contracts/Voting.json";
import getWeb3 from "./getWeb3";

import Accordion from 'react-bootstrap/Accordion';
import Alert from 'react-bootstrap/Alert';
import Card from 'react-bootstrap/Card';
import Navbar from 'react-bootstrap/Navbar';
import Container from 'react-bootstrap/Container';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Stack from 'react-bootstrap/Stack';
import ListGroup from 'react-bootstrap/ListGroup';
import Table from 'react-bootstrap/Table';

import AddressesVoters from "./component/AddressesVoters";
// import Proposals from "./component/Proposals";

import "./App.css";

class App extends Component {
  state = { web3: null, accounts: null, contract: null,contractInformation: null, isWeb3Error:null };

  componentDidMount = async () => {
   
    let isWeb3Error;
    try {
      
      isWeb3Error = false;

      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts (Metamask).
      const accounts = await web3.eth.getAccounts();

      // Get the Voting contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = VotingContract.networks[networkId];       

      const instance = new web3.eth.Contract(
        VotingContract.abi,
        deployedNetwork && deployedNetwork.address,
        
      ); 

      // Set web3, accounts, and contract to the state, and then proceed with runInit 
      this.setState({ web3, accounts, contract: instance, isWeb3Error });
    
    } catch (error) {      
      isWeb3Error = true
      this.setState({isWeb3Error})
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );     
      console.error(error);
    }
  };

  //Initilazation
  runInit = async() => {
    const { contract , accounts} = this.state;

    // Get contract info     
    const contractOwner = await contract.methods.owner().call(); // The owner
    
    const currentWorkflowStatus = await contract.methods.getCurrentWorkflowStatus().call(); // current workflow status
    const proposals = await contract.methods.getProposals().call(); // proposals 
    const votersAdresses = await contract.methods.getVotersAdresses().call(); // addresses on wihtelist
    let winningProposal = null;

    const connectedAccount = accounts[0];
    const isOwner = connectedAccount === contractOwner ? true : false;
   // const isVoter = connectedAccount === contractOwner ? true : false;
   const isVoter = votersAdresses.indexOf(connectedAccount) > -1;
   
   if(currentWorkflowStatus == "5")
   {
     winningProposal = await contract.methods.getWinningProposal().call(); // the winning proposal
   }

    const isVoteOpen = currentWorkflowStatus == "3";

   let  contractInformation = {
        contractOwner: contractOwner,
        currentWorkflowStatus: currentWorkflowStatus,
        proposals: proposals,
        votersAdresses: votersAdresses,
        winningProposal: winningProposal,  
        isVoter : isVoter,
        isVoteOpen :  isVoteOpen     
    };
    
    this.setState({ contractInformation });
    this.setAccountInformation();
    this.getUIWorkflowStatus();

    // ********** Events management **********
    window.ethereum.on('accountsChanged', (accounts) => this.handleAccountsChanged(accounts));
    contract.events.WorkflowStatusChange().on('data', (event) => this.handleWorkflowStatusChange(event))
                                          .on('error', (error) => console.error(error));
    contract.events.VoterRegistered().on('data', (event) => this.handleVoterAdded(event))
                                     .on('error', (error) => console.error(error));
    contract.events.ProposalRegistered().on('data', (event) => this.handleProposalRegistered(event))
                                        .on('error', (error) => console.error(error));     
    contract.events.Voted().on('data', (event) => this.handleVoted(event))
                           .on('error', (error) => console.error(error));
  }

  // Connected account (Need to be call at start and when user change metamastk account !)
  setAccountInformation = async() => {
    const { accounts, contract, contractInformation, web3 } = this.state;
    const connectedAccount = accounts[0];
    const isOwner = connectedAccount === contractInformation.contractOwner ? true : false;
    let voterInformation = null;
    let canVote = false;
    let isRegistered = false;
    let hasVoted = false; 

    const isVoter = contractInformation.votersAdresses.indexOf(connectedAccount) > -1;
  
    if (!isOwner && isVoter)
    {
      voterInformation = await contract.methods.getVoter(connectedAccount).call({ from: connectedAccount });
    }

     canVote = voterInformation && voterInformation.isRegistered && !voterInformation.hasVoted;
     isRegistered = voterInformation && voterInformation.isRegistered;
     hasVoted = voterInformation && voterInformation.hasVoted; 
   
    let accountInformation = {
      account: connectedAccount,
      canVote: canVote,
      hasVoted: hasVoted,
      isOwner: isOwner,
      isRegistered: isRegistered,     
    };

    this.setState({ accountInformation });   
  };

  getUIWorkflowStatus = async() => {
    const { contractInformation } = this.state;

    let UIWorkflowStatus
    switch (contractInformation.currentWorkflowStatus) {
      case '0':
        UIWorkflowStatus = "RegisteringVoters";
        break;
      case '1':
        UIWorkflowStatus = "ProposalsRegistrationStarted";
        break;
      case '2':
        UIWorkflowStatus = "ProposalsRegistrationEnded";
        break;
      case '3':
        UIWorkflowStatus = "VotingSessionStarted";
        break;
      case '4':
        UIWorkflowStatus = "VotingSessionEnded";
        break;
      case '5':
        UIWorkflowStatus = "VotesTallied";
        break;
    }
    this.setState({ UIWorkflowStatus });

  }


  // ========== Handles events ==========
  
  // Account change on Metamask
  handleAccountsChanged = async(newAccounts) => {
    const { web3 } = this.state;
    const reloadedAccounts = await web3.eth.getAccounts();   
    this.setState({ accounts: reloadedAccounts });
    this.setAccountInformation();
  
}

  // Workflow change
  handleWorkflowStatusChange = async(event) => {  
    const { contract, contractInformation } = this.state;
    contractInformation.currentWorkflowStatus = event.returnValues._newStatus;  
    this.setState({ contractInformation });
    this.setAccountInformation();
    this.getUIWorkflowStatus();
  }

  //Voter added
  handleVoterAdded = async(event) => {    
    const { contract, contractInformation } = this.state;
    contractInformation.votersAdresses = await contract.methods.getVotersAdresses().call(); 
    this.setState({ contractInformation });    
    
  }

  //Proposal registred
  handleProposalRegistered = async(event) => {    
    this.listAllProposals();
   
  }

  //Vote done
  handleVoted = async(event) => {    
    this.listAllProposals();
  
  }

// ============== Contract interactions =================

  // Add account
  registeringUsers = async () => {
    try {

      const { accounts, contract } = this.state;
      const address = this.address.value;
      await contract.methods.addVoter(address.trim()).send({ from: accounts[0] }).then(response => {     
        //console.log(response);  
        this.address.value = '';
      })
    } catch (error) {
         alert(error.message, "Error");
    }
  }

  // Open registration
  openProposaRegistration = async () => {
    try {
      const { accounts, contract } = this.state;
      await contract.methods.startProposalsRegistering().send({ from: accounts[0] });
    } catch (error) {
      alert(error.message, "Error");
    }
  }

  // Make a proposal
  addProposal = async() => {
    try{
      const { accounts, contract } = this.state;
      const description = this.proposal.value;

      await contract.methods.addProposal(description).send({ from: accounts[0] }).then(response => {     
        this.proposal.value = '';
      });
    }catch (error) {
      alert(error.message, "Error");
    }
  }

  //List all proposals
  listAllProposals = async () => {
    try {
      const { contract, contractInformation } = this.state;
      contractInformation.proposals = await contract.methods.getProposals().call();
      
      console.log("contractInformation.proposals=");
      console.log(contractInformation.proposals);

      this.setState({ contractInformation });
      this.setAccountInformation();
    } catch (error) {
      alert(error.message, "Error");
    }
  }

  //Close proposal session
  closeProposalRegistrationn = async () => {
    try {
      const { accounts, contract } = this.state;
      await contract.methods.endProposalsRegistering().send({ from: accounts[0] }).then(response => {     
           alert("Close Proposal");
      })
    } catch (error) {
      alert(error.message, "Error");
    }
  }

  //Open vote session
  startVotingSession = async() => {
    try{
      const { accounts, contract } = this.state;
      await contract.methods.startVotingSession().send({ from: accounts[0] });

    }catch (error) {
      alert(error.message, "Error");
    }
  }

  //Close vote session
  endVotingSession = async () => {
    try {
      const { accounts, contract } = this.state;
      await contract.methods.endVotingSession().send({ from: accounts[0] });
    } catch (error) {
      alert(error.message, "Error");
    }
  }

  //Vote action
  voteForProposal = async (index) => {
    try {
      //alert(index.target.value);
      const { accounts, contract } = this.state;
      await contract.methods.setVote(index.target.value).send({from: accounts[0]});
    } catch (error) {
      alert(error.message, "Error");
 
    }
  }

  // Process vote result
  endVotesTallied = async () => {
    try {
      const { accounts, contract } = this.state;
      await contract.methods.endVotesTallied().send({ from: accounts[0] });
    } catch (error) {
      alert(error.message, "Error");
 
    }
  }  
  
  getWinningProposal = async () => {
    try {
      const {contract, contractInformation } = this.state;
        await contract.methods.getWinningProposal().call().then(response => {    
          contractInformation.winningProposal = response;
          console.log(response);
          this.setState({ contractInformation });
     })
    } catch (error) {
      alert(error.message, "Error");
 
    }
  }

// **************************************** Render ****************************************

  render() {
    const { accounts, accountInformation, contractInformation, UIWorkflowStatus } = this.state;
    
    //Loading
    let divConnection = <Alert variant='info'>
      Connect your Metamask
    </Alert> 

    if (!this.state.web3) {
      return divConnection
    }
    
    // ======== DEFINE ALL DIV SECTIONS ========

    //DIV User connection info 
    let divConnectionInfo = accountInformation ? 
      accountInformation.account + " ": 
      "Connect Wallet"
    
    //Contract info
    let isOwner = (accountInformation && accountInformation.isOwner)
    if (contractInformation!=null)
      isOwner= accounts[0] === contractInformation.contractOwner ? true : false;
    
    let isVoter = (accountInformation && accountInformation.canVote)    
    let isRegistrationOpen = (UIWorkflowStatus!=null && UIWorkflowStatus === "ProposalsRegistrationStarted") ? true : false
    let isVoteOpen = (UIWorkflowStatus!=null && UIWorkflowStatus === "VotingSessionStarted") ? true : false
    let isVoteTallied = (UIWorkflowStatus!=null && UIWorkflowStatus === "VotesTallied") ? true : false
    
    //DIV owner
    let divIsOwner = <span className='badge bg-success'>owner</span>

    //DIV workflowStatus
    let uiStatus = UIWorkflowStatus
    
    //DIV Admin buttons


let divOpenProposaRegistrationButtons =
<>
<Button onClick={this.openProposaRegistration}>
   Open proposal registration
   </Button> 
</>

let divCloseProposalRegistrationButtons =
<>
<Button onClick={this.closeProposalRegistrationn}>
  Close proposal registration
  </Button> 
</>

let divStartVotingSessionButtons =
<>
<Button onClick={this.startVotingSession}>
 Start Voting Session
 </Button> 
</>

let divEndVotingSessionButtons =
<>
 <Button onClick={this.endVotingSession}>
 End Voting Session
 </Button> 
</>

let divEndVotesTalliedButtons =
<>
 <Button onClick={this.endVotesTallied}>
 End Voting Session
 </Button> 
</>

let divGetWinningProposalButtons =
<>
 <Button onClick={this.getWinningProposal}>
 Get Winner
 </Button> 
</>


    //DIV Add Voters
    let divAddVoter =  
    <Stack direction="horizontal" gap={3}>
      <Form.Group>
        <Form.Control type="text" id="address"
          ref={(input) => { this.address = input }}
        />
      </Form.Group>
      <Button onClick={this.registeringUsers}>Add new account</Button>
      </Stack>
    
//DIV Add proposal
let divAddProposal = <Stack direction="horizontal" gap={3}><Form className="w-50"> 
<Form.Control type="text" id="proposal" placeholder="Your proposal"
  ref={(input) => { this.proposal = input }}
/>        
</Form>
<Button onClick={this.addProposal}>Enregistrer</Button>
</Stack>

//DIV list proposals
const tdButtonVote = (index) => {
if (isVoter && isVoteOpen) {
  return <>
           <Button onClick={ this.voteForProposal } value={index}>Voter</Button>&nbsp;
         </>;
}else {
  return <></>;
}
}

let divProposals = <ListGroup>
<ListGroup.Item>
  <Table hover>
    <tbody>
      {contractInformation && contractInformation.proposals != null &&
        contractInformation.proposals.map((prop, index) => 
        <tr key={index}>               
        <td>#{index} - {prop.description} ({prop[1]} vote(s))</td>
        <td>{tdButtonVote(index)}</td>
        </tr>)
      }
    </tbody>
  </Table>
</ListGroup.Item>
</ListGroup>
   
     // ======== DISPLAY RENDER ========
    return (
      <div className="App">   
        <Navbar bg="dark" variant="dark">
          <Container>
            <Navbar.Brand href="#">VOTING DAPP - Defi Project #3</Navbar.Brand>
              <Form className="d-flex navbar-brand" > 
              <Button variant="outline-success" onClick={this.runInit}>
              {divConnectionInfo}
              </Button>

              </Form>
          </Container>
        </Navbar>        
        
        <Navbar>
          <Container>
            <Navbar.Brand href="#">Status : {uiStatus}</Navbar.Brand>    
            {uiStatus=="RegisteringVoters" && isOwner? divOpenProposaRegistrationButtons : ""}
          {uiStatus=="ProposalsRegistrationStarted" && isOwner? divCloseProposalRegistrationButtons : ""}
          {uiStatus=="ProposalsRegistrationEnded" && isOwner? divStartVotingSessionButtons : ""}
          {uiStatus=="VotingSessionStarted" && isOwner? divEndVotingSessionButtons : ""}
          {uiStatus=="VotingSessionEnded" && isOwner? divEndVotesTalliedButtons : ""}    
          {uiStatus=="VotesTallied" && isOwner? divGetWinningProposalButtons : ""}    
          </Container>
        </Navbar>    

          <Card key={1}>
          <Card.Header> List voters    </Card.Header>
          <Card.Body>
            <Card.Text>
              {isOwner && uiStatus == "RegisteringVoters" ? divAddVoter : ""}
              <AddressesVoters contractInformation={this.state.contractInformation}></AddressesVoters>
            </Card.Text>
          
          </Card.Body>
        </Card>


        <Card key={2}>
            <Card.Header>Proposals</Card.Header>
            <Card.Body>
              <Card.Text>
              {isVoter && isRegistrationOpen ? divAddProposal : ""}
              {divProposals}
              </Card.Text>
            </Card.Body>
          </Card>

          <Card key={3}>
            <Card.Header>Tally vote</Card.Header>
            <Card.Body>
              <Card.Text>            
              {contractInformation !=null  && contractInformation.winningProposal? 
           contractInformation.winningProposal[0] + "(" + contractInformation.winningProposal[1] + " votes)": ""}  
              </Card.Text>
            </Card.Body>
          </Card>

      </div>
    );
  }
}

export default App;
