#!/bin/bash

if curl -f http://localhost:27000/ && \
   curl -f http://localhost:27003/ && \
   curl -f http://localhost:27020/ && \
   curl -f http://localhost:27021/; then
  exit 0
else
  exit 1
fi