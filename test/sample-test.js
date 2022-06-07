const { expect } = require("chai");
const {
  ethers: { getContractFactory, BigNumber, getNamedSigners },
} = require("hardhat");
describe("Staking", function () {
  let accounts;
  let deployer, owner, caller, holder;

  it("stake", async function () {
    const EXIO = await getContractFactory("EXIO");
    const token = await EXIO.deploy(BigNumber.from("1000000000000000000000"));
    const Staking = await ethers.getContractFactory("Staking");
    const staking = await Staking.deploy();
    await staking.deployed();
    console.log(22222222);
    accounts = await ethers.getSigners();
    [deployer, owner, caller, holder] = accounts;
    console.log(
      deployer.address,
      owner.address,
      caller.address,
      holder.address
    );
    expect(await token.totalSupply()).to.equal(
      BigNumber.from("1000000000000000000000")
    );

    await token.mint(caller.address, BigNumber.from("1000000000000000000000"));
    expect(await token.balanceOf(caller.address)).to.equal(
      BigNumber.from("1000000000000000000000")
    );

    console.log(2222, await token.balanceOf(caller.address));
    const tokenAddress = await token.deployTransaction.creates;
    const stakingAddress = await staking.deployTransaction.creates;

    await token
      .connect(caller)
      .approve(tokenAddress, BigNumber.from("1100000000000000000000000000000"));
    expect(await token.allowance(caller.address, tokenAddress)).to.equal(
      BigNumber.from("1100000000000000000000000000000")
    );
    console.log(
      "token.allowance(caller.address, tokenAddress)",
      await token.allowance(caller.address, tokenAddress)
    );
    let x;
    for (let i = 0; i < 10; i++) {
      await staking
        .connect(caller)
        .stake(BigNumber.from("100000000000000000000"));
      x = await staking.getUserStake(caller.address);
      console.log(x);
    }

    await token._transferFrom(
      caller.address,
      stakingAddress,
      BigNumber.from("1000000000000000000000")
    );
    const stake = await staking.getUserStake(caller.address);
    expect(await token.balanceOf(caller.address)).to.equal(
      BigNumber.from("1000000000000000000000").sub(
        BigNumber.from("1000000000000000000000")
      )
    );
    
    console.log(stake);
    console.log(await token.balanceOf(caller.address));
    expect(stake.amount).to.equal(BigNumber.from("1000000000000000000000"));

    const reward = await staking.pendingRewards(caller.address);

    console.log(333, reward);
    // expect(reward).to.equal(BigNumber.from("25000000000000000000"));

  });
});
