const ToknFactory = artifacts.require("ToknFactory");
// const ToknBidding = artifacts.require("Auction");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(ToknFactory, accounts[1]);
};
