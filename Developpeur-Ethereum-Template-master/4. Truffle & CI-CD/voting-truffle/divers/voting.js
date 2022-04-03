const Voting = artifacts.require("Voting");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract('Voting', accounts => {
    const owner = accounts[0];
    const second = accounts[1];
    const third = accounts[2];

    let VotingInstance;

    describe("test setter/getter", function () {

        beforeEach(async function () {
            VotingInstance = await Voting.new({from:owner});
        });

        it("should add voter, get voter", async () => {
            await VotingInstance.addVoter(second, { from: owner });
            const storedData = await VotingInstance.getVoter(second, { from: owner });
            expect(storedData.isRegistered).to.be.true;
        });
    });

    describe("tests des event, du require, de revert", function () {

        before(async function () {
            VotingInstance = await Voting.deployed();
        });

        it("should add Voting, get event Voting Added", async () => {
            const findEvent = await VotingInstance.addVoter(second, { from: owner });
            expectEvent(findEvent,"VoterRegistered" ,{id: new BN(0)});
        });

  
    });

});