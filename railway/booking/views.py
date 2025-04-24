from django.shortcuts import render, redirect
from django.contrib.auth import login, authenticate
from django.http import HttpResponse, JsonResponse
from django.db import connection
from django.template import loader


from decimal import Decimal
from datetime import datetime, date, timedelta
import bcrypt
import json
from ast import literal_eval

def form_test(request):
    return render(request, "booking/test.html", {"extra": request.POST.dict()})

def test_view(request):
    with connection.cursor() as cursor:
        cursor.execute('''SELECT t.id, t.name, js1.departure_time as Departure_Time, js2.departure_time as Arrival_Time, (js2.distance_from_start-js1.distance_from_start) as Distance
                        FROM train t
                        JOIN journey_station js1 ON t.id = js1.train_id
                        JOIN journey_station js2 ON t.id = js2.train_id
                        JOIN train_station ts1 ON js1.station_id = ts1.id
                        JOIN train_station ts2 ON js2.station_id = ts2.id
                        WHERE ts1.id = 2
                        AND ts2.id = 4
                        AND js1.departure_time > "2025-04-19 00:00:00"
                        AND js1.stop_order < js2.stop_order
                        ORDER BY js1.departure_time;''')
        rows = [cursor.fetchall()]
        rows[0] = [list(i) for i in rows[0]]
        
        for i in range(len(rows[0])):
            delta = int((rows[0][i][3]-rows[0][i][2]).total_seconds())
            days = delta // 86400
            hour = (delta % 86400) // 3600
            min = (delta % 3600) // 60
            duration = (f"{days}d " if days else "") + f"{hour}h {min}m"
            rows[0][i].extend([duration, rows[0][i][2].strftime("%d %b, %Y"), rows[0][i][2].strftime("%H:%M")])
        column_name = [[col[0] for col in cursor.description]+["Duration", "dept date", "dept time"]]
        cursor.execute('''select * from seat_availability;''')
        rows.append(cursor.fetchall())
        column_name.append([col[0] for col in cursor.description])
        cursor.close()
    if rows:
        rows = [[[float(val) if isinstance(val, Decimal) else val for val in r] for r in r2] for r2 in rows]
        rows = [[[val.strftime("%Y-%m-%d %H:%M:%S") if isinstance(val, datetime) else val for val in r] for r in r2] for r2 in rows]
        # response = f"Fetched {len(rows)} rows:<br>" + "<br>".join(str(row) for row in rows)
    # else: return HttpResponse("Failed")
    return render(request, "booking/test.html", {
        "row_data": rows, 
        "column_names": column_name,
        # "extra": bcrypt.checkpw(password.encode('utf-8'), rows[0][2].encode('utf-8'))
        "extra": rows,
    })

def login_view(request):
    request.session.flush()
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        password = password.encode('utf-8')
         
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, username, password, category FROM user WHERE username=%s;", (username,))
            user = cursor.fetchall()
            cursor.close()
        
        if not user:
            return render(request, "booking/login.html", {"error_message": 'Wrong Username or Password'})
        
        if bcrypt.checkpw(password, user[0][2].encode('utf-8')):
            request.session['user_id'] = str(user[0][0])
            request.session['username'] = str(user[0][1])
            
            with connection.cursor() as cursor:
                cursor.execute('''SELECT concession FROM concession WHERE category=%s''', (user[0][3],))
                request.session['concession'] = float(cursor.fetchone()[0])
            
            return redirect("booking:home")
        else:
            return render(request, "booking/login.html", {"error_message": 'Wrong Username or Password'})
    return render(request, "booking/login.html", {"error_message": None})

