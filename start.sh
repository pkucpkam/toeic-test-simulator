#!/bin/bash

echo "Starting Backend (Spring Boot)..."
start "Backend" bash -c "cd backend/practice && ./gradlew bootRun; exec bash"

echo "Starting Frontend (Next.js)..."
start "Frontend" bash -c "cd frontend && npm run dev; exec bash"

echo "Both services are starting in new terminals!"
