// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

import "hardhat/console.sol";
import { ethers } from "hardhat";
import { expect } from "chai";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../contracts/PropertyBuyingSystem.sol";

contract PropertyBuyingSystemTest {
    // using SafeMath for uint256;

    // PropertyBuyingSystem private propertyBuyingSystem;

    // uint256 private tokenPrice = 100;

    // address private owner;
    // address private buyer;

    // uint256 private tokenId;

    // string private tokenURI = "testURI";

    before(async () => {
        [owner, buyer] = await ethers.getSigners();
        propertyBuyingSystem = await ethers.getContractFactory(
            "PropertyBuyingSystem"
        ).then((f) => f.deploy());
    });

    describe("PropertyBuyingSystem", () => {
        describe("#mintToken()", () => {
            it("should mint a new token and set the correct metadata", async () => {
                const tx = await propertyBuyingSystem.mintToken(
                    tokenPrice,
                    tokenURI
                );
                await tx.wait();

                const tokenOwner = await propertyBuyingSystem.ownerOf(0);
                expect(tokenOwner).to.equal(owner.address);

                const tokenURIStored = await propertyBuyingSystem.tokenURI(0);
                expect(tokenURIStored).to.equal(tokenURI);

                const forSale = await propertyBuyingSystem.propertyForSale(0);
                expect(forSale).to.equal(true);

                tokenId = 0;
            });

            it("should not allow a token with zero price to be minted", async () => {
                await expect(
                    propertyBuyingSystem.mintToken(0, tokenURI)
                ).to.be.revertedWith("Price cannot be zero");
            });
        });

        describe("#requestToBuyToken()", () => {
            it("should allow a buyer to request to buy a token", async () => {
                const tx = await propertyBuyingSystem.connect(buyer).requestToBuyToken(
                    tokenId,
                    {
                        value: tokenPrice,
                    }
                );
                await tx.wait();

                const isPending = await propertyBuyingSystem.properties(tokenId)
                    .isPending;
                expect(isPending).to.equal(true);
            });

            it("should not allow a buyer to request to buy their own token", async () => {
                await expect(
                    propertyBuyingSystem.connect(owner).requestToBuyToken(
                        tokenId,
                        {
                            value: tokenPrice,
                        }
                    )
                ).to.be.revertedWith("You cannot buy your own property");
            });

            it("should not allow a buyer to request to buy a token that is not for sale", async () => {
                await expect(
                    propertyBuyingSystem.connect(buyer).requestToBuyToken(
                        tokenId,
                        {
                            value: tokenPrice,
                        }
                    )
                ).to.be.revertedWith("Property is not for sale");
            });

            it("should not allow a buyer to request to buy a token with incorrect payment amount", async () => {
                await expect(
                    propertyBuyingSystem.connect(buyer).requestToBuyToken(
                        tokenId,
                        {
                            value: tokenPrice - 1,
                        }
                    )
                ).to.be.revertedWith("Incorrect payment amount");
            });
        });

        describe("#BuyToken()", () => {
            it("should not allow a non-owner to accept the buy request", async () => {
                await expect(
                    propertyBuyingSystem.connect(buyer).BuyToken(tokenId)
                ).to.be
                
                }
              
              
              
    }