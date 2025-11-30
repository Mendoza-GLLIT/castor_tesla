import psycopg2

def get_db_connection():
    return psycopg2.connect(
        dbname="CastorTesla",
        user="postgres",
        password="160603", #Valente:1234 
        host="localhost",
        port="5432"
    )