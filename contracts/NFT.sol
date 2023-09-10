// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721, ERC721Enumerable, Ownable {
    constructor() ERC721("MyToken", "MTK") {}

    uint NFT_ID = 1;
    struct Detail {
        uint id;    
        address nftowner;
        string imgUrl;
        uint nftprice;
        string nft_title;
        string nftDescription;
        string nftcreator;
    }

    struct sellnft {
        uint Id;
        address NFTOwner;
        uint Price;
        // string imgUrl;
        bool is_Offer;
        uint OfferEnd; 
    }

    uint[] public NFTId;
    uint256 public offerExpirationTime;

    mapping(uint=>sellnft) public sellData;
    mapping(uint=>Detail) public data;
    mapping(address=>Detail[]) userdata;

    event AddNFT(uint NFT_ID,string imgUrl,uint nftprice,string nft_title,string nftDescription,string nftcreator);
    event sellNFT(address nftowner,uint offerPrice,uint offercreatedtime,uint offerended);
    event buynft(address nftowner,address buyaddress,uint buyprice,uint buytime);
    // uint256 public constant MINT_PRICE = 0.05 ether;


    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function Add_nft (address _add, uint _price,string memory _title , string memory _imgUrl,string memory _des,string memory _creator ) public payable {
        _mint(_add,NFT_ID);
        data[NFT_ID] = Detail(NFT_ID,_add,_imgUrl,_price,_title,_des,_creator);
        userdata[_add].push(Detail(NFT_ID,_add,_imgUrl,_price,_title,_des,_creator));
        emit AddNFT(NFT_ID,_imgUrl,_price,_title,_des,_creator);
        NFT_ID += 1;
    }

    function NFT_DATA (uint _id) public view returns(Detail memory){
        return data[_id];
    }


    function IMG_URL (uint _id) public view returns(string memory){
        return data[_id].imgUrl;
    }

    function SellNFT( uint _ID,uint _price) public returns (string memory) {
        require(_exists(_ID), "NFT does not exist");
        // address nft_O = data[_ID].nftowner;
        require(msg.sender == data[_ID].nftowner,"You are not owner of this nft");
        // require(msg.sender == , "You do not own this NFT");
        sellData[_ID] = sellnft(_ID,msg.sender,_price,true,block.timestamp);
        offerExpirationTime = block.timestamp + 10 minutes;
        _approve(address(this),_ID);
        // _isApprovedOrOwner(address(this),_ID);
        // _setApprovalForAll(msg.sender,address(this),true);
        NFTId.push(_ID);
        emit sellNFT(msg.sender,_price,block.timestamp,offerExpirationTime);
        return "sucessfully sell nft";
    }

    function RemoveSell (uint _ID) public {
        require(sellData[_ID].NFTOwner==msg.sender,"Your Are Not Owner Of This NFT");
        uint i = 0;
        while(i < NFTId.length){
            if(NFTId[i] == _ID){
                delete NFTId[i];
            }
            i++;
        }
    }

    function ArrayLengh () public view returns(uint) {
        return NFTId.length;
    }

    function BuyNFT (uint _ID) public payable returns(string memory) {
        require(offerExpirationTime>=block.timestamp,"Offer Has Ended");
        // require(msg.value==sellData[_ID].Price,"Invalid value");
        if(offerExpirationTime<=block.timestamp){
            sellData[_ID].is_Offer = false;
            delete NFTId[0];
            // string memory msg = "This Offer is ended";
            return "This Offer is ended";
        }
        else{
            sellData[_ID].is_Offer = true;
            _approve(msg.sender, _ID);
            address o = data[_ID].nftowner;
            safeTransferFrom(o,msg.sender,_ID);
            payable(o).transfer(msg.value);
            data[_ID].nftowner = msg.sender;
            data[_ID].nftprice = sellData[_ID].Price;
            sellData[_ID].NFTOwner = msg.sender;

            emit buynft(o,msg.sender,sellData[_ID].Price,block.timestamp);
            delete NFTId[0];
        }

        return "NFT purchase successful";
    }

    function Offer_ID (uint _index) public view returns(uint) {
        return NFTId[_index];
    }

    function offerExpired() public view returns (bool) {
        return (block.timestamp >= offerExpirationTime);
    }
}