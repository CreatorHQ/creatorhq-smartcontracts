pragma solidity >0.6.0;
pragma experimental ABIEncoderV2;

contract UserProfile {

    struct Payments {
        string sender_name;
        address sender;
        uint256 value;
        string message;
    }

    struct Profile {
        string username;
        string name;
        address wallet_address;
        string bio;
        // Links to other profiles
        // mapping(uint256 => string) profileLinks;
        string profile_pic_link;
        // string link2;
        
        // all payments made to a profile
        mapping(uint256 => Payments) paymentsToProfile;
        uint256 payments_count;
        uint256 balance;
    }

    Profile[] internal profiles; // Change to private

    mapping(uint256 => address) private addressById;
    mapping(address => Profile) private profileByAddress;
    mapping(string => bool) private doesExist;
    mapping(address => bool) private doesExistAddress;

    // Modifiers to check if profile exists
    modifier checkAvailability(string memory _username, address _wallet_address) {
        require(doesExist[_username] == false, "Username already exists");
        require(doesExistAddress[_wallet_address] == false, "Address already exists");
        _;
    }
    modifier isUser(address _wallet_address) {
        require(msg.sender == _wallet_address, "Not a valid user");
        _;
    }

    // Create Profile
    function createProfile(string memory _username, string memory _name, 
                            string memory _bio, string memory _profile_pic_link) public checkAvailability(_username, msg.sender) {
        address _wallet_address = msg.sender;
        profiles.push(Profile({username: _username, name: _name, wallet_address: _wallet_address, bio: _bio, profile_pic_link: _profile_pic_link, payments_count: 0, balance: 0}));
        uint256 id = profiles.length - 1;
        doesExist[_username] = true;
        doesExistAddress[_wallet_address] = true;
        addressById[id] = _wallet_address;
    }

    // Get Profile Details
    function viewProfileAddress(uint256 _id) internal view returns(address) {
        return(profiles[_id].wallet_address);
    }
    function getIdByUsername(string memory _username) internal view returns(uint256) {
        for (uint256 i = 0; i < profiles.length; i++) {
            if (keccak256(abi.encode(profiles[i].username)) == keccak256(abi.encode(_username))) {
                return(i);
            }
        }
    }

    function getIdByAddress(address _address) internal view returns(uint256) {
        for (uint256 i = 0; i < profiles.length; i++) {
            if (profiles[i].wallet_address == _address) {
                return(i);
            }
        }
    }

    function getAddressByID(uint256 _id) internal view returns(address) {
        return(profiles[_id].wallet_address);
    }

    function getUsernameByID(uint256 _id) internal view returns(string memory) {
        return(profiles[_id].username);
    }

    function getProfileByUsername(string memory _username) public view returns(string memory, 
                                                                                string memory,
                                                                                string memory, 
                                                                                string memory) {
        uint256 id = getIdByUsername(_username);
        return(profiles[id].username, profiles[id].name, profiles[id].profile_pic_link, profiles[id].bio);
    }

    function viewMyProfile(address _wallet_address) public view isUser(_wallet_address) returns(string memory,
                                                                        string memory,
                                                                        address,
                                                                        string memory,
                                                                        string memory,
                                                                        uint256,
                                                                        uint256) {
        uint256 id = getIdByAddress(_wallet_address);
        return(profiles[id].username, profiles[id].name, profiles[id].wallet_address, profiles[id].profile_pic_link, profiles[id].bio, profiles[id].payments_count, profiles[id].balance);
    }

    function checkMyPayments(address _wallet_address) public view isUser(_wallet_address) returns(Payments[] memory) {
        uint256 id = getIdByAddress(_wallet_address);
        Payments[] memory profile_payments = new Payments[](profiles[id].payments_count);
        for (uint256 i = 0; i < profiles[id].payments_count; i++) {
            profile_payments[i] = profiles[id].paymentsToProfile[i];
        }
        return(profile_payments);
    }
    
    // function testUserProfile(address _wallet_address) public {
    //     uint256 id = getIdByAddress(_wallet_address);
    //     address sender = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    //     uint256 val = 1000;
    //     string memory message = "hello world";
    //     profiles[id].paymentsToProfile[profiles[id].payments_count] = Payments(sender, val, message);
    //     profiles[id].payments_count++;
    // }
}

