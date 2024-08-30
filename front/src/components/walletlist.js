import React from 'react';

const supportedWallets = [
  {
    name: 'MetaMask',
    url: 'https://metamask.io/',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/3/36/MetaMask_Fox.svg',
  },
  {
    name: 'Trust Wallet',
    url: 'https://trustwallet.com/',
    logo: 'https://trustwallet.com/assets/images/media/assets/TWT.png',
  },
  {
    name: 'Coinbase Wallet',
    url: 'https://www.coinbase.com/wallet',
    logo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Coinbase.svg/1200px-Coinbase.svg.png',
  },
  {
    name: 'Argent',
    url: 'https://www.argent.xyz/',
    logo: 'https://argent.link/static/images/logo/argent-logo.svg',
  },
  {
    name: 'Rainbow',
    url: 'https://rainbow.me/',
    logo: 'https://res.cloudinary.com/rainbow-wallet/image/upload/q_auto,f_auto,w_300,h_300/v1635796434/Rainbow%20App%20Logos/Rainbow%20Logo%20Oct%202021.png',
  },
  {
    name: 'imToken',
    url: 'https://token.im/',
    logo: 'https://token.im/images/imtoken_logo_blue.png',
  },
  {
    name: 'Zerion',
    url: 'https://zerion.io/',
    logo: 'https://zerion.io/favicon.ico',
  },
  {
    name: 'SafePal',
    url: 'https://www.safepal.io/',
    logo: 'https://www.safepal.io/static/media/logo.77e54e1e.svg',
  },
  {
    name: 'Ledger Live',
    url: 'https://www.ledger.com/ledger-live',
    logo: 'https://cdn.shopify.com/s/files/1/2974/4858/products/Ledger-Live-logo_1200x1200.png',
  },
  {
    name: 'Trezor',
    url: 'https://trezor.io/',
    logo: 'https://trezor.io/static/images/brand/trezor-logo.svg',
  },
];

const WalletList = () => {
  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
      <h2>Supported Wallets</h2>
      <p>The following wallets support the Arbitrum network:</p>
      <ul style={{ listStyleType: 'none', padding: 0 }}>
        {supportedWallets.map((wallet, index) => (
          <li key={index} style={{ display: 'flex', alignItems: 'center', marginBottom: '15px' }}>
            <img src={wallet.logo} alt={`${wallet.name} Logo`} style={{ marginRight: '10px', borderRadius: '5px', width: '50px', height: '50px' }} />
            <a href={wallet.url} target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'none', color: '#0a66c2', fontSize: '18px' }}>
              {wallet.name}
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default WalletList;
