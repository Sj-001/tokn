pragma solidity ^0.8.0;
import "./ToknBidding.sol";

contract ToknFactory{
  address payable deployer;
  uint256 songID;
  // address artist;
//store songs
 mapping(uint256=> Song) public songList;
 mapping(address=> address) public artistTokn;

//model song object
struct Song{
 uint256 _songID;
 string _title;
 address _artist;
 string _albumCoverHash;
 string _audioHash;
 }

 //Song uploaded EventEmitter
 event SongUploaded(
   uint256 _songID,
   string _title,
   address _artist,
   string _albumCoverHash,
   string _audioHash
 );

constructor(address payable _deployer) {
  deployer = _deployer;
  songID = 0;
}



//upload or store song on the blockchain
function uploadSong(string memory _albumCoverHash, string memory _audioHash, string memory _title) public {
  //ensure imgHash is not empty
  require(bytes(_albumCoverHash).length > 0);
  //ensure auidoHash is not empty
  require(bytes(_audioHash).length > 0);
  //ensure function caller(an artist) has an address
  require(msg.sender != address(0));
  //increment songID
  songID++;
  //create and store song object to mapping
  songList[songID] = Song(songID, _title, msg.sender, _albumCoverHash, _audioHash);  
  //emit event after song has been uploaded successfully
  emit SongUploaded(songID++, _title, msg.sender, _albumCoverHash, _audioHash);

}

// Creating an NFT of the song uploaded

function createTokn(string memory name, string memory symbol, uint256 _songID) public{
  require(msg.sender == songList[_songID]._artist);
  // address newTokn = address(new ToknBidding(name, symbol));
  // ToknCollectible.Collectible memory newCollectible = newTokn.create(songList[_songID]._title, tokenURI, commission);
  artistTokn[msg.sender] = address(new ToknBidding(name, symbol));
}

}