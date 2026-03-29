import subprocess
import sys
import time
import os

def main():
    print("==================================================")
    print(" Spawning Local RAG Servers (No Docker Required) ")
    print("==================================================\n")
    
    print("[1/2] Starting FastAPI Backend on Port 8000...")
    backend_process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "backend.main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"],
        cwd="../"  # Explicitly targeting the root repo boundary
    )
    
    time.sleep(3)
    
    print("\n[2/2] Starting React Frontend SPA...")
    npm_cmd = "npm.cmd" if os.name == "nt" else "npm"
    frontend_process = subprocess.Popen(
        [npm_cmd, "run", "dev"],
        cwd="../frontend" # Navigating from demo/ dynamically
    )
    
    try:
        print("\n==================================================")
        print(" [OK] Servers are actively running in the foreground!")
        print("          Backend: http://localhost:8000")
        print("          React UI: http://localhost:5173")
        print("==================================================\n")
        print(" [Press CTRL+C at any time to gracefully stop both servers]\n")
        
        backend_process.wait()
        frontend_process.wait()
        
    except KeyboardInterrupt:
        print("\n\n [\u26a0\ufe0f] Terminating Assessment Servers...")
        backend_process.terminate()
        frontend_process.terminate()
        backend_process.wait()
        frontend_process.wait()
        print(" [OK] Subprocesses closed successfully. Goodbye!")

if __name__ == "__main__":
    main()
