from rethinkdb import RethinkDB
import time
r = RethinkDB()

class RethinkDBConnection:
    def __init__(self,configs):
        self.host = configs["host"]
        self.port = configs["port"]
        self.db_name = configs["db_name"]
        self.username = configs["username"]
        self.password = configs["password"]

    def __enter__(self):
        self.conn = r.connect(host=self.host, port=self.port, db=self.db_name, user=self.username, password=self.password)
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.conn.close()

    def write(self, table, data):
        r.table(table).insert(data).run(self.conn)

    def query(self, table, query):
        result = r.table(table).filter(query).run(self.conn)
        return list(result)
    def insert_data(self,data):
        self.write('data',{'ts':time.time(), 'data':data})
    def get_latest_data(self):
        result = self.query('data', r.table('data').max('ts'))
        return result[0] if result else None
    def get_data_last_ts(self,t):
        timestamp = time.time() - t
        return self.query('data',r.row['ts']>timestamp)
    def get_data_last_n(self, n):
        return r.table('data').order_by(r.desc('ts')).limit(n).run(self.conn)
    
    def create_table_if_not_exists(self, table_name):
        # Check if the table exists
        if table_name not in r.table_list().run(self.conn):
            # Create the table
            r.table_create(table_name).run(self.conn)
            print(f"Table '{table_name}' created.")
        else:
            print(f"Table '{table_name}' already exists.")

