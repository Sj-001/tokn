pragma solidity ^0.8.0;

import "./ToknCollectible.sol";
import "./Auction.sol";

contract ToknBidding is ToknCollectible{

  // uint256 collectibleID;
  // address payable creator;
  // address payable owner;
    mapping(uint256=> bool) public runningAuction;
  mapping(uint256=> address) public currentAuctionForTokn;
  // mapping(uint256=> mapping(address=>bool)) public currentRunningAuction;
  mapping(uint=> uint) public toknMaxPrice;
  
  constructor(string memory name, string memory symbol) ToknCollectible(name, symbol){
    // collectibleID = _toknID;
    // creator = payable(_creator);
    // owner = payable(msg.sender);
  }
function toknExists(uint256 toknID) private view{
  require(_exists(toknID));
}

 // Starting auction for a particular collectible
function startAuction(uint256 toknID, uint _maxPrice) public {
  toknExists(toknID);
  // require(_exists(toknID));
  require(_isApprovedOrOwner(msg.sender, toknID) && runningAuction[toknID] == false);
  // require(runningAuction[toknID] == false);

  // address newAuction = address(new Auction(payable(msg.sender)));
  // collectibleAuctions[toknID].push(address(newAuction));
  toknMaxPrice[toknID] =_maxPrice*10**18;
  runningAuction[toknID] = true;
  currentAuctionForTokn[toknID] = address(new Auction(payable(msg.sender)));
}


// Placeing Bid
function bid(uint256 _toknID) public payable{
  toknExists(_toknID);
  // require(_exists(_toknID));
  require(runningAuction[_toknID]);
  
  // Auction currentAuction = currentAuctionForTokn[_toknID];

  Auction(currentAuctionForTokn[_toknID]).placeBid{value: msg.value}(msg.sender);

  // Finalizing the auction if the current bid reaches maximum price defines by the owner 
  if(msg.value >= toknMaxPrice[_toknID]){
    runningAuction[_toknID] = false;

  }
  
}

// Finalizing Auction and transferring the ownership to the buyer and sending the commision to the original creator
function endAuction(uint256 _toknID, uint256 commission) public {
  toknExists(_toknID);
  // require(_exists(_toknID));
  Auction currentAuction = Auction(currentAuctionForTokn[_toknID]);
  require(currentAuction.auctionState() != Auction.State.Ended && msg.sender == currentAuction.owner()); 
  // require(msg.sender == currentAuction.owner());
  
  currentAuction.finalizeAuction();
  _collectibleList[_toknID]._owner = currentAuction.highestBidder();
  // uint lastPrice = currentAuction.highestBid()/uint(10**18);
  // uint creatorCommission = ((currentAuction.highestBid()/uint(10**18))*commission/uint(100));
  creator.transfer(((currentAuction.highestBid()/uint(10**18))*commission/uint(100))*10**18); 
  safeTransferFrom(msg.sender, currentAuction.highestBidder(), _toknID);
  runningAuction[_toknID] = false;
  // delete currentAuctionForTokn[_toknID];
}

//cancelling the auction
function cancelAuction(uint256 toknID) public {
  toknExists(toknID);
  // require(_exists(toknID));
  require(msg.sender == _collectibleList[toknID]._owner && runningAuction[toknID]);
  // require(runningAuction[toknID]);
  // Auction currentAuction = currentAuctionForTokn[toknID];
  Auction(currentAuctionForTokn[toknID]).cancelAuction(msg.sender);
  runningAuction[toknID] = false;
  // delete currentAuctionForTokn[toknID];
}

// setting terminal price for auction
function setMaxPrice(uint256 toknID, uint price) public {
  toknExists(toknID);
  // require(_exists(toknID));
  require(msg.sender == _collectibleList[toknID]._owner && runningAuction[toknID]);
  // require(runningAuction[toknID]);
 
  // Auction currentAuction = currentAuctionForTokn[toknID];
  toknMaxPrice[toknID] = price*10**18;
}

}