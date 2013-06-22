#!/bin/bash

PROJECT_PATH=$(dirname $0)/../

cd $PROJECT_PATH && bundle exec guard
