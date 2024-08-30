const webpack = require('webpack');

module.exports = function override(config) {
  config.resolve.fallback = {
    stream: require.resolve('stream-browserify'),
    util: require.resolve('util/'),
    buffer: require.resolve('buffer/'),
    assert: require.resolve('assert/'),
    https: require.resolve('https-browserify'),
    http: require.resolve('stream-http'),
    os: require.resolve('os-browserify/browser'),
    url: require.resolve('url/')  // Bu satırı ekleyin
  };

  config.plugins.push(
    new webpack.ProvidePlugin({
      process: 'process/browser',
      Buffer: ['buffer', 'Buffer'],
    })
  );

  return config;
};
