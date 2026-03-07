import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");
 

const main = async () =>{
    // address of token
    const thresholdAddress = "0xCdF7028ceAB81fA0C6971208e83fa7872994beE5";
    const kuCoinAddress = "0xf34960d9d60be18cC1D5Afc1A6F012A723a28811";
    const impersonatorAddress = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";
    const uniswapRouterAddy = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"

    await helpers.impersonateAccount(impersonatorAddress);
    await helpers.setBalance(impersonatorAddress, ethers.parseEther("10"));

    const signer = await ethers.getSigner(impersonatorAddress);
    
    //get contact instances
    const thresholdContract = await ethers.getContractAt("IERC20", thresholdAddress, signer);
    const kuCoinContract = await ethers.getContractAt("IERC20", kuCoinAddress, signer);
    const routerContract = await ethers.getContractAt("IUniswapV2Router01", uniswapRouterAddy, signer);

    console.log("===================LETS GO=====================")

    //get balance  before

    const beforeThresholdBalance = await thresholdContract.balanceOf(impersonatorAddress);
    const beforekuCoinBalance = await kuCoinContract.balanceOf(impersonatorAddress);

    console.log(
    "=================Before========================================",
  );

console.log("before balance for impersonated threshold", ethers.formatUnits(beforeThresholdBalance, 18))
console.log("before balance for impersonated kucoin", ethers.formatUnits(beforekuCoinBalance, 6))
// If you want to remove liquidity, you must first:

// Add liquidity
// Receive LP tokens
// Approve LP tokens
// Then remove liquidity

console.log("===================Adding Liquidity=========================")

const amountThresholdDesire = ethers.parseUnits("100000", 18);
const amountKucoinDesire = ethers.parseUnits("1", 6);
const amountThresholdMin =  await ethers.parseUnits("99000", 18);
const amountKucoinMin = amountKucoinDesire * 90n/100n;
const deadline =  await helpers.time.latest() + 600;

//aprove tokens
const approveThresholdTx = await thresholdContract.connect(signer).approve(uniswapRouterAddy, amountThresholdDesire);
await approveThresholdTx.wait();

const approvekuCoinTx = await kuCoinContract.connect(signer).approve(uniswapRouterAddy, amountKucoinDesire);
await approvekuCoinTx.wait();

try{
  const addLiquidityTx = await routerContract.connect(signer).addLiquidity(
    thresholdAddress, 
    kuCoinAddress,
    amountThresholdDesire,
    amountKucoinDesire,
    amountThresholdMin,
    amountKucoinMin,
    impersonatorAddress,
    deadline
  )

  await addLiquidityTx.wait();

  console.log("=================Adding Liquidity Successful=================")
} catch(error){
  console.log("=================Adding Liquidity Failed=================", error)
}


console.log("\n\n===========Getting Pairs========================")
const getContractFactoryAddress = await routerContract.factory()

//contract instance of factory
const factoryContract = await ethers.getContractAt("IUniswapV2Factory", getContractFactoryAddress, signer)
//creeate pair  if pair doesnt exist
// const creatPoolAddress = await factoryContract.createPair(thresholdAddress, kuCoinAddress)
//now get pair
const poolAddress = await factoryContract.getPair(thresholdAddress, kuCoinAddress)


// 🔥 Check pool existence first
if (poolAddress === ethers.ZeroAddress) {
    console.log("Pool does not exist");
    return;
}
//contract instance of pool
const poolContract = await ethers.getContractAt("IERC20", poolAddress, signer);
//get decimal to be sure
const decimalPool = await poolContract.decimals();
//balance of
const beforePoolBalance = await poolContract.balanceOf(impersonatorAddress)
console.log("threshold/pool", ethers.formatUnits(beforePoolBalance, decimalPool));
const liquidity = beforePoolBalance;


//remove liquidity
await poolContract.connect(signer).approve(uniswapRouterAddy, liquidity)
console.log("======================REMOVIN LIQUIDITY=========================");
try{
    const removeLiquidityTx = await routerContract.connect(signer).removeLiquidity(
        thresholdAddress,
        kuCoinAddress,
        liquidity,
        amountThresholdMin,
        amountKucoinMin,
        impersonatorAddress,
        deadline

    )
    await removeLiquidityTx.wait()

        console.log("=================LIQUIDITY REMOVED=====================");
    }catch(error){
        console.log("=================LIQUIDITY FAILED TO REMOVE======================", error);
        
    }

    //after
    const afterThresholdBalance = await thresholdContract.balanceOf(impersonatorAddress);
    const afterKucoinBalance = await kuCoinContract.balanceOf(impersonatorAddress);
    const afterPoolBalance = await poolContract.balanceOf(impersonatorAddress);

    console.log("===========================AFTER======================================");
    

    console.log("after balance for impersonated threshold", ethers.formatUnits(afterThresholdBalance, 18))
    console.log("after balance for impersonated kucoin", ethers.formatUnits(afterKucoinBalance, 6))
    console.log("threshold/pool", ethers.formatUnits(afterPoolBalance, decimalPool));
}

main().catch((error)=>{
    console.error(error);
    process.exitCode= 1;
    
});