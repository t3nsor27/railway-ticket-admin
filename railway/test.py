import datetime
import mysql.connector
from ast import literal_eval
from decimal import Decimal
import bcrypt

# a = datetime.datetime(2025,4,19,15,17,0)
# b = datetime.datetime(2025,4,19, 20,30,0)
# print(a.strftime("%Y %y %d %D %m %M %H %h %S"), '----', datetime.timedelta(days=1))
# c= (b-a).seconds
# print(b-a)
# print((b-a).days, c/(60*60), c/(60), c%60)
# print(type(a.date()))
# print(f"{2.51:.0f}")

# Connect to the MySQL server
conn = mysql.connector.connect(
    host="localhost",      # or your host like '127.0.0.1'
    user="root",  # e.g., 'root'
    password="srikant",
    database="dbtest"
)

user_id=1
keys = ["train_name", "train_no", "departure_time", "departure_date", "departure_station", "distance", "duration", "arrival_time", "arrival_date", "arrival_station"]
data = []

with conn.cursor() as cursor:
    cursor.execute('''SELECT ticket_no, status_id, starting_station_id, ending_station_id, train_id, ticket_class_id, transaction_id, booking_date, seat_no, position_number, distance
    FROM booking
    WHERE passenger_id = %s;''', (user_id,))
    rows = cursor.fetchall()

for row in rows:
    train_no = row[4]
    starting_station_id = row[2]
    ending_station_id = row[3]
    distance = f"{row[10]:.0f} km"
    with conn.cursor() as cursor:
        cursor.execute('''SELECT name FROM train WHERE id=%s;''', (train_no,))
        train_name = cursor.fetchone()[0]
        
        cursor.execute('''SELECT name FROM train_station WHERE id=%s;''', (starting_station_id,))
        departure_station = cursor.fetchone()[0]
        
        cursor.execute('''SELECT name FROM train_station WHERE id=%s;''', (ending_station_id,))
        arrival_station = cursor.fetchone()[0]
        
        cursor.execute('''SELECT departure_time FROM journey_station WHERE train_id=%s AND station_id=%s;''', (train_no, starting_station_id))
        departure_datetime = cursor.fetchone()[0]
        departure_time = departure_datetime.strftime("%H:%M")
        departure_date = departure_datetime.strftime("%d %b, %Y")
        
        cursor.execute('''SELECT departure_time FROM journey_station WHERE train_id=%s AND station_id=%s;''', (train_no, ending_station_id))
        arrival_datetime = cursor.fetchone()[0]
        arrival_time = arrival_datetime.strftime("%H:%M")
        arrival_date = arrival_datetime.strftime("%d %b, %Y")
    delta = int((arrival_datetime-departure_datetime).total_seconds())
    days = delta // 86400
    hour = (delta % 86400) // 3600
    min = (delta % 3600) // 60
    duration = (f"{days}d " if days else "") + f"{hour}h {min}m"
    curr_data = [train_name, train_no, departure_time, departure_date, departure_station, distance, duration, arrival_time, arrival_date, arrival_station]
    data.append(dict(zip(keys, curr_data)))

# print(data[0])

with conn.cursor() as cursor:
    cursor.execute('''SELECT COUNT(*) FROM booking''')
    booking_id = cursor.fetchone()
print(booking_id)

with conn.cursor() as cursor:
    cursor.execute('''SELECT concession FROM concession WHERE category=%s''', ('DISABLED',))
    c = float(cursor.fetchone()[0])

print(c*4, type(c))
#print(bcrypt.hashpw(b'test', bcrypt.gensalt()))
        

conn.close()
