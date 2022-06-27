//SPDX-License-Identifier:MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract fundMe{
    uint256 public constant minimumUsd=50*1e18;
    address[] public funders;
    mapping(address=>uint256) public addressToAmountFunded;
    address public immutable owner;
    constructor(){
        owner=msg.sender;
    }
    function fund() public payable{
         require(getConversionRate(msg.value)>1e18,"Didn't send enough");
         funders.push(msg.sender);
         addressToAmountFunded[msg.sender]=msg.value;
    }
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed=AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 price,,,)=priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }
    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed=AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice=getPrice();
        uint256 ethAmountInUsd=(ethPrice*ethAmount)/1e18;
        return ethAmountInUsd;
    }
    function withdraw() public onlyOwner {
        for(uint256 fundIndex=0;fundIndex<funders.length;fundIndex++){
            address funder=funders[fundIndex];
            addressToAmountFunded[funder]=0;
        }
        funders= new address[](0);
        (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"Call failed");
    }
    modifier onlyOwner{
        require(msg.sender==owner,"Sender is not owner");
        _;
    }
    receive() external payable{
        fund();
    }
    fallback() external payable{
        fund();
    }
}