## Plan to Set Up and Run the AFL Fantasy Manager Locally

This plan outlines how to organize and install the project dependencies and run the AFL Fantasy Manager project on your local machine, either via Docker (recommended for full system testing) or by running the frontend and backend separately (helpful for development).

### 1. Verify Prerequisites
- Ensure Docker and Docker Compose are installed:
  - Docker version: 27.5.1
  - Docker Compose version: v2.32.4
- Confirm Python 3.13.3 is installed.
- Confirm Node.js 22.15.0 is installed.

### 2. Running Everything with Docker (Recommended)
1. Open your project directory and run:
   ```
   sudo docker-compose up -d
   ```
2. Access the application:
   - Frontend UI: http://localhost:3000
   - Backend API: http://localhost:5000/api/health
3. To view real-time logs:
   ```
   sudo docker-compose logs -f
   ```
4. To stop the application:
   ```
   sudo docker-compose down
   ```

### 3. Running Components Separately (Development Mode)
1. Prepare the Backend:
   - Enter the backend folder:
     ```
     cd server
     ```
   - Create and activate a Python virtual environment:
     ```
     python -m venv .venv
     source .venv/bin/activate
     ```
   - Install requirements:
     ```
     pip install -r api/requirements.txt
     pip install -r scraper/requirements.txt
     ```
   - Start the Flask server in debug mode:
     ```
     cd api
     flask run --debug
     ```
2. Prepare the Frontend:
   - In a new terminal, navigate to the project root
   - Install Node.js dependencies:
     ```
     npm install
     ```
   - Start the frontend development server:
     ```
     PORT=3001 npm start
     ```

### 4. Database Setup
- The project uses PostgreSQL with Docker
- Default connection: localhost:5432, user: postgres, database: afldb
- Check port conflicts with ports 3000, 5000, or 5432.

### 5. Environment Variables
- Copy `.env.example` to `.env` and configure as needed
- Ensure all required API keys and database credentials are set

### 6. Troubleshooting
- If ports are in use, modify the port configurations in docker-compose.yml
- Check Docker logs for any startup issues
- Verify all environment variables are correctly set
