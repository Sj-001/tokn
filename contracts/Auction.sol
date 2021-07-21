pragma solidity ^0.8.0;

// Contract for bidding on NFT
contract Auction{
    address payable public owner;
    // uint public startBlock;
    // uint public endBlock;
    // uint256 public collectibleId;

    address payable[] public bidders;
    enum State {Started, Running, Ended, Cancelled}
    State public auctionState;
    
    uint public highestBid;
    address payable public highestBidder;
    
    mapping(address => uint) public bids;
    
    
    // Assigning the msg.sender as the owner of the auction
    constructor(address payable creator){
        owner = creator;
        auctionState = State.Running;
        // startBlock = block.number;
        // collectibleId = toknId;
    }
    
       
    
    // Cancelling teh auction if creator decides not to sell NFT
    function cancelAuction(address sender) public {
        require(sender == owner);
        auctionState = State.Cancelled;
        for(uint i = 0; i < bidders.length; ++i){
          
          bidders[i].transfer(bids[bidders[i]]);
        }

    }
    
    // Placing bid on the auction
    function placeBid(address sender) public payable returns(bool){
        require(sender != owner);
        require(auctionState == State.Running);
        require(msg.value > 0.001 ether);  
        if(bids[sender] == 0){
          bidders.push(payable(sender));
        }
        uint currentBid = bids[sender] + msg.value;
        
        
        require(currentBid > highestBid);
        
        bids[sender] = currentBid;

        // Setting the highest binding bid
        
        
        highestBid = currentBid;
        highestBidder = payable(sender);
        
        
        return true;
    }
    
    // Finalizing the auction and declaring teh winner
    function finalizeAuction() public {
        require(auctionState != State.Cancelled);
      
        
        
        // Transferring the highestBinding Bid to teh owners account
        
        owner.transfer(highestBid);

        // Transferring rest of the bid amounts back to the bidders
        for(uint i = 0; i < bidders.length; ++i){
          if(bidders[i] != highestBidder){
          
            bidders[i].transfer(bids[bidders[i]]);
          }
          
        }
        
        // Ending the auction
        auctionState = State.Ended;
        // endBlock = block.number;
        
    }
}