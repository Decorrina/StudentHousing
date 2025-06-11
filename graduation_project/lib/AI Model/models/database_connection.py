import pyodbc as odbc

DRIVER_NAME = 'SQL SERVER'
SERVER_NAME = r'.'  # Raw string to avoid newline error
DATABASE_NAME = 'StudentHousing.App'

connection_string = f"DRIVER={{{DRIVER_NAME}}};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME};Trusted_Connection=yes;"

conn = odbc.connect(connection_string)
print("Connection successful:", conn)
