@echo off
echo Starting Backend (Spring Boot)...
start "Backend" cmd /k "cd backend\practice && gradlew bootRun"

echo Starting Frontend (Next.js)...
start "Frontend" cmd /k "cd frontend && npm run dev"

echo Both services are starting in new terminals!
