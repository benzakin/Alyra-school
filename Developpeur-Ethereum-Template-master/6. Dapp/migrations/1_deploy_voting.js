var SimpleVoting = artifacts.require("./Voting.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleVoting);
};
