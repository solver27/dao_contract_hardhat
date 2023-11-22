const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
  
  describe("DAO", async function () {
    async function deployDao() {
      const [owner, user1] = await ethers.getSigners();
  
      const DAOToken = await ethers.getContractFactory("DAOToken");
      const daoToken = await DAOToken.deploy();

      await daoToken.connect(user1).mint(ethers.parseEther("10"))

      const DAO = await ethers.getContractFactory("DAO");
      const dao = await DAO.deploy(daoToken.getAddress());
  
      return { daoToken, dao, owner, user1 };
    }
  
    describe("Deployment", function () {
      it("Depoyed with correct address and amouont", async function () {
        const { daoToken, dao, user1 } = await loadFixture(deployDao);
  
        expect(await dao.daoToken()).to.equal(await daoToken.getAddress());
        expect(await daoToken.balanceOf(user1)).to.equal(ethers.parseUnits("10"));

      });
  
    });
  
    describe("Function", function () {
      it("Creat Proposal", async function () {
        const { daoToken, dao, user1 } = await loadFixture(deployDao);
        const ONE_WEEK_IN_SECS = 7 * 24 * 60 * 60;
        const endTime = (await time.latest()) + ONE_WEEK_IN_SECS
        await expect(dao.createProposal(
                      "Test Proposal",
                      "This is Test Proposal",
                      ethers.parseEther("50"),
                      endTime
                    ))
                    .to.emit(dao, "NewProposal")
                    .withArgs(0, "Test Proposal", "This is Test Proposal");
      });

      it("Vote", async function () {
        const { daoToken, dao, user1 } = await loadFixture(deployDao);
        const ONE_WEEK_IN_SECS = 7 * 24 * 60 * 60;
        const endTime = (await time.latest()) + ONE_WEEK_IN_SECS
        await dao.createProposal("Test Proposal", "This is Test Proposal", ethers.parseEther("50"), endTime);

        await expect(dao.connect(user1).vote(0, true)).to.be.revertedWith(
          "Insufficient tokens to vote"
        );

        await daoToken.connect(user1).mint(ethers.parseEther("50"));
        await dao.connect(user1).vote(0, true);
        await expect(dao.connect(user1).vote(0, true)).to.be.revertedWith(
          "You have already voted on this proposal"
        );
        await time.increaseTo(endTime);
        await daoToken.mint(ethers.parseEther("50"));
        await expect(dao.vote(0, false)).to.be.revertedWith(
          "It was expired"
        );
      });
    });
  });
  