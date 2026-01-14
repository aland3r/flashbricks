# Flashbricks

A mobile application built with React Native (CLI) frontend and FastAPI backend.

## Project Structure

```
flashbricks/
├── frontend/          # React Native CLI app
├── backend/           # FastAPI project (Domain-Driven Design)
├── docs/              # Documentation and requirements
├── .gitignore         # Git ignore rules
└── README.md          # Project documentation
```

## Prerequisites

### Backend (FastAPI)
- Python 3.12+
- [uv](https://github.com/astral-sh/uv) - Fast Python package and project manager

### Frontend (React Native)
- Node.js 20+
- npm or yarn
- React Native CLI
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

## Backend Setup

### Install uv

If you haven't installed uv yet:

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
```

**macOS/Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Set Up the Backend

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Sync dependencies:**
   ```bash
   uv sync
   ```
   This will create a virtual environment and install all dependencies.

3. **Create environment file (optional):**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` if you need to customize settings.

4. **Run the development server:**
   ```bash
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   
   Or using the FastAPI CLI:
   ```bash
   uv run fastapi dev app/main.py
   ```
   
   The server will run on `http://127.0.0.1:8000`

5. **Test the API:**
   - Health check endpoint: `http://127.0.0.1:8000/api/v1/health`
   - API Documentation: `http://127.0.0.1:8000/docs`
   - Alternative Docs: `http://127.0.0.1:8000/redoc`

## Frontend Setup

1. **Navigate to the frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure API endpoint:**
   
   Edit `frontend/src/config/api.ts` and update the `API_BASE_URL` based on your setup:
   
   - **Android Emulator:** `http://10.0.2.2:8000` (for connecting to backend)
   - **iOS Simulator:** `http://localhost:8000`
   - **Physical Device:** `http://YOUR_COMPUTER_IP:8000` (find your IP with `ipconfig` on Windows or `ifconfig` on macOS/Linux)

4. **Start Metro bundler:**
   ```bash
   npm start
   ```

5. **Run the app:**
   
   For Android:
   ```bash
   npm run android
   ```
   
   For iOS (macOS only):
   ```bash
   npm run ios
   ```

## Development Workflow

### Running Both Services

You'll need to run both the FastAPI backend and React Native frontend:

1. **Terminal 1 - FastAPI Backend:**
   ```bash
   cd backend
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   
   Or:
   ```bash
   cd backend
   uv run fastapi dev app/main.py
   ```

2. **Terminal 2 - React Native Frontend:**
   ```bash
   cd frontend
   npm start
   ```

3. **Terminal 3 - Run App (optional, can use Terminal 2):**
   ```bash
   cd frontend
   npm run android  # or npm run ios
   ```

## API Configuration

### CORS Settings

The FastAPI backend is configured with CORS headers to allow requests from React Native. The settings are in `backend/app/config.py`:

- Configure `CORS_ALLOWED_ORIGINS` in `.env` file or environment variables
- Default origins include React Native development servers

### API Endpoints

- `GET /api/v1/health` - Health check endpoint

Add more endpoints in `backend/app/api/v1/endpoints/` following the Domain-Driven Design structure.

## Project Details

### Backend Stack
- **FastAPI** - Modern, fast web framework
- **uv** - Fast Python package and project manager
- **Pydantic** - Data validation using Python type annotations
- **uvicorn** - ASGI server
- **Domain-Driven Design (DDD)** - Clean architecture with separation of concerns

### Frontend Stack
- **React Native 0.83.1** - Mobile framework
- **TypeScript** - Type safety
- **Axios** - HTTP client for API calls

## Troubleshooting

### Backend Issues

1. **Port already in use:**
   ```bash
   # Change port in .env file or use different port:
   uv run uvicorn app.main:app --reload --port 8001
   ```

2. **uv not found:**
   - Make sure uv is installed (see Backend Setup section)
   - Add uv to your PATH if needed
   - Restart your terminal/IDE after installation

3. **Dependencies issues:**
   ```bash
   cd backend
   uv sync
   ```

### Frontend Issues

1. **Metro bundler cache:**
   ```bash
   npm start -- --reset-cache
   ```

2. **Android build issues:**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   npm run android
   ```

3. **iOS build issues (macOS):**
   ```bash
   cd ios
   pod install
   cd ..
   npm run ios
   ```

4. **Cannot connect to API:**
   - Ensure FastAPI server is running
   - Check API_BASE_URL in `frontend/src/config/api.ts`
   - Verify CORS settings in `backend/app/config.py` or `.env`
   - For physical devices, ensure your phone and computer are on the same network
   - Check firewall settings

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

[Add your license here]

