import React from 'react'
import ListGroup from 'react-bootstrap/ListGroup';
import Table from 'react-bootstrap/Table';
import Button from 'react-bootstrap/Button';

export default class Proposals extends React.Component {

    constructor(props){
        super(props);
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

    render()
    {
      console.log(this.props.contractInformation);
      const tdButtonVote = (index) => {
          if (this.props.contractInformation.isVoter && this.props.contractInformation.isVoteOpen) {

            return <>
                   <Button onClick={ this.voteForProposal } value={index}>Vote</Button>&nbsp;
                 </>;
        }else {
          return <></>;
       }
      }

        return(
          <ListGroup>
          <ListGroup.Item>
            <Table hover>
              <tbody>
                {this.props.contractInformation && this.props.contractInformation.proposals != null &&
                  this.props.contractInformation.proposals.map((prop, index) => 
                  <tr key={index}>               
                  <td>#{index} - {prop.description} ({prop[1]} vote(s))</td>
                  <td>{tdButtonVote(index)}</td>
                  </tr>)
                }
              </tbody>
            </Table>
          </ListGroup.Item>
          </ListGroup>
        )
    }
}