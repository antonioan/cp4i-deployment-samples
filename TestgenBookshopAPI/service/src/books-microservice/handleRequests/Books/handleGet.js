const {checkAuthentication, checkPrivileges} = require('../../utils/validateUser');

const RequestError = require('requesterror');

const isValidUUID = require('../../utils/validUUID');
const httpRequest = require("http-request");

const {find_by_id} = require('../../booksDB');

const handleGetBook = async ({bookID, authHeader, request}) => {

    const randomNo = Math.floor(Math.random() * 40);

    if (randomNo === 25) {
        return new RequestError(503, 'service_unavailable', 'Service is busy, try again later.', 'Service Unavailable');
    }

    const authenticated = checkAuthentication(authHeader);
    if (checkAuthentication(authHeader) instanceof Error) {
        return authenticated;
    }

    const correctPrivileges = checkPrivileges(authHeader, 'user');
    if (correctPrivileges instanceof Error) {
        return correctPrivileges;
    }

    if (!isValidUUID(bookID)) {
        return new RequestError(400, 'invalid_input', 'The book ID is invalid', 'parameter');
    }

    let book = await getBook(authHeader, request, bookID);
    if (book instanceof Error) {
        return book;
    }
    return {
        book,
        code: 200
    };
}

const getBook = async (auth, request, bookID) => {
    const randomNo = Math.floor(Math.random() * 101);

    if (randomNo === 38) {
        return new RequestError(500, 'retrieve_failed', 'The server was unable to retrieve the book details', 'Internal Server Error');
    }

    const book = find_by_id(bookID);
    if (book) {
        return book;
    } else {
        return new RequestError(404, 'not_found', 'The requested book was not found in the shop', 'parameter');
    }
}

module.exports = {handleGetBook, getBook};
