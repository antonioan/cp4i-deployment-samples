#!/bin/bash

runsudo=0
tool=docker

delete=1
unnetwork=0

network=0
build=1
deploy=1

postdelete=0
postunnetwork=0

if ! command -v "$tool" &> /dev/null; then
    echo "$tool could not be found"
    exit 1
fi

if ! [[ "$PWD" == */TestgenBookshopAPI/service ]]; then
    echo "you must run this command from TestgenBookshopAPI/service"
    exit 2
fi

if [ "$runsudo" -ne 0 ]; then
    sudo echo "Authenticated successfully" || exit 3
    tool="sudo $tool"
fi

if [ "$delete" -ne 0 ]; then
    $tool kill \
        books-service \
        customer-order-service \
        bookshop-services \
        gateway-service
fi

if [ "$unnetwork" -ne 0 ]; then
    $tool network rm bookshop-network
fi

if [ "$network" -ne 0 ]; then
    $tool network create --attachable bookshop-network
fi

if [ "$build" -ne 0 ]; then
    $tool build \
        -t bookshop-books-service:latest \
        --build-arg SRC_DIR=books-microservice \
        .

    $tool build \
        -t bookshop-customer-service:latest \
        --build-arg SRC_DIR=customer-microservice \
        .

    $tool build \
        -t bookshop-services:latest \
        --build-arg SRC_DIR=services \
        .

    $tool build \
        -t bookshop-gateway-service:latest \
        --build-arg SRC_DIR=gateway-service \
        .
fi

if [ "$deploy" -ne 0 ]; then
    $tool run -dit --rm \
        --net  bookshop-network \
        -p     6001:5000 \
        --name books-service \
        --env  ALL_LANGUAGES=en \
        bookshop-books-service:latest

    $tool run -dit --rm \
        --net  bookshop-network \
        -p     6002:5000 \
        --name customer-order-service \
        bookshop-customer-service:latest

    $tool run -dit --rm \
        --net  bookshop-network \
        -p     6003:5000 \
        --name bookshop-services \
        bookshop-services:latest

    $tool run -dit --rm \
        --net  bookshop-network \
        -p     6000:5000 \
        --name gateway-service \
        bookshop-gateway-service:latest

fi

if [ "$postdelete" -ne 0 ]; then
    $tool kill \
        books-service \
        customer-order-service \
        bookshop-services \
        gateway-service
fi

if [ "$postunnetwork" -ne 0 ]; then
    $tool network rm bookshop-network
fi
