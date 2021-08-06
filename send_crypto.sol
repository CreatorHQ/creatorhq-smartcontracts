pragma solidity >0.6.0;

contract SendCrypto {

    // Recieve crypto from the user to the contract
    function recieveCrypto(uint256 min_val) public payable {
        if(msg.value < min_val) {
            revert();
        }
    }
    
    // Send crypto to the user - Change this security from public to private
    function sendCrypto(address payable _receiver_address, uint256 value) public {
        _receiver_address.transfer(value);
        
    }
}