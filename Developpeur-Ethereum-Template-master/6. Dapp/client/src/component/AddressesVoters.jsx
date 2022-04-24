import React from 'react'
import ListGroup from 'react-bootstrap/ListGroup';
import Table from 'react-bootstrap/Table';

export default class AddressesVoters extends React.Component {

    constructor(props){
        super(props);
    }

    render()
    {
        return(
            <ListGroup variant="flush">       
            <ListGroup.Item>      
              <Table hover>      
                <tbody>
                  {
                    this.props.contractInformation && 
                    typeof (this.props.contractInformation.votersAdresses) !== 'undefined' && 
                    this.props.contractInformation.votersAdresses !== null &&
                    this.props.contractInformation.votersAdresses.map((a) => <tr key={a.toString()}><td>{a}</td></tr>)
                  }
                </tbody>
              </Table>
            </ListGroup.Item>
          </ListGroup>
        )
    }
}