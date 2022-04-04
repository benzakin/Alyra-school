
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
```

Les tests sont décomposés en fonction du workflow :

Enregistrement des voteurs :

1.Apres l'ajout d'un voteur on si la propriété registred est vrai

2.On test lors de l'ajout d'un voteur si c'est bien le owner

3.
