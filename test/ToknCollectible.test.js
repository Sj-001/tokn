const { assert } = require("chai");

const ToknFactory = artifacts.require("ToknFactory");
const ToknCollectible = artifacts.require("ToknCollectible");
// const Auction = artifacts.require("Auction");

require("chai").use(require("chai-as-promised")).should();

contract(ToknFactory, (accounts) => {
  let toknFactory, song, toknCollectible;
  before(async () => {
    toknFactory = await ToknFactory.new(accounts[0]);
  });
  describe("uploadSong()", async () => {
    it("allows user to uplaod a song", async () => {
      await toknFactory.uploadSong("albumHash", "audioHash", "My Song", {
        from: accounts[0],
      });
      song = await toknFactory.songList(1);
      // console.log(song);
      assert.equal(song._title, "My Song", "Song uploaded");
      assert.equal(song._artist, accounts[0], "Success");
      // assert.ok(toknFactory.address);
    });
  });
  describe("createNFT()", async () => {
    it("doesn't allow anyone else other than artist to create NFT", async () => {
      await toknFactory.createNFT("colors", "COL", song._songID, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("allows artist to create NFT for their song", async () => {
      await toknFactory.createNFT("colors", "COL", song._songID, {
        from: accounts[0],
      });
      toknCollectible = await toknFactory.songNFT(song._songID);
      // console.log(toknCollectible);
      assert.ok(toknCollectible);
    });
  });
  // });

  // contract(ToknCollectible, (accounts) => {
  //   let toknCollectible, auction, collectible;
  // before(async () => {
  // console.log(toknCollectible);
  // toknCollectible = ToknCollectible.at(toknCollectible);
  // });

  describe("create()", async () => {
    it("creates a collectible", async () => {
      toknCollectible = await ToknCollectible.at(toknCollectible);
      collectible = await toknCollectible.create("My Song", "None", 5, {
        from: accounts[0],
      });
      collectible = await toknCollectible._collectibleList(1);
      // console.log(newCollectible);
      assert.equal(
        collectible._title,
        "My Song",
        "Creates an NFT for given song title"
      );
    });
  });

  describe("startAuction()", async () => {
    it("doesn't allow anyone else other than owner to start the auction", async () => {
      await toknCollectible.startAuction(collectible._collectibleID, 10, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("starts an auction", async () => {
      await toknCollectible.startAuction(collectible._collectibleID, 5, {
        from: accounts[0],
      });
      auction = await toknCollectible.currentAuctionForTokn(
        collectible._collectibleID
      );
      // auction = auctions[0];
      assert.ok(auction, "Deploys an auction for created NFT");
      let res = await toknCollectible.runningAuction(
        collectible._collectibleID
      );
      assert.equal(res, true, "Auction running");
    });
  });

  describe("bid()", async () => {
    it("doesn't allow owner to place the bid", async () => {
      await toknCollectible.bid(collectible._collectibleID, {
        value: 2e18,
        from: accounts[0],
      }).should.be.rejected;
    });

    it("allows user to place bid on a particular collectible", async () => {
      await toknCollectible.bid(collectible._collectibleID, {
        value: 2e18,
        from: accounts[1],
      });

      let currentBid = await toknCollectible.getHighestBid(
        collectible._collectibleID
      );
      let currentBidder = await toknCollectible.getHighestBidder(
        collectible._collectibleID
      );
      assert.equal(currentBid, 2e18, "bid placed");
      assert.equal(currentBidder, accounts[1], "bid placed");
    });

    it("stops the auction when bid exceeds maxPrice", async () => {
      await toknCollectible.bid(collectible._collectibleID, {
        value: 5e18,
        from: accounts[2],
      });

      let res = await toknCollectible.runningAuction(
        collectible._collectibleID
      );
      assert.equal(res, false, "Terminates the auction");
    });
  });

  describe("endAuction()", async () => {
    it("doesn't allow anyone else other than owner to end the auction", async () => {
      await toknCollectible.endAuction(collectible._collectibleID, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("finalizes the auction", async () => {
      await toknCollectible.endAuction(collectible._collectibleID, {
        from: accounts[0],
      });
      collectible = await toknCollectible._collectibleList(
        collectible._collectibleID
      );
      let owner = collectible._owner;
      assert.equal(
        owner,
        accounts[2],
        "Transfers collectible to auction winner."
      );
    });
  });

  describe("setMaxPrice()", async () => {
    it("allows owner to manipulate maximum price", async () => {
      await toknCollectible.startAuction(collectible._collectibleID, 6, {
        from: accounts[2],
      });
      auction = await toknCollectible.currentAuctionForTokn(
        collectible._collectibleID
      );
      let price = await toknCollectible.auctionMaxPrice(auction);
      assert.equal(price, 6e18, "Initial max price is correct");
      await toknCollectible.setMaxPrice(collectible._collectibleID, 10, {
        from: accounts[2],
      });
      price = await toknCollectible.auctionMaxPrice(auction);
      assert.equal(price, 10e18, "New max price is correct");
    });
  });

  describe("cancelAuction()", async () => {
    it("doesn't allow anyone else other than owner to cancel the auction", async () => {
      await toknCollectible.cancelAuction(collectible._collectibleID, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("cancels the auction", async () => {
      await toknCollectible.cancelAuction(collectible._collectibleID, {
        from: accounts[2],
      });
      let res = await toknCollectible.runningAuction(
        collectible._collectibleID
      );
      assert.equal(res, false, "Cancels the auction");
    });
  });

  describe("destroy()", async () => {
    it("destroys the collectible", async () => {
      await toknCollectible.destroy(collectible._collectibleID, {
        from: accounts[2],
      });
      let res = await toknCollectible._collectibleList(
        collectible._collectibleID
      );
      // console.log(res);
      assert.equal(
        res._owner,
        "0x0000000000000000000000000000000000000000",
        "Collectible destroyed."
      );
    });
  });
});
