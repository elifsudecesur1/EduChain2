async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const zkVerifierAddress = "0x0000000000000000000000000000000000000000";

  const Restaking = await ethers.getContractFactory("Restaking");
  const stakingTokenAddress = "0x0a2227f13957C40E19193c1f4d86ed7B2730391c"; 
  const restaking = await Restaking.deploy(stakingTokenAddress, zkVerifierAddress);
  await restaking.deployed();
  console.log("Restaking deployed to:", restaking.address);

  const TokenLaunchpad = await ethers.getContractFactory("TokenLaunchpad");
  const tokenLaunchpad = await TokenLaunchpad.deploy(zkVerifierAddress);
  await tokenLaunchpad.deployed();
  console.log("TokenLaunchpad deployed to:", tokenLaunchpad.address);

  const JobListing = await ethers.getContractFactory("JobListing");
  const jobListing = await JobListing.deploy(zkVerifierAddress);
  await jobListing.deployed();
  console.log("JobListing deployed to:", jobListing.address);

  const VerifierManagement = await ethers.getContractFactory("VerifierManagement");
  const verifierManagement = await VerifierManagement.deploy();
  await verifierManagement.deployed();
  console.log("VerifierManagement deployed to:", verifierManagement.address);

  const BorrowLend = await ethers.getContractFactory("BorrowLend");
  const borrowLend = await BorrowLend.deploy();
  await borrowLend.deployed();
  console.log("BorrowLend deployed to:", borrowLend.address);

  const EduFi = await ethers.getContractFactory("EduFi");
  const eduFi = await EduFi.deploy();
  await eduFi.deployed();
  console.log("EduFi deployed to:", eduFi.address);

  const Earnings = await ethers.getContractFactory("Earnings");
  const earnings = await Earnings.deploy(zkVerifierAddress);
  await earnings.deployed();
  console.log("Earnings deployed to:", earnings.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
