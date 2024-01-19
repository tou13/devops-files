#!/usr/bin/env bash

apt update && apt upgrade -y

if ! command -v wget &> /dev/null; then
    apt install wget -y
fi

if ! command -v curl &> /dev/null; then
    apt install curl -y
fi

if ! command -v git &> /dev/null; then
    apt install git -y
fi

if ! command -v nano &> /dev/null; then
    apt install nano -y
fi