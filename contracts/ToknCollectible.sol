pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Auction.sol";


// function for maxPrice authorized to owner

contract ToknCollectible is ERC721{
  uint256 public  _collectibleID;
  uint256 public _collectibleCount;
  uint public maxPrice;

  // the original creator of NFT (artist)
  address payable public creator;

  mapping(uint256=> Collectible) public _collectibleList;

  // Storing commisions as demanded by NFT creators for a token
  mapping(address=> mapping (uint256=> uint256)) public commissions;
  mapping(uint256=> address[]) public collectibleAuctions;
  mapping(uint256=> bool) public runningAuction;
  mapping(uint256=> Auction) public currentAuctionForTokn;
  mapping(address=> uint) public auctionMaxPrice;
  // Auctions deployed for a token(No. of time the NFT gets selled)
  // address[] public deployedAuctions;

  struct Collectible{
    uint256 _collectibleID;
    string _title;
    address _owner;
    string _collectibleURI;
    
  }
  event CollectibleCreated(
    uint256 _collectibleID,
    string _title,
    address _owner,
    string _collectibleURI
    
  );


constructor(string memory name, string memory symbol ) public ERC721(name, symbol){
    _collectibleID = 0;
}

//creates and mints NFT Tokn to user.
//Takes as input _tokenURI: token data off chain, address of the _owner,collectible title

function create(string memory _title, string memory _tokenURI, uint256 commission) public returns(Collectible memory){
    //increment collectible count
      _collectibleID++;
      _collectibleCount++;

    //create collectible struct
    Collectible memory newCollectible = Collectible(_collectibleID, _title, msg.sender, _tokenURI);
  _collectibleList[_collectibleID] = newCollectible;

  //emit Event
  emit CollectibleCreated(_collectibleID, _title, msg.sender, _tokenURI);

  //call safemint function from openzeppelin
  _safeMint(msg.sender, _collectibleID);
  // storing commission
  commissions[msg.sender][_collectibleID] = commission;

  // Assiging msg.sender as the original creator 
  creator = payable(msg.sender);

// According to Release date
// Starting Bidding process
  // startAuction(msg.sender, _collectibleID);

  return newCollectible;

}

// Starting auction for a particular collectible
function startAuction(uint256 toknID, uint _maxPrice) public{
  require(_exists(toknID));
  require(_isApprovedOrOwner(msg.sender, toknID), "You should be the token owner");
  require(runningAuction[toknID] == false);
  Auction newAuction = new Auction(payable(msg.sender), toknID);
  // deployedAuctions.push(address(newAuction));
  collectibleAuctions[toknID].push(address(newAuction));
  auctionMaxPrice[address(newAuction)] =_maxPrice*10**18;
  runningAuction[toknID] = true;
  currentAuctionForTokn[toknID] = newAuction;
}


// Placeing Bid
function bid(uint256 _toknID) public payable returns(bool){
  require(_exists(_toknID));
  require(runningAuction[_toknID]);
  // Auction currentAuction = Auction(deployedAuctions[deployedAuctions.length - 1]);
  
  Auction currentAuction = currentAuctionForTokn[_toknID];
  // address[] memory auctions = collectibleAuctions[_toknID];
  // Auction currentAuction = Auction(auctions[auctions.length-1]);
  bool res = currentAuction.placeBid{value: msg.value}(msg.sender);

  // Finalizing the auction if the current bid reaches maximum price defines by the owner 
  if(msg.value >= auctionMaxPrice[address(currentAuction)]){
    runningAuction[_toknID] = false;
    // currentAuction.finalizeAuction();
    // _collectibleList[_toknID]._owner = currentAuction.highestBidder();
    // uint lastPrice = currentAuction.highestBid();
    // uint creatorCommission = lastPrice*commissions[msg.sender][_toknID]/uint(100);
    // creator.transfer(creatorCommission); 
    // safeTransferFrom(_collectibleList[_toknID]._owner, currentAuction.highestBidder(), _toknID);
  }
  return res;
}

function getHighestBid(uint256 toknID) public view returns(uint){
  require(_exists(toknID));
  // address[] memory auctions = collectibleAuctions[toknID];
  // Auction currentAuction = Auction(auctions[auctions.length-1]);
  Auction currentAuction = currentAuctionForTokn[toknID];
  return currentAuction.highestBid();
}

function getHighestBidder(uint256 toknID) public view returns(address payable){
  require(_exists(toknID));
  // address[] memory auctions = collectibleAuctions[toknID];
  // Auction currentAuction = Auction(auctions[auctions.length-1]);
  Auction currentAuction = currentAuctionForTokn[toknID];
  return currentAuction.highestBidder();
}
// Finalizing Auction and transferring the ownership to the buyer and sending the commision to the original creator
function endAuction(uint256 _toknID) public{
  require(_exists(_toknID));
  // require(runningAuction[_toknID]);
  // Auction currentAuction = Auction(deployedAuctions[deployedAuctions.length - 1]);
  // address[] memory auctions = collectibleAuctions[_toknID];
  // Auction currentAuction = Auction(auctions[auctions.length-1]);
  Auction currentAuction = currentAuctionForTokn[_toknID];
  require(currentAuction.auctionState() != Auction.State.Ended); 
  require(_isApprovedOrOwner(msg.sender, _toknID) && msg.sender == currentAuction.owner());
  
  currentAuction.finalizeAuction();
  _collectibleList[_toknID]._owner = currentAuction.highestBidder();
  uint lastPrice = currentAuction.highestBid()/uint(10**18);
  uint creatorCommission = lastPrice*commissions[msg.sender][_toknID]/uint(100);
  creator.transfer(creatorCommission*10**18); 
  safeTransferFrom(msg.sender, currentAuction.highestBidder(), _toknID);
  runningAuction[_toknID] = false;
  delete currentAuctionForTokn[_toknID];
}

//cancelling the auction
function cancelAuction(uint256 toknID) public {
  require(_exists(toknID));
  require(msg.sender == _collectibleList[toknID]._owner);
  require(runningAuction[toknID]);
  // address[] memory auctions = collectibleAuctions[toknID];
  // Auction currentAuction = Auction(auctions[auctions.length-1]);
  Auction currentAuction = currentAuctionForTokn[toknID];
  currentAuction.cancelAuction(msg.sender);
  runningAuction[toknID] = false;
  delete currentAuctionForTokn[toknID];
}

// setting terminal price for auction
function setMaxPrice(uint256 toknID, uint price) public returns(bool){
  // require(_isApprovedOrOwner(msg.sender, toknID)); 
  require(_exists(toknID));
  require(msg.sender == _collectibleList[toknID]._owner);
  require(runningAuction[toknID]);
  // address[] memory auctions = collectibleAuctions[toknID];
  // address currentAuction = auctions[auctions.length-1];
  Auction currentAuction = currentAuctionForTokn[toknID];
  auctionMaxPrice[address(currentAuction)] = price*10**18;
  return true;
}

//destroy function takes the tokenID of the NFT, then calls on openzeppelin's burn function.
function destroy(uint256 toknID) public returns(bool success) {
  require(_exists(toknID));
  _burn(toknID);
  delete _collectibleList[toknID];
  return true;
}

}