import { ethers } from 'ethers';

// Bu dosyada cüzdanlar ve ağ bağlantıları için servisler oluşturabilirsiniz

export const getProvider = () => {
  return new ethers.providers.JsonRpcProvider("https://rinkeby.arbitrum.io/rpc");
}

export const connectToNetwork = async () => {
  const provider = getProvider();
  const network = await provider.getNetwork();
  return network;
}
