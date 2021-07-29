const ToknFactory = artifacts.require("ToknFactory");
const ToknBidding = artifacts.require("ToknBidding");
// const ToknBidding = artifacts.require("Auction");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(ToknFactory, accounts[0], { from: accounts[0] });
  // await deployer.deploy(ToknBidding, "colors", "CLR", { from: accounts[0] });
};
