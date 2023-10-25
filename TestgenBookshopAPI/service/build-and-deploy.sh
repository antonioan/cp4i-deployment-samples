#!/bin/bash

runsudo=0
tool=docker
tag=latest

terminate=0
unnetwork=0

network=0
build=0
deploy=0

function do_build() {
    name="$1"
    src_dir="$2"
    $tool build -t "$name:$tag" --build-arg SRC_DIR="$src_dir" .
}

function do_run() {
    name="$1"
    label="$2"
    port="$3"
    $tool run -dit --rm --net bookshop-network -p $port:5000 --name "$label" "$name:$tag"
}

if ! command -v "$tool" &> /dev/null; then
    echo "$tool could not be found"
    exit 1
fi

if ! [[ "$PWD" == */TestgenBookshopAPI/service ]]; then
    echo "you must run this command from inside TestgenBookshopAPI/service"
    exit 2
fi

if [ "$runsudo" -ne 0 ]; then
    sudo echo "Authenticated successfully" || exit 3
    tool="sudo $tool"
fi

if [ "$terminate" -ne 0 ]; then
    $tool kill books-service customer-order-service bookshop-services gateway-service
fi

if [ "$unnetwork" -ne 0 ]; then
    $tool network rm bookshop-network
fi

if [ "$network" -ne 0 ]; then
    if [ "$tool" -eq "docker" ]; then
        $tool network create --attachable bookshop-network
    else
        $tool network create bookshop-network
    fi
fi

if [ "$build" -ne 0 ]; then
    do_build "bookshop-books-service" "books-microservice"
    do_build "bookshop-customer-service" "customer-microservice"
    do_build "bookshop-services" "services"
    do_build "bookshop-gateway-service" "gateway-service"
fi

if [ "$deploy" -ne 0 ]; then
    do_run "bookshop-books-service" "books-service" 5001
    do_run "bookshop-customer-service" "customer-order-service" 5002
    do_run "bookshop-services" "bookshop-services" 5003
    do_run "bookshop-gateway-service" "gateway-service" 5000
fi
