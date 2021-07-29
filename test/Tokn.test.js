const { assert } = require("chai");

const ToknFactory = artifacts.require("ToknFactory");
const ToknBidding = artifacts.require("ToknBidding");
const Auction = artifacts.require("Auction");

require("chai").use(require("chai-as-promised")).should();

contract(ToknFactory, (accounts) => {
  let toknFactory, song, tokn, collectible;
  before(async () => {
    toknFactory = await ToknFactory.deployed();
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
  describe("createTokn()", async () => {
    it("doesn't allow anyone else other than artist to create Tokn", async () => {
      await toknFactory.createTokn("colors", "COL", song._songID, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("allows artist to create Tokn for their song", async () => {
      await toknFactory.createTokn("colors", "COL", song._songID, {
        from: accounts[0],
      });
      tokn = await toknFactory.artistTokn(accounts[0]);
      // console.log(tokn);
      assert.ok(tokn);
      // tokn = await ToknBidding.at(tokn);
      // console.log(tokn);
    });
  });

  describe("create()", async () => {
    it("creates a collectible", async () => {
      tokn = await ToknBidding.at(tokn);
      collectible = await tokn.create("My Song", "None", {
        from: accounts[0],
      });
      // console.log(collectibleID);
      collectible = await tokn._collectibleList(1);
      // console.log(newCollectible);
      assert.equal(
        collectible._title,
        "My Song",
        "Creates an NFT for given song title"
      );
      // assert.ok(collectibleID);
    });
  });

  describe("startAuction()", async () => {
    it("doesn't allow anyone else other than owner to start the auction", async () => {
      await tokn.startAuction(collectible._collectibleID, 10, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("starts an auction", async () => {
      await tokn.startAuction(collectible._collectibleID, 5, {
        from: accounts[0],
      });
      auction = await tokn.currentAuctionForTokn(collectible._collectibleID);
      auction = await Auction.at(auction);
      // auction = auctions[0];
      assert.ok(auction, "Deploys an auction for created NFT");
      let res = await tokn.runningAuction(collectible._collectibleID);
      assert.equal(res, true, "Auction running");
    });
  });

  describe("bid()", async () => {
    it("doesn't allow owner to place the bid", async () => {
      await tokn.bid(collectible._collectibleID, {
        value: 2e18,
        from: accounts[0],
      }).should.be.rejected;
    });

    it("allows user to place bid on a particular collectible", async () => {
      await tokn.bid(collectible._collectibleID, {
        value: 2e18,
        from: accounts[1],
      });

      let currentBid = await auction.highestBid();
      let currentBidder = await auction.highestBidder();
      assert.equal(currentBid, 2e18, "bid placed");
      assert.equal(currentBidder, accounts[1], "bid placed");
    });

    it("stops the auction when bid exceeds maxPrice", async () => {
      await tokn.bid(collectible._collectibleID, {
        value: 5e18,
        from: accounts[2],
      });

      let res = await tokn.runningAuction(collectible._collectibleID);
      assert.equal(res, false, "Terminates the auction");
    });
  });

  describe("endAuction()", async () => {
    it("doesn't allow anyone else other than owner to end the auction", async () => {
      await tokn.endAuction(collectible._collectibleID, 5, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("finalizes the auction", async () => {
      await tokn.endAuction(collectible._collectibleID, 5, {
        from: accounts[0],
      });
      collectible = await tokn._collectibleList(collectible._collectibleID);
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
      await tokn.startAuction(collectible._collectibleID, 6, {
        from: accounts[2],
      });
      auction = await tokn.currentAuctionForTokn(collectible._collectibleID);
      let price = await tokn.toknMaxPrice(collectible._collectibleID);
      assert.equal(price, 6e18, "Initial max price is correct");
      await tokn.setMaxPrice(collectible._collectibleID, 10, {
        from: accounts[2],
      });
      price = await tokn.toknMaxPrice(collectible._collectibleID);
      assert.equal(price, 10e18, "New max price is correct");
    });
  });

  describe("cancelAuction()", async () => {
    it("doesn't allow anyone else other than owner to cancel the auction", async () => {
      await tokn.cancelAuction(collectible._collectibleID, {
        from: accounts[1],
      }).should.be.rejected;
    });

    it("cancels the auction", async () => {
      await tokn.cancelAuction(collectible._collectibleID, {
        from: accounts[2],
      });
      let res = await tokn.runningAuction(collectible._collectibleID);
      assert.equal(res, false, "Cancels the auction");
    });
  });

  describe("destroy()", async () => {
    it("destroys the collectible", async () => {
      await tokn.destroy(collectible._collectibleID, {
        from: accounts[2],
      });
      let res = await tokn._collectibleList(collectible._collectibleID);
      // console.log(res);
      assert.equal(
        res._owner,
        "0x0000000000000000000000000000000000000000",
        "Collectible destroyed."
      );
    });
  });
});
