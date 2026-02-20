#!/usr/bin/env python3
"""
Letter Management System - Startup Script
Educational Flow Management System

This runner explicitly boots the legacy monolithic app.py so all existing
routes referenced by the templates are available. Importing "app" by module
name would pick up the app/ package instead, which omits most endpoints.
"""

import os
import sys
from importlib.util import module_from_spec, spec_from_file_location

def check_dependencies():
    """Check if all required dependencies are installed"""
    required_packages = {
        'flask': 'flask',
        'mysql-connector-python': 'mysql.connector',
        'flask-wtf': 'flask_wtf',
        'flask-limiter': 'flask_limiter',
        'bleach': 'bleach',
        'flask-login': 'flask_login'
    }
    missing_packages = []
    
    for package_name, import_name in required_packages.items():
        try:
            __import__(import_name)
        except ImportError:
            missing_packages.append(package_name)
    
    if missing_packages:
        print(f"Missing packages: {', '.join(missing_packages)}")
        print("Install them using: pip install -r requirements.txt")
        return False
    return True


def load_legacy_app():
    """Load the monolithic app.py without colliding with the app package."""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    legacy_path = os.path.join(base_dir, 'app.py')

    if not os.path.exists(legacy_path):
        raise FileNotFoundError(f"Cannot find legacy app at {legacy_path}")

    spec = spec_from_file_location("legacy_app", legacy_path)
    module = module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def main():
    """Main startup function"""
    print("Starting Letter Management System...")
    print("=" * 50)
    
    # Check dependencies
    if not check_dependencies():
        sys.exit(1)
    
    # Load legacy monolithic app with full route coverage
    try:
        legacy = load_legacy_app()
    except Exception as e:
        print(f"Failed to load legacy app.py: {e}")
        sys.exit(1)

    app = getattr(legacy, 'app', None)
    init_db = getattr(legacy, 'init_db', None)

    if app is None or init_db is None:
        print("Loaded module missing expected `app` or `init_db` attributes.")
        sys.exit(1)

    # Initialize database
    print("Setting up database...")
    try:
        with app.app_context():
            init_db()
            print("Database setup complete.")
    except Exception as e:
        print(f"Database setup failed: {e}")
        # Continuing as it might be a transient connectivity issue
    
    # Run the Flask app
    try:
        print("Letter Management System is starting...")
        print("Access the portal at: http://localhost:5000")
        print("=" * 50)
        
        app.run(
            host=os.getenv('FLASK_HOST', '0.0.0.0'),
            port=int(os.getenv('FLASK_PORT', 5000)),
            debug=app.debug or True
        )
    except Exception as e:
        print(f"Failed to start the application: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
