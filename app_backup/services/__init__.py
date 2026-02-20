"""Services package for Letter Management System"""

from .database import init_database, create_sample_data, migrate_legacy_data, check_database_health

__all__ = ['init_database', 'create_sample_data', 'migrate_legacy_data', 'check_database_health']