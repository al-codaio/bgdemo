pragma solidity ^0.4.17;

contract Bgnetwork {

	address bgAdmin;
	
	mapping (bytes32 => notarizedImage) notarizedImages;
	bytes32[] imagesByNotaryHash;

	mapping (address => User) Users;
	address[] usersByAddress;

	struct notarizedImage {
    	string imageURL;
    	uint timeStamp;
  	}

  	struct User {
    	string handle;
    	bytes32 city;
    	bytes32 state;
    	bytes32 country;
    	bytes32[] myImages;
  	}

  	function registerNewUser(string handle, bytes32 city, bytes32 state, bytes32 country) returns (bool success) {
	    address thisNewAddress = msg.sender;
	    // don't overwrite existing entries, and make sure handle isn't null
	    if(bytes(Users[msg.sender].handle).length == 0 && bytes(handle).length != 0){
	        Users[thisNewAddress].handle = handle;
	        Users[thisNewAddress].city = city;
	        Users[thisNewAddress].state = state;
	        Users[thisNewAddress].country = country;
	        usersByAddress.push(thisNewAddress);  // adds an entry for this user to the user 'whitepages'
	        return true;
	    } else {
	        return false; // either handle was null, or a user with this handle already existed
	    }
	  }

	function addImageToUser(string imageURL, bytes32 SHA256notaryHash) returns (bool success) {
	    address thisNewAddress = msg.sender;
	    if(bytes(Users[thisNewAddress].handle).length != 0) { // make sure this user has created an account first
	    	if(bytes(imageURL).length != 0){  // prevent users from fighting over sha->image listings in the whitepages, but still allow them to add a personal ref to any sha             
	            if(bytes(notarizedImages[SHA256notaryHash].imageURL).length == 0) {
	            	imagesByNotaryHash.push(SHA256notaryHash); // adds entry for this image to our image whitepages
	            }
	            notarizedImages[SHA256notaryHash].imageURL = imageURL;
	            notarizedImages[SHA256notaryHash].timeStamp = block.timestamp; // note that updating an image also updates the timestamp
	            Users[thisNewAddress].myImages.push(SHA256notaryHash); // add the image hash to this users .myImages array
	            return true;
	        } else {
	        	return false; // either imageURL or SHA256notaryHash was null, couldn't store image
	        }
	        return true;
	    } else {
	       	return false; // user didn't have an account yet, couldn't store image
	    }
  	}

  	//getters
  	function getUsers() view returns (address[]) { return usersByAddress; }

	function getUser(address userAddress) view returns (string, bytes32, bytes32, bytes32, bytes32[]) {
		return (Users[userAddress].handle, Users[userAddress].city, Users[userAddress].state, Users[userAddress].country, Users[userAddress].myImages);
	}

	function getAllImages() view returns (bytes32[]) { return imagesByNotaryHash; }

	function getUserImages(address userAddress) view returns (bytes32[]) { return Users[userAddress].myImages; }

	function getImage(bytes32 SHA256notaryHash) view returns (string,uint) {
		return (notarizedImages[SHA256notaryHash].imageURL, notarizedImages[SHA256notaryHash].timeStamp);
	}

}