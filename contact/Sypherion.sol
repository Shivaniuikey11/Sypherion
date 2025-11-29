// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Sypherion (SYPH)
 * @author Grok
 * @notice A privacy-inspired ERC20 token with encrypted transfer messaging and stealth burn mechanics.
 */
contract Sypherion is ERC20, ERC20Burnable, Ownable {
    // Mapping to store encrypted messages attached to transfers (for privacy illusion)
    mapping(address => string) public encryptedMessages;

    // Event emitted when a stealth (private) transfer occurs
    event StealthTransfer(address indexed from, address indexed to, uint256 amount, bytes32 messageHash);

    // Event for revealing encrypted message (optional future decryption)
    event MessageRevealed(address indexed user, string message);

    constructor() ERC20("Sypherion", "SYPH") Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10**decimals()); // 1 million initial supply
    }

    /**
     * @dev Core Function 1: Stealth Transfer
     * Transfers tokens with an encrypted message (hash stored on-chain)
     */
    function stealthTransfer(
        address to,
        uint256 amount,
        string calldata encryptedMessage
    ) external returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(encryptedMessage, block.timestamp, msg.sender));
        
        emit StealthTransfer(msg.sender, to, amount, messageHash);
        
        _transfer(msg.sender, to, amount);
        encryptedMessages[to] = encryptedMessage; // Optional: store for receiver
        
        return true;
    }

    /**
     * @dev Core Function 2: Quantum Burn
     * Burns tokens with a "quantum entropy" multiplier (fun thematic burn)
     */
    function quantumBurn(uint256 amount, uint256 entropySeed) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        uint256 bonusBurn = (amount * (entropySeed % 10)) / 100; // Up to 10% bonus burn based on seed
        uint256 totalBurn = amount + bonusBurn;
        
        _burn(msg.sender, totalBurn);
    }

    /**
     * @dev Core Function 3: Reveal Encrypted Message (Owner or Recipient)
     * Allows the recipient to publicly reveal their encrypted message
     */
    function revealMessage(string calldata clearMessage) external {
        require(bytes(encryptedMessages[msg.sender]).length > 0, "No message stored");
        
        delete encryptedMessages[msg.sender];
        emit MessageRevealed(msg.sender, clearMessage);
    }

    /**
     * @dev Optional: Owner can mint new tokens (governance in future)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