def home_view(request):
    if 'user_id' not in request.session:
        return render(request, "booking/home.html", {"error_message": "Please Login first."})
    
    user_id = request.session.get('user_id')
    keys = ["booking_id", "train_name", "train_no", "departure_time", "departure_date", "departure_station", "distance", "duration", "arrival_time", "arrival_date", "arrival_station", "seat_no", "position_number", "amount", "class_name", "status", "status_style"]
    data = []
    
    with connection.cursor() as cursor:
        cursor.execute('''SELECT ticket_no, status_id, starting_station_id, ending_station_id, train_id, ticket_class_id, transaction_id, booking_date, seat_no, position_number, distance
        FROM booking
        WHERE passenger_id = %s;''', (user_id,))
        rows = cursor.fetchall()
    
    if not rows:
        return render(request, 'booking/home.html', {"error_message": "No bookings available."})
    
    for row in rows:
        booking_id = row[0]
        train_no = row[4]
        status_id = row[1]
        starting_station_id = row[2]
        ending_station_id = row[3]
        distance = f"{row[10]:.0f} km"
        seat_no = row[8]
        position_number = row[9]
        transaction_id = row[6]
        ticket_class_id = row[5]
        
        with connection.cursor() as cursor:
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
            
            cursor.execute('''SELECT amount FROM transaction where id=%s;''', (transaction_id,))
            amount = cursor.fetchone()[0]
            
            cursor.execute('''SELECT class_name FROM carriage_class WHERE id=%s;''', (ticket_class_id,))
            class_name = cursor.fetchone()[0]
            
            cursor.execute('''SELECT status FROM booking_status where id=%s''', (status_id,))
            status_style = cursor.fetchone()[0]
            
            cursor.execute('''SELECT id FROM booking_status WHERE status="CANCELLED"''')
            cancelled_id = cursor.fetchone()[0]
        
        if status_id==cancelled_id: status = "CNCL"
        elif seat_no: status = f"CNF{seat_no}"
        else: status = f"{status_style}{position_number}"
                
        delta = int((arrival_datetime-departure_datetime).total_seconds())
        days = delta // 86400
        hour = (delta % 86400) // 3600
        min = (delta % 3600) // 60
        duration = (f"{days}d " if days else "") + f"{hour}h {min}m"
        curr_data = [booking_id, train_name, train_no, departure_time, departure_date, departure_station, distance, duration, arrival_time, arrival_date, arrival_station, seat_no, position_number, amount, class_name, status, status_style]
        data.append(dict(zip(keys, curr_data)))
    data = data[::-1]

    return render(request, "booking/home.html", {"username": request.session.get('username'), "row_data": data})


