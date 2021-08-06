pragma solidity > 0.6.0;
pragma experimental ABIEncoderV2;

import "./send_crypto.sol";
import "./user_profile.sol";
import "./get_price.sol";
import "./ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";


contract Transactions is UserProfile, GetPrice, SendCrypto, Ownable {

    /* ToDo:
    * 1. Figure out how to send messages with transactions - Can't be done through metamask. Pass it as an argument to the function.
    * 2. Figure out the gas fee and subtract it from the user payout - User pays the gas fee lol
    * 3. Finalize on the transaction percentage fee
    * 4. Add SafeMath ops to the contract
    */
    
    using SafeMath for uint256;
    
    uint256 transactionFeePercentage = 5;
    uint256 ethToWithdraw = 0;
    
    // constructor() internal {
    //     transactionFeePercentage = 5;
    //     ethToWithdraw = 0;
    // }

    modifier checkSenderAddress(address _sender) {
        require(msg.sender == _sender);
        _;
    }
    // Set transaction fee percentage by the user
    function setTransactionFee(uint8 _transactionFeePercentage) public onlyOwner() {
        transactionFeePercentage = _transactionFeePercentage;
    }

    // Users can donate to their fav creators
    function donateToUser(string memory _sender_name, string memory _username, string memory _message) public payable {
        uint256 weiUsd = weiInUsd();
        require(msg.value>=weiUsd, 'Error, Donation must be >= $1');
        // uint256 weiUsd = 10000;
        uint256 id = getIdByUsername(_username);
        recieveCrypto({min_val: weiUsd});
        profiles[id].balance = profiles[id].balance.add(msg.value);
        profiles[id].paymentsToProfile[profiles[id].payments_count] = Payments({sender_name: _sender_name, sender: msg.sender, value: msg.value, message: _message});
        profiles[id].payments_count = profiles[id].payments_count.add(1);
    }
    
    // Creators can call this function to withdraw their ETH from the contract
    function payoutToCreator(address _wallet_address) public payable checkSenderAddress(_wallet_address) {
        uint256 id = getIdByAddress(_wallet_address);
        uint256 payout_value = profiles[id].balance.sub((profiles[id].balance.mul(transactionFeePercentage/100))); // Considering 5% transaction fee
        ethToWithdraw = ethToWithdraw.add(profiles[id].balance.mul(transactionFeePercentage.div(100)));
        address payable creatorAddress = payable(profiles[id].wallet_address);
        sendCrypto(creatorAddress, payout_value);
        profiles[id].balance = 0;
    }

    // Withdraw ETH from the contract
    function withdrawEther() public payable onlyOwner() {
        if (ethToWithdraw > 0) {
            address payable owner = payable(owner());
            sendCrypto(owner, ethToWithdraw);
            ethToWithdraw = 0;
        }
    }
    
    // Check the balance in the contract
    function checkBalance() public view onlyOwner() returns(uint) {
        return address(this).balance;
    }
    // Check how much ETH can be withdrawn by the owner
    function checkEthToWithdraw() public view onlyOwner() returns(uint256) {
        return ethToWithdraw;
    }

    // Show Transaction percentage fee
    function displayTransactionFee() public view returns(uint8) {
        return transactionFeePercentage;
    }

}