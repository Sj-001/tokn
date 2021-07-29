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


constructor(string memory name, string memory symbol ) ERC721(name, symbol){
    _collectibleID = 0;
    _collectibleCount = 0;
}


function create(string memory _title, string memory _tokenURI) public returns(uint256){
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
  return newCollectible._collectibleID;

}


//destroy function takes the tokenID of the NFT, then calls on openzeppelin's burn function.
function destroy(uint256 toknID) public  returns(bool success) {
  require(_exists(toknID));
  // toknExists(toknID);
  _burn(toknID);
  delete _collectibleList[toknID];
  return true;
}

}