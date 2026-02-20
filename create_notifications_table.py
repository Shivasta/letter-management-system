#!/usr/bin/env python3
"""
Script to create the notifications table for the Letter Management System
Run this once to set up notifications tracking
"""

import mysql.connector
from mysql.connector import Error
import os

def create_notifications_table():
    """Create notifications table if it doesn't exist"""
    
    # Try different DB configurations
    db_configs = [
        {
            'host': os.environ.get('LMS_DB_HOST', 'localhost'),
            'user': os.environ.get('LMS_DB_USER', 'ram'),
            'password': os.environ.get('LMS_DB_PASSWORD', 'ram123'),
            'database': os.environ.get('LMS_DB_NAME', 'letter_management'),
        },
        {'host': 'localhost', 'user': 'root', 'password': '', 'database': 'letter_management'},
        {'host': 'localhost', 'user': 'root', 'password': 'root', 'database': 'letter_management'}
    ]
    
    db = None
    for config in db_configs:
        try:
            print(f"Trying to connect with user: {config['user']}...")
            db = mysql.connector.connect(**config)
            print(f"✅ Connected successfully with user: {config['user']}")
            break
        except Error as e:
            print(f"Failed with {config['user']}: {e}")
            continue
    
    if not db:
        print("❌ Could not connect to database with any configuration")
        return False
    
    try:
        cur = db.cursor()
        
        # Create notifications table
        create_table_query = """
        CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            request_id INT NOT NULL,
            type VARCHAR(50) NOT NULL,
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            status VARCHAR(50) NOT NULL,
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            read_at TIMESTAMP NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE CASCADE,
            INDEX idx_user_id (user_id),
            INDEX idx_is_read (is_read),
            INDEX idx_created_at (created_at)
        )
        """
        
        cur.execute(create_table_query)
        db.commit()
        print("✅ Notifications table created successfully!")
        
        # Also add status_changed_at column to requests table if it doesn't exist
        try:
            alter_requests_query = """
            ALTER TABLE requests 
            ADD COLUMN status_changed_at TIMESTAMP NULL
            """
            cur.execute(alter_requests_query)
            db.commit()
            print("✅ status_changed_at column added to requests table!")
        except Error as e:
            if "Duplicate column" in str(e):
                print("ℹ️  Column status_changed_at already exists")
            else:
                print(f"Note: {e}")
        
        cur.close()
        db.close()
        print("\n✅ Database setup completed!")
        
    except Error as e:
        print(f"❌ Error: {e}")
        return False
    
    return True

if __name__ == "__main__":
    create_notifications_table()
