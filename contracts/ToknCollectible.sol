pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ToknCollectible is ERC721{
  uint256 public  _collectibleID;
  uint256 public _collectibleCount;

  mapping(uint256=> Collectible) private _collectibleList;

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

function create(string memory _title, string memory _tokenURI) public {
    //increment collectible count
      _collectibleID++;
      _collectibleCount++;

    //create collectible struct
  _collectibleList[_collectibleID] = Collectible(_collectibleID, _title, msg.sender, _tokenURI);

  //emit Event
  emit CollectibleCreated(_collectibleID, _title, msg.sender, _tokenURI);

  //call safemint function from openzeppelin
  _safeMint(msg.sender, _collectibleID);
  setTokenURI(_collectibleID, _tokenURI);


}

function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
    require(_isApprovedOrOwner(_msgSender(), tokenId),
    "ERC721: transfer caller is not owner nor approved");
    _setTokenURI(tokenId, _tokenURI);
 }

//destroy function takes the tokenID of the NFT, then calls on openzeppelin's burn function.
function destroy() internal returns(bool success) {
  _burn(_collectibleID);
  return true;
}

}