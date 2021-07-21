pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "./Auction.sol";


// function for maxPrice authorized to owner

contract ToknCollectible is ERC721{
  uint256 public  _collectibleID;
  uint256 public _collectibleCount;
  // uint public maxPrice;

  // the original creator of NFT (artist)
  address payable public creator;

  mapping(uint256=> Collectible) public _collectibleList;


  // mapping(uint256=> address[]) public collectibleAuctions;
  // mapping(uint256=> bool) public runningAuction;
  // mapping(uint256=> Auction) public currentAuctionForTokn;
  // mapping(address=> uint) public auctionMaxPrice;

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
    _collectibleCount = 0;
}

//creates and mints NFT Tokn to user.
//Takes as input _tokenURI: token data off chain, address of the _owner,collectible title

modifier toknExists(uint256 toknID) {
  require(_exists(toknID));
  _;
}

function create(string memory _title, string memory _tokenURI) public returns(Collectible memory){
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

  // Assiging msg.sender as the original creator 
  creator = payable(msg.sender);
  return newCollectible;

}

// // Starting auction for a particular collectible
// function startAuction(uint256 toknID, uint _maxPrice) public toknExists(toknID){
//   // require(_exists(toknID));
//   require(_isApprovedOrOwner(msg.sender, toknID));
//   require(runningAuction[toknID] == false);
//   Auction newAuction = new Auction(payable(msg.sender), toknID);
//   // collectibleAuctions[toknID].push(address(newAuction));
//   auctionMaxPrice[address(newAuction)] =_maxPrice*10**18;
//   runningAuction[toknID] = true;
//   currentAuctionForTokn[toknID] = newAuction;
// }


// // Placeing Bid
// function bid(uint256 _toknID) public payable toknExists(_toknID) returns(bool){
//   // require(_exists(_toknID));
//   require(runningAuction[_toknID]);
  
//   // Auction currentAuction = currentAuctionForTokn[_toknID];

//   bool res = currentAuctionForTokn[_toknID].placeBid{value: msg.value}(msg.sender);

//   // Finalizing the auction if the current bid reaches maximum price defines by the owner 
//   if(msg.value >= auctionMaxPrice[address(currentAuctionForTokn[_toknID])]){
//     runningAuction[_toknID] = false;

//   }
//   return res;
// }

// // Finalizing Auction and transferring the ownership to the buyer and sending the commision to the original creator
// function endAuction(uint256 _toknID, uint256 commission) public toknExists(_toknID){
//   // require(_exists(_toknID));
//   Auction currentAuction = currentAuctionForTokn[_toknID];
//   require(currentAuction.auctionState() != Auction.State.Ended); 
//   require(_isApprovedOrOwner(msg.sender, _toknID) && msg.sender == currentAuction.owner());
  
//   currentAuction.finalizeAuction();
//   _collectibleList[_toknID]._owner = currentAuction.highestBidder();
//   uint lastPrice = currentAuction.highestBid()/uint(10**18);
//   uint creatorCommission = lastPrice*commission/uint(100);
//   creator.transfer(creatorCommission*10**18); 
//   safeTransferFrom(msg.sender, currentAuction.highestBidder(), _toknID);
//   runningAuction[_toknID] = false;
//   delete currentAuctionForTokn[_toknID];
// }

// //cancelling the auction
// function cancelAuction(uint256 toknID) public toknExists(toknID){
//   // require(_exists(toknID));
//   require(msg.sender == _collectibleList[toknID]._owner);
//   require(runningAuction[toknID]);
//   // Auction currentAuction = currentAuctionForTokn[toknID];
//   currentAuctionForTokn[toknID].cancelAuction(msg.sender);
//   runningAuction[toknID] = false;
//   delete currentAuctionForTokn[toknID];
// }

// // setting terminal price for auction
// function setMaxPrice(uint256 toknID, uint price) public toknExists(toknID) returns(bool){
//   // require(_exists(toknID));
//   require(msg.sender == _collectibleList[toknID]._owner);
//   require(runningAuction[toknID]);
 
//   // Auction currentAuction = currentAuctionForTokn[toknID];
//   auctionMaxPrice[address(currentAuctionForTokn[toknID])] = price*10**18;
//   return true;
// }

//destroy function takes the tokenID of the NFT, then calls on openzeppelin's burn function.
function destroy(uint256 toknID) public toknExists(toknID) returns(bool success) {
  // require(_exists(toknID));
  _burn(toknID);
  delete _collectibleList[toknID];
  return true;
}

}