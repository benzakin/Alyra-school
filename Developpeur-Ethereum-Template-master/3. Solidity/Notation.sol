// SPDX-License-Identifier: GPL-3.0
//0xA62476dba259301A9e415ca298c75A1aed1A285B
pragma solidity 0.8.12;
import "./StringUtils.sol";

contract Notation   {
 	 
     struct student {
        string name;
        uint[] noteBio;
        uint[] noteMath;
        uint[] noteFr;
	}

    struct prof {
        string name;
        string matiere;
    }

    mapping (address=>prof) public listProf;

    mapping (address=>student) public listStudent;

constructor() {
        // listProf[0xf99f8e27b8afd13e9acdbfa5ea3e1f69ef425d2d] = prof('ProfBio_Name1','Bio');
        // listProf[0xf99f8e27b8afd13e9acdbfa5ea3e1f69ef425d2d] =prof('ProfMath_Name1','Math');  
        // listProf[0xf99f8e27b8afd13e9acdbfa5ea3e1f69ef425d2d] = prof('ProfFr_Name1','Francais');
    }

 function addProf (string memory name, string memory matiere) public {
     listProf[msg.sender] = prof(name,matiere);
 } 

 function addStudent (string memory name) public {
     uint[] memory notes;
     listStudent[msg.sender] = student(name,notes,notes,notes);
 }   

function addNote(address addressProf, address studentId,uint note) public {
//require verifier que le prof est autorisé a mettre la note
    if (StringUtils.equal(listProf[addressProf].matiere ,"Bio"))  {
    listStudent[studentId].noteBio.push(note);
    }

    if (StringUtils.equal(listProf[addressProf].matiere ,"Math"))  {
    listStudent[studentId].noteMath.push(note);
    }

    if (StringUtils.equal(listProf[addressProf].matiere ,"Francais"))  {
    listStudent[studentId].noteFr.push(note);
    }

}

function getNote(address studentId) public view returns(uint)
{
    //return listStudent[studentId];
  
  return   getMoyenneForStudent( studentId) ;
}

function setNote(address addressProf, address studentId,uint numberNote,uint note) public {
//require verifier que le prof est autorisé a mettre la note

   if (StringUtils.equal(listProf[addressProf].matiere ,"Bio"))  {
   listStudent[studentId].noteBio[numberNote]=note;
}

    if (StringUtils.equal(listProf[addressProf].matiere ,"Math"))  {
  listStudent[studentId].noteMath[numberNote]=note;
}

   if (StringUtils.equal(listProf[addressProf].matiere ,"Francais"))  {
   listStudent[studentId].noteFr[numberNote]=note;
}
}

function getMoyenneForStudent(address studentId)  public view returns(uint){
 return (
					getSum(listStudent[studentId].noteBio) + 
				  getSum(listStudent[studentId].noteMath) + 
					getSum(listStudent[studentId].noteFr))/3;
}
	
function getSum(uint[] memory arr) public pure returns(uint)
{
  uint i;
  uint sum = 0;
    
  for(i = 0; i < arr.length; i++)
    sum = sum + arr[i];
  return sum;
}

}