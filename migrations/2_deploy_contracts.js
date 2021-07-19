const ToknCollectible = artifacts.require("ToknCollectible");
// const ToknBidding = artifacts.require("Auction");

module.exports = function (deployer) {
  deployer.deploy(ToknCollectible, "colors", "COL");
};
