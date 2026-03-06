const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {

//address of both token
const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
const imopersonatorAddress = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621"
const routerAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
const pairAddress = "0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5"


await helpers.impersonateAccount(imopersonatorAddress);
await helpers.setBalance(imopersonatorAddress, ethers.parseEther("5"));

const signer = await ethers.getSigner(imopersonatorAddress);

//contract instances 
const usdcContract = await ethers.getContractAt("IERC20", USDCAddress, signer);
const daiContract = await ethers.getContractAt("IERC20", DAIAddress, signer);
const routerContract = await ethers.getContractAt("IUniswapV2Router01", routerAddress, signer);
const pairContract = await ethers.getContractAt("IUniswapV2Pair", pairAddress, signer);

//before liquidity
const beforeUsdcImpersonationBalance = await usdcContract.balanceOf(imopersonatorAddress);
const beforeDaiImpersonationBalance = await daiContract.balanceOf(imopersonatorAddress);
const beforeUsdcPoolBalance = await usdcContract.balanceOf(pairAddress);
const beforeDaiPoolBalance = await daiContract.balanceOf(pairAddress);
const beforePairBalance = await pairContract.balanceOf(imopersonatorAddress);


console.log(
    "=================Before========================================",
  );

console.log("USDC Balance before adding liquidity", ethers.formatUnits(beforeUsdcImpersonationBalance, 6))
console.log("DAI Balance before adding liquidity", ethers.formatUnits(beforeDaiImpersonationBalance, 18))
console.log("USDC Pool Balance before adding liquidity", ethers.formatUnits(beforeUsdcPoolBalance, 6))
console.log("DAI Pool Balance before adding liquidity", ethers.formatUnits(beforeDaiPoolBalance, 18))
console.log("Before Pool Balance of LP Tokens", ethers.formatUnits(beforePairBalance, 18))

console.log("Adding Liquidity")

const amountUsdcDesire = await ethers.parseUnits("100000", 6);

//using quote to get the dai(amountBdesire) function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
const amountDaiDesire = await routerContract.quote(amountUsdcDesire, beforeUsdcPoolBalance, beforeDaiPoolBalance);
console.log("Amount of Dai Desire: ", amountDaiDesire);
  // const amountDAI = ethers.parseUnits("10000", 18);  or gamble 
const amountUsdcMin =  await ethers.parseUnits("99000", 6);
const amountDaiMin = amountDaiDesire * 90n/100n;
const deadline =  await helpers.time.latest() + 600;

//approve usdc
const approveUSDCTx = await usdcContract.connect(signer).approve(routerAddress, amountUsdcDesire);
await approveUSDCTx.wait();
//approve dai
const approveDaiTx = await daiContract.connect(signer).approve(routerAddress, amountDaiDesire);
await approveDaiTx.wait();

try{
  const addLiquidity = await routerContract.connect(signer).addLiquidity(
    USDCAddress, 
    DAIAddress,
    amountUsdcDesire,
    amountDaiDesire,
    amountUsdcMin,
    amountDaiMin,
    imopersonatorAddress,
    deadline
  )

  await addLiquidity.wait();

  console.log("=================Adding Liquidity Successful=================")
} catch(error){
  console.log("=================Adding Liquidity Failed=================", error)
}



//after liquidity
const afterUsdcImpersonationBalance = await usdcContract.balanceOf(imopersonatorAddress);
const afterDaiImpersonationBalance = await daiContract.balanceOf(imopersonatorAddress);
const afterUsdcPoolBalance = await usdcContract.balanceOf(pairAddress);
const afterDaiPoolBalance = await daiContract.balanceOf(pairAddress);
const afterPairBalance = await pairContract.balanceOf(imopersonatorAddress);


console.log(
    "=================After========================================",
  );

console.log("USDC Balance after adding liquidity", ethers.formatUnits(afterUsdcImpersonationBalance, 6))
console.log("DAI Balance after adding liquidity", ethers.formatUnits(afterDaiImpersonationBalance, 18))
console.log("USDC Pool Balance after adding liquidity", ethers.formatUnits(afterUsdcPoolBalance, 6))
console.log("DAI Pool Balance after adding liquidity", ethers.formatUnits(afterDaiPoolBalance, 18))
console.log("after Pool Balance of LP Tokens", ethers.formatUnits(afterPairBalance, 18))

console.log("Adding Liquidity............")

console.log("=================Adding Liquidity Ended=================")

};
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});