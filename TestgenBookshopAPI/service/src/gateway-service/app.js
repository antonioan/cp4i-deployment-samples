const express = require('express')
const proxy = require('express-http-proxy')

const PORT = process.env.GATEWAY_PORT || 5000
const BOOK_SERVICE = process.env.BOOK_SERVICE || 'http://books-service:5000'
const CUSTOMER_SERVICE = process.env.CUSTOMER_SERVICE || 'http://customer-order-service:5000'
const BOOKSHOP_SERVICES = process.env.BOOKSHOP_SERVICES || 'http://bookshop-services:5000'

function proxyOptions(prefix) {
    return {
        proxyReqPathResolver: function (req) {
            return `${prefix}${req.url}`
        },
        proxyErrorHandler: function (err, res, next) {
            next(err);
        },
        parseReqBody: false,
        timeout: 120000
    }
}

const app = express()

app.use('/books',
    proxy(BOOK_SERVICE, proxyOptions('/books')))

app.use('/customers',
    proxy(CUSTOMER_SERVICE, proxyOptions('/customers')))

app.use('/services',
    proxy(BOOKSHOP_SERVICES, proxyOptions('/services')))

app.listen(PORT, () => console.log(`Gateway is listening on ${PORT}...`))

module.exports = app