def train_view(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT id, name from train_station")
        rows = cursor.fetchall()
    keys = ["id", "name"]
    station_info = [dict(zip(keys, i)) for i in rows]
    if request.method == "POST":
        if 'from' in request.POST:
            from_station = request.POST.get("from")
            to_station = request.POST.get("to")
            journey_date = request.POST.get("date")
            with connection.cursor() as cursor:
                cursor.execute('''SELECT t.id, t.name, js1.departure_time as Departure_Time, js2.departure_time as Arrival_Time, (js2.distance_from_start-js1.distance_from_start) as Distance
                FROM train t
                JOIN journey_station js1 ON t.id = js1.train_id
                JOIN journey_station js2 ON t.id = js2.train_id
                JOIN train_station ts1 ON js1.station_id = ts1.id
                JOIN train_station ts2 ON js2.station_id = ts2.id
                WHERE ts1.id = %s
                AND ts2.id = %s
                AND js1.departure_time BETWEEN %s and %s
                AND js1.stop_order < js2.stop_order
                ORDER BY js1.departure_time;''', (from_station, to_station, journey_date, (date.fromisoformat(journey_date)+timedelta(days=1)).strftime("%Y-%m-%d")))
                rows = cursor.fetchall()
                cursor.execute("SELECT name from train_station WHERE id=%s", (from_station,))
                departure_station = cursor.fetchone()[0]
                cursor.execute("SELECT name from train_station WHERE id=%s", (to_station,))
                arrival_station = cursor.fetchone()[0]


            keys = ["train_name", "train_no", "departure_time", "departure_date", "departure_station", "distance", "duration", "arrival_time", "arrival_date", "arrival_station", "seat_avail_data", "distance_info", "username", "departure_station_id", "arrival_station_id", "journey_date"]
            data = list()

   
            if not rows:
                return render(request, "booking/t.html", {"username": request.session.get('username'), "train_stations": station_info, "error_message": "No Trains Available ╯︿╰"})
            for row in rows:
                train_name = row[1]
                train_id = row[0]
                departure_time = row[2].strftime("%H:%M")
                departure_date = row[2].strftime("%d %b, %Y")
                distance = f"{row[4]:.0f} km"
                delta = int((row[3]-row[2]).total_seconds())
                days = delta // 86400
                hour = (delta % 86400) // 3600
                min = (delta % 3600) // 60
                duration = (f"{days}d " if days else "") + f"{hour}h {min}m"
                arrival_time = row[3].strftime("%H:%M")
                arrival_date = row[3].strftime("%d %b, %Y")
                distance_info = float(row[4])
                
                seat_data = dict()
                with connection.cursor() as cursor2:
                    cursor2.execute('''SELECT carriage_class_id, total_seats, available_seats, rac_seats, waiting_list, total_rac_seats, total_waiting_list, cc.class_name, cc.distance_price_multiplier
                                    FROM  seat_availability sa
                                    JOIN journey_station js on sa.train_id = js.train_id
                                    AND DATE(js.departure_time) = sa.journey_date
                                    AND js.stop_order=1
                                    JOIN carriage_class cc on sa.carriage_class_id = cc.id
                                    WHERE sa.train_id = %s
                                    AND sa.journey_date = %s;
                                    ''', (train_id, row[2].strftime("%Y-%m-%d")))
                    seat_rows = cursor2.fetchall()
                    for srow in seat_rows:
                        if srow[2]:
                            statement = f"AVL {srow[2]}"
                            status = "available"
                        elif srow[3]:
                            statement = f"RAC {srow[5]-srow[3]+1}"
                            status = "rac"
                        elif srow[4]:
                            statement = f"WL {srow[6]-srow[4]+1}"
                            status = "waitlist"
                        seat_data[f"{srow[7]}"] = [statement, srow[0], status]
                
                curr_data = [train_name, train_id, departure_time, departure_date, departure_station, distance, duration, arrival_time, arrival_date, arrival_station, seat_data, distance_info, request.session.get('username'), from_station, to_station, row[2].strftime("%Y-%m-%d")]
                data.append(dict(zip(keys,curr_data)))
            
            return render(request, "booking/t.html", {"username": request.session.get('username'), "train_stations": station_info, "row_data": data})
    
    return render(request, "booking/t.html", {"username": request.session.get('username'), "train_stations": [dict(zip(keys, i)) for i in rows]})


def pay_view(request):
    if 'username' not in request.session:
        return render(request, 'booking/pay.html', {"error_message": "Please Login First"})
    if request.method=='POST':
        context = literal_eval(request.POST.get('row_dict'))
        carriage_class = request.POST.get('class-selection')
        concession = request.session.get('concession')
        with connection.cursor() as cursor:
            cursor.execute("SELECT distance_price_multiplier FROM carriage_class WHERE id=%s", (carriage_class,))
            multiplier=float(cursor.fetchall()[0][0])

        carriage_name = list(context['seat_avail_data'].keys())[int(carriage_class)-1]
        context['carriage_name'] = carriage_name
        context['carriage_class'] = carriage_class
        context['carriage_status'], context['status'] = context['seat_avail_data'][carriage_name][0], context['seat_avail_data'][carriage_name][2]
        context['price']= f"{context['distance_info']*multiplier*concession:.2f}"
        context['username'] = request.session.get('username')
        context['context'] = str(context)
        return render(request, 'booking/pay.html', context)
    return render(request, 'booking/pay.html', {"error_message": "Invalid Access"})

def update_price(request):
    if request.method=='POST':
        data = json.loads(request.body)
        print(request.body)
        selected_class = data.get('selected_class')
        distance = float(data.get('distance')[:3])
        concession = request.session.get('concession')
        
        with connection.cursor() as cursor:
            cursor.execute("SELECT distance_price_multiplier FROM carriage_class WHERE id=%s", (selected_class,))
            multiplier=float(cursor.fetchall()[0][0])

                
        return JsonResponse({
            'price': f"{distance*multiplier*concession:.2f}"
        })
        
def confirm_view(request):
    if 'username' not in request.session:
        return render(request, 'booking/confirm.hmtl', {"error_message": "Pleas Login first."})
    if request.method=="POST":
        data = literal_eval(request.POST.get("data"))
        user_id = request.session.get('user_id')
        train_id = data['train_no']
        start_station = data['departure_station_id']
        end_station = data['arrival_station_id']
        class_id = data['carriage_class']
        journey_date = data['journey_date']
        distance = data['distance_info']
        payment_method = str(request.POST.get('payment_method'))
        amount = float(data['price'])
        status = "DONE"
        payment_method=payment_method.replace('_', '').upper()
        
        with connection.cursor() as cursor:
            cursor.execute('''INSERT INTO transaction(amount, method, status, date) VALUES (%s, %s, %s, NOW());''', (amount, payment_method, status))
            cursor.execute('''SELECT COUNT(*) FROM transaction''')
            transaction_id = cursor.fetchall()[0][0]
        
        with connection.cursor() as cursor:
            cursor.execute('''CALL book_ticket(%s,%s,%s,%s,%s, %s, %s, %s);''', (user_id, train_id, start_station, end_station, class_id, journey_date, transaction_id, distance))
        return render(request, 'booking/confirm.html', {"username": request.session.get('username')})
    return render(request, "booking/confirm.html", {"error_message": "Invalid Access"})

def cancel_view(request):
    if 'username' not in request.session:
        return render(request, 'booking/confirm.hmtl', {"error_message": "Pleas Login first."})
    if request.method=="POST":
        username = request.session.get('username')
        booking_id = request.POST.get('booking_id')
        
        with connection.cursor() as cursor:
            cursor.execute('''CALL cancel_ticket(%s);''', (booking_id, ))
            
        return render(request, 'booking/cancel.html', {"username": username})
    return render(request, "booking/confirm.html", {"error_message": "Invalid Access"})