//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PropertyBuyingSystem is ERC721URIStorage {
    using SafeMath for uint256;

    struct Property {
        uint256 price;
        address owner;
        bool forSale;
        address buyer;
        bool isPending;
    }

    Property[] public properties;

    mapping(uint256 => bool) public propertyExists;
    mapping(address => uint256[]) public ownerProperties;
    mapping(uint256 => uint256) public propertyIndex;
    mapping(uint256 => address) public propertyOwner;
    mapping(uint256 => bool) public propertyForSale;

    constructor() ERC721("Property", "PROP") {}

    function mintToken(uint256 _price, string memory _tokenURI)
        public
        returns (uint256)
    {
        require(_price > 0, "Price cannot be zero");

        Property memory newProperty = Property(
            _price,
            msg.sender,
            true,
            address(0),
            false
        );
        uint256 tokenId = properties.length;
        properties.push(newProperty);

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        propertyExists[tokenId] = true;
        ownerProperties[msg.sender].push(tokenId);
        propertyIndex[tokenId] = ownerProperties[msg.sender].length - 1;
        propertyOwner[tokenId] = msg.sender;
        propertyForSale[tokenId] = true;

        return tokenId;
    }

    function requestToBuyToken(uint256 _tokenId) public payable {
        require(msg.sender != address(0), "Invalid address");
        require(propertyExists[_tokenId], "Property does not exist");
        require(propertyForSale[_tokenId], "Property is not for sale");

        require(
            !properties[_tokenId].isPending,
            "There is already a pending transaction for this property"
        );

        require(
            properties[_tokenId].owner != msg.sender,
            "You cannot buy your own property"
        );

        uint256 propertyPrice = properties[_tokenId].price;
        require(msg.value == propertyPrice, "Incorrect payment amount");

        properties[_tokenId].isPending = true;
        properties[_tokenId].buyer = msg.sender;
    }

    function BuyToken(uint256 _tokenId) public {
        require(
            msg.sender == properties[_tokenId].owner,
            "Only the owner can accept the buy request"
        );
        require(
            properties[_tokenId].isPending,
            "There is no pending transaction for this property"
        );

        address payable propertyOwnerAddress = payable(
            properties[_tokenId].owner
        );
        address buyer = properties[_tokenId].buyer;
        uint256 propertyPrice = properties[_tokenId].price;

        propertyOwnerAddress.transfer(propertyPrice); // transfer the payment to the owner

        safeTransferFrom(propertyOwnerAddress, buyer, _tokenId); //  ownership of the property to the buyer
        propertyForSale[_tokenId] = false;

        // we are here updating the data related to property which get tranferred to buyer

        uint256 propertyIndexToUpdate = propertyIndex[_tokenId];
        uint256 lastPropertyIndex = ownerProperties[propertyOwnerAddress]
            .length
            .sub(1);
        uint256 lastPropertyId = ownerProperties[propertyOwnerAddress][
            lastPropertyIndex
        ];
        ownerProperties[propertyOwnerAddress][
            propertyIndexToUpdate
        ] = lastPropertyId;
        propertyIndex[lastPropertyId] = propertyIndexToUpdate;
        ownerProperties[propertyOwnerAddress].pop();
        ownerProperties[buyer].push(_tokenId);
        propertyIndex[_tokenId] = ownerProperties[buyer].length - 1;
        propertyOwner[_tokenId] = msg.sender;
    }
}