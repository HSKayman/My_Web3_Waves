const mongoose = require('mongoose');

module.exports = mongoose.model('WalletInfo', { name: String, publicKey: String, privateKey: String });