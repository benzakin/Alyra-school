
# **⚡️ Projet - Système de vote 2**

### **[Projet #2](https://formation.alyra.fr/products/developpeur-blockchain/categories/2149101531)**

Oui oui, nous allons repartir du défi [“Système de vote”]

Depuis la dernière version, vous avez vu la partie CI/CD avec les tests et le déploiement.

Vous devez alors fournir les tests unitaires de votre smart contract Nous n’attendons pas une couverture à 100% du smart contract mais veillez à bien tester les différentes possibilités de retours (event, revert).


```solidity
Contract: Voting
    Test step for Registering Voters
      ✓ test add voter and get voter (115ms)
      ✓ test requires for addVoter (289ms)
      ✓ test event for addVoter (73ms)
    Test step for Proposals Registration Started Part 1
      ✓ test require startProposalsRegistering (234ms)
      ✓ test event startProposalsRegistering (396ms)
    Test step for Proposals Registration Started Part 2
      ✓ test function getOneProposal (858ms)
      ✓ test step end Proposals Registering (263ms)
      ✓ test step start Voting Session (310ms)
    Test step for Voting Session Started
      ✓ test setVote (249ms)
      ✓ test end Voting Session (323ms)
    Test step for Voting Session Ended
      ✓ test tallyVotes (391ms)

  11 passing (13s)
  
  eth-gas-reporter
·--------------------------------------------|----------------------------|-------------|----------------------------·
|    Solc version: 0.8.12+commit.f00d7308    ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 6718946 gas  │
·············································|····························|·············|·····························
|  Methods                                                                                                           │
···············|·····························|··············|·············|·············|··············|··············
|  Contract    ·  Method                     ·  Min         ·  Max        ·  Avg        ·  # calls     ·  eur (avg)  │
···············|·····························|··············|·············|·············|··············|··············
|  Migrations  ·  setCompleted               ·           -  ·          -  ·      28813  ·           1  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  addProposal                ·       59538  ·      76638  ·      61818  ·          30  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  addVoter                   ·           -  ·          -  ·      50199  ·          59  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  endProposalsRegistering    ·           -  ·          -  ·      30575  ·           5  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  endVotingSession           ·           -  ·          -  ·      30509  ·           2  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  setVote                    ·       58110  ·      78022  ·      66153  ·           6  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  startProposalsRegistering  ·           -  ·          -  ·      47653  ·          10  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  startVotingSession         ·           -  ·          -  ·      30530  ·           6  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Voting      ·  tallyVotes                 ·           -  ·          -  ·      80992  ·           1  ·          -  │
···············|·····························|··············|·············|·············|··············|··············
|  Deployments                               ·                                          ·  % of limit  ·             │
·············································|··············|·············|·············|··············|··············
|  Migrations                                ·           -  ·          -  ·     250142  ·       3.7 %  ·          -  │
·············································|··············|·············|·············|··············|··············
|  Voting                                    ·           -  ·          -  ·    2138726  ·      31.8 %  ·          -  │
·--------------------------------------------|--------------|-------------|-------------|--------------|-------------·

coverage
-------------|----------|----------|----------|----------|----------------|
File         |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-------------|----------|----------|----------|----------|----------------|
 contracts/  |      100 |    96.43 |      100 |      100 |                |
  Voting.sol |      100 |    96.43 |      100 |      100 |                |
-------------|----------|----------|----------|----------|----------------|
All files    |      100 |    96.43 |      100 |      100 |                |
-------------|----------|----------|----------|----------|----------------|
 
```

### Enregistrement des voteurs (Test step for Registering Voters):

-  test l'ajout d'un voteur et si la propriété registred est vrai;
-  test lors de l'ajout d'un voteur si c'est bien le owner;
-  test lors de l'ajout d'un voteur si il a deja été enregistré;
-  test lors de l'ajout d'un voteur si il est bien dans le bon workflow pour le faire;

### Enregistrement des propositions  (Test step for Proposals Registration Started Part 1):

-  test si c'est bien le owner qui fait le changement de workflow;
-  test le changement de workflow;
-  test l'evenement du changement de workflow;

### Enregistrement des propositions  (Test step for Proposals Registration Started Part 2):

-  test si une proposition est vide;
-  test si c'est bien un voteur qui fait la proposition;
-  test l'evenement du changement de workflow;
-  test qu'apres création de la proposition le nombre de vote est initialisé à 0;
-  test l'evenement de l'ajout d'une proposition
-  test si c'est bien le owner qui fait le changement de workflow (ProposalsRegistrationEnded); 
-  test l'evenement du changement de workflow(ProposalsRegistrationEnded);
-  test si c'est bien le owner qui fait le changement de workflow (StartVotingSession); 
-  test le changement de workflow;
-  test l'evenement du changement de workflow (VotingSessionStarted);

### Ajout des votes  (Test step for Voting Session Started):

- test le workflow pour savoir si on est bien en startvotingsession;
- test si le voteur est bien enregistré
- test si le voteur a déjà voté
- test si la proposition n existe pas
- test si le voteur Account6 a voté pour la proposition 1 qui est "Proposal_1"
- test si le voteur Account6 a bien le flag voted à vrai
- test l'evenement Voted avec le voteur Account6 et la proposition 1
- test si c'est bien le owner qui fait le changement de workflow (VotingSessionEnd); 
-  test le changement de workflow;
-  test l'evenement du changement de workflow (VotingSessionEnd);

### Dépouillement  (Test step for Voting Session Ended):

-  test le changement de workflow;
-  test si c'est bien le owner qui fait le changement de workflow (VotesTallied);  
-  test l'evenement 
-  test si le vainqueur est bien la proposition 1 
-  test l'evenement du changement de workflow (VotesTallied);








