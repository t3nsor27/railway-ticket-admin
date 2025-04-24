CREATE TABLE booking_status(
	id INT PRIMARY KEY AUTO_INCREMENT,
	status VARCHAR(10) NOT NULL
);

CREATE TABLE user(
	id INT PRIMARY KEY AUTO_INCREMENT,
	username VARCHAR(45) NOT NULL UNIQUE,
	password CHAR(60) NOT NULL,
	mob CHAR(10) NOT NULL,
	dob DATE NOT NULL,
	email VARCHAR(60) NOT NULL,
	category ENUM('STUDENT', 'SENIOR CITIZEN', 'DISABLED', 'GENERAL') NOT NULL
);

CREATE TABLE concession(
	category ENUM('STUDENT', 'SENIOR CITIZEN', 'DISABLED', 'GENERAL') NOT NULL,
	concession DECIMAL(3,2)
);

CREATE TABLE transaction(
	id INT PRIMARY KEY AUTO_INCREMENT,
	amount DECIMAL(7,2) NOT NULL,
	method varchar(10) NOT NULL,
	status varchar(10) NOT NULL,
	date DATETIME NOT NULL
);


CREATE TABLE train_station(
	id INT PRIMARY KEY AUTO_INCREMENT,
	name VARCHAR(45) NOT NULL,
	state VARCHAR(45) NOT NULL,
	city VARCHAR(45) NOT NULL,
	PIN INT(6) NOT NULL
);


CREATE TABLE train(
	id INT(5) PRIMARY KEY NOT NULL,
	name VARCHAR(45) NOT NULL
);


CREATE TABLE journey_station(
	train_id INT NOT NULL,
	station_id INT NOT NULL,
	stop_order INT NOT NULL,
	distance_from_start DECIMAL(7,2) NOT NULL,
	departure_time DATETIME NOT NULL,
	CONSTRAINT station_fk FOREIGN KEY (station_id) REFERENCES train_station(id),
	CONSTRAINT train_fk FOREIGN KEY (train_id) REFERENCES train(id)
);

CREATE TABLE carriage_class(
	id INT PRIMARY KEY AUTO_INCREMENT,
	class_name CHAR(2) NOT NULL UNIQUE,
	seating_capacity INT NOT NULL,
	distance_price_multiplier DECIMAL(4,2) NOT NULL
);

CREATE TABLE booking(
	ticket_no INT AUTO_INCREMENT PRIMARY KEY,
	passenger_id INT NOT NULL,
	status_id INT NOT NULL,
	starting_station_id INT NOT NULL,
	ending_station_id INT NOT NULL,
	train_id INT(5) NOT NULL,
	ticket_class_id INT NOT NULL,
	transaction_id INT NOT NULL,
	booking_date DATETIME NOT NULL,
	seat_no INT NOT NULL,
	position_number INT(2),
	distance DECIMAL(7,2) NOT NULL,
	journey_date DATE,
	CONSTRAINT passenger_fk FOREIGN KEY (passenger_id) REFERENCES user(id),
	CONSTRAINT status_fk FOREIGN KEY (status_id) REFERENCES booking_status(id),
	CONSTRAINT starting_station_fk FOREIGN KEY (starting_station_id) REFERENCES train_station(id),
	CONSTRAINT ending_station_fk FOREIGN KEY (ending_station_id) REFERENCES train_station(id),
	CONSTRAINT train_id_booking_fk FOREIGN KEY (train_id) REFERENCES train(id),
	CONSTRAINT ticket_class_fk FOREIGN KEY (ticket_class_id) REFERENCES carriage_class(id),
	CONSTRAINT transaction_fk FOREIGN KEY (transaction_id) REFERENCES transaction(id)
);

CREATE TABLE seat_availability (
	id INT PRIMARY KEY AUTO_INCREMENT,
	train_id INT(5) NOT NULL,
	journey_date DATE NOT NULL,
	carriage_class_id INT NOT NULL,
	total_seats INT NOT NULL,
	available_seats INT NOT NULL,
	total_rac_seats INT NOT NULL,
	rac_seats INT NOT NULL,
	total_waiting_list INT NOT NULL,
	waiting_list INT NOT NULL,
	CONSTRAINT sa_train_fk FOREIGN KEY (train_id) REFERENCES train(id),
	CONSTRAINT sa_class_fk FOREIGN KEY (carriage_class_id) REFERENCES carriage_class(id),
	UNIQUE KEY (train_id, journey_date, carriage_class_id)
);

INSERT INTO user(username, password, mob, dob, email, category) VALUES
('srikant', '$2b$12$2u68wWsXpbzuTQ3pyDSWGuQQdCIfD7FD/0OqnRKnUcJBaxDX5NuZa', '9090909090', '2025-05-05', 'srikant@email.com', 'STUDENT'),
('testSTU', '$2b$12$Vd7/YgFfRcXKDca.2jhSXuXQxalvL88U4MuGgP824yAjuo5R8AsIS', '1010101010', '2025-04-04', 'test@email.com', 'STUDENT'),
('testSNR', '$2b$12$U4WO36OzsWuxYbKQJPBWfOCZ8LFbsm.Wz1Wl2AoYsHM6kyc7kodFa', '1010101010', '2025-04-04', 'test@email.com', 'SENIOR CITIZEN'),
('testDIS', '$2b$12$IU0SqCp5DZXW9GPrEE2bGO.a3r27tkqqfuRqOVDMNQbJiJ9IxaaFW', '1010101010', '2025-04-04', 'test@email.com', 'DISABLED'),
('testGEN', '$2b$12$akA15iusj97xuh56uMZUJO4Z2E2ct7KU9ptCTURfcsY.X1VLpFR0e', '1010101010', '2025-04-04', 'test@email.com', 'GENERAL');

INSERT INTO concession VALUES
('STUDENT', 0.50),
('SENIOR CITIZEN', 0.40),
('DISABLED', 0.60),
('GENERAL', 1.00);

INSERT INTO train_station(name, state, city, PIN) VALUES
('Bhubaneswar Railway Station', 'Odisha', 'Bhubaneswar', 751001),
('Cuttack Junc.', 'Odisha', 'Cuttack', 753003),
('Patna Junc.', 'Bihar', 'Patna', 800001),
('Howrah junc.', 'West Bengal', 'Howrah', 711101);

INSERT INTO train(id, name) VALUES
(08439, 'PURI PNBE SPL'),
(18449, 'BAIDYANATH DHAM'),
(22896, 'VANDE BHARAT EXP');

INSERT INTO journey_station(train_id, station_id, stop_order, distance_from_start, departure_time) VALUES
(08439, 1, 1, 0, "2025-04-19 16:15:00"),
(08439, 3, 2, 828, "2025-04-20 10:45:00"),
(18449, 1, 1, 0, "2025-04-21 16:15:00"),
(18449, 3, 2, 828, "2025-04-22 09:35:00"),
(22896, 1, 1, 0, "2025-04-19 14:49:00"),
(22896, 2, 2, 25.7, "2025-04-19 15:17:00"),
(22896, 4, 3, 438, "2025-04-19 20:30:00");

INSERT INTO carriage_class(class_name, seating_capacity, distance_price_multiplier) VALUES
('SL', 40, 0.7),
('3A', 30, 1.2),
('2A', 20, 1.8),
('1A', 10, 2.4);

INSERT INTO booking_status (status) VALUES 
('CONFIRMED'),
('RAC'),
('WL'),
('CANCELLED');

INSERT INTO transaction(amount, method, status, date) VALUES (1100.45, "UPI", "DONE", NOW());


DELIMITER //
CREATE PROCEDURE book_ticket(
	IN p_passenger_id INT,
	IN p_train_id INT,
	IN p_start_station INT,
	IN p_end_station INT,
	IN p_class_id INT,
	IN p_journey_date DATE,
	IN p_transaction_id INT,
	IN p_distance DECIMAL(7,2)
)
BEGIN
	DECLARE v_available_seats INT;
	DECLARE v_rac_seats INT;
	DECLARE v_waiting_list INT;
	DECLARE v_status_id INT;
	DECLARE v_position INT;
	DECLARE v_seat_no INT;
	
	-- Get current availability
	SELECT available_seats, rac_seats, waiting_list 
	INTO v_available_seats, v_rac_seats, v_waiting_list
	FROM seat_availability
	WHERE train_id = p_train_id 
	AND journey_date = p_journey_date
	AND carriage_class_id = p_class_id;
	
	-- Determine booking status
	IF v_available_seats > 0 THEN
		-- Confirmed ticket
		SELECT id INTO v_status_id FROM booking_status WHERE status = 'CONFIRMED';
		SET v_seat_no = (SELECT seating_capacity FROM carriage_class WHERE id = p_class_id) - v_available_seats + 1;
		SET v_position = NULL;
		
		-- Update available seats
		UPDATE seat_availability 
		SET available_seats = available_seats - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND carriage_class_id = p_class_id;
		
	ELSEIF v_rac_seats > 0 THEN
		-- RAC ticket
		SELECT id INTO v_status_id FROM booking_status WHERE status = 'RAC';
		SET v_seat_no = 0; -- RAC doesn't have fixed seat
		SET v_position = (SELECT COUNT(*) FROM booking 
						 WHERE train_id = p_train_id 
						 AND journey_date= p_journey_date
						 AND ticket_class_id = p_class_id
						 AND status_id = v_status_id) + 1;
		
		-- Update RAC count
		UPDATE seat_availability 
		SET rac_seats = rac_seats - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND carriage_class_id = p_class_id;
		
	ELSE
		-- Waiting list ticket
		SELECT id INTO v_status_id FROM booking_status WHERE status = 'WL';
		SET v_seat_no = 0; -- WL doesn't have seat
		SET v_position = (SELECT COUNT(*) FROM booking 
						 WHERE train_id = p_train_id 
						 AND journey_date = p_journey_date
						 AND ticket_class_id = p_class_id
						 AND status_id = v_status_id) + 1;
		
		-- Update waiting list count
		UPDATE seat_availability 
		SET waiting_list = waiting_list - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND carriage_class_id = p_class_id;
	END IF;
	
	-- Create booking
	INSERT INTO booking (
		passenger_id, status_id, starting_station_id, 
		ending_station_id, train_id, ticket_class_id, 
		transaction_id, booking_date, seat_no, position_number, distance, journey_date
	) VALUES (
		p_passenger_id, v_status_id, p_start_station,
		p_end_station, p_train_id, p_class_id,
		p_transaction_id, NOW(), v_seat_no, v_position, p_distance, p_journey_date
	);
	
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE cancel_ticket(IN p_booking_id INT)
BEGIN
	DECLARE v_train_id INT;
	DECLARE v_journey_date DATE;
	DECLARE v_class_id INT;
	DECLARE v_status_id INT;
	DECLARE v_cancelled_status_id INT;
	DECLARE v_seat_no INT;
	DECLARE v_position INT;
	DECLARE v_transaction_id INT;
	
	-- Get booking details
	SELECT train_id, journey_date, ticket_class_id, status_id, seat_no, position_number, transaction_id
	INTO v_train_id, v_journey_date, v_class_id, v_status_id, v_seat_no, v_position, v_transaction_id
	FROM booking WHERE ticket_no = p_booking_id;
	
	UPDATE transaction SET status="REFUND" WHERE id=v_transaction_id;

	SELECT id INTO v_cancelled_status_id FROM booking_status WHERE status = 'CANCELLED';
	
	-- Update booking status to cancelled
	UPDATE booking SET status_id = v_cancelled_status_id WHERE ticket_no = p_booking_id;
	
	-- Handle seat availability based on previous status
	IF (SELECT status FROM booking_status WHERE id = v_status_id) = 'CONFIRMED' THEN
		-- Free up a confirmed seat and upgrade RAC to confirmed if available
		UPDATE seat_availability 
		SET available_seats = available_seats + 1
		WHERE train_id = v_train_id 
		AND journey_date = v_journey_date
		AND carriage_class_id = v_class_id;

		UPDATE booking
		SET seat_no=seat_no-1
		WHERE train_id = v_train_id
		AND journey_date = v_journey_date
		AND ticket_class_id = v_class_id
		AND status_id = v_status_id
		AND seat_no>v_seat_no;
		
		-- Find first RAC ticket to upgrade
		CALL upgrade_rac_to_confirmed(v_train_id, v_journey_date, v_class_id);
		CALL upgrade_wl_to_rac(v_train_id, v_journey_date, v_class_id);
		
	ELSEIF (SELECT status FROM booking_status WHERE id = v_status_id) = 'RAC' THEN
		-- Free up RAC and upgrade WL to RAC if available
		UPDATE seat_availability 
		SET rac_seats = rac_seats + 1
		WHERE train_id = v_train_id 
		AND journey_date = v_journey_date
		AND carriage_class_id = v_class_id;

		UPDATE booking
		SET position_number = position_number -1
		WHERE train_id = v_train_id
		AND journey_date = v_journey_date
		AND status_id = v_status_id
		AND position_number > v_position;
		
		-- Find first WL ticket to upgrade
		CALL upgrade_wl_to_rac(v_train_id, v_journey_date, v_class_id);
		
	ELSEIF (SELECT status FROM booking_status WHERE id = v_status_id) = 'WL' THEN
		-- Free up waiting list
		UPDATE seat_availability 
		SET waiting_list = waiting_list + 1
		WHERE train_id = v_train_id 
		AND journey_date = v_journey_date
		AND carriage_class_id = v_class_id;


		SELECT position_number INTO v_position FROM booking WHERE ticket_no = p_booking_id;
		-- Update positions of remaining WL tickets
		UPDATE booking 
		SET position_number = position_number - 1
		WHERE train_id = v_train_id 
		AND journey_date = v_journey_date
		AND ticket_class_id = v_class_id
		AND status_id = (SELECT id FROM booking_status WHERE status = 'WL')
		AND position_number > v_position;
	END IF;
END //
DELIMITER ;

-- Procedure to upgrade RAC to confirmed
DELIMITER //
CREATE PROCEDURE upgrade_rac_to_confirmed(
	IN p_train_id INT,
	IN p_journey_date DATE,
	IN p_class_id INT
)
BEGIN
	DECLARE v_rac_status_id INT;
	DECLARE v_confirmed_status_id INT;
	DECLARE v_booking_id INT;
	DECLARE v_position INT;
	DECLARE v_seat_no INT;
	
	SELECT id INTO v_rac_status_id FROM booking_status WHERE status = 'RAC';
	SELECT id INTO v_confirmed_status_id FROM booking_status WHERE status = 'CONFIRMED';
	
	-- Find first RAC ticket
	SELECT ticket_no INTO v_booking_id
	FROM booking
	WHERE train_id = p_train_id 
	AND journey_date = p_journey_date
	AND ticket_class_id = p_class_id
	AND status_id = v_rac_status_id
	ORDER BY position_number
	LIMIT 1;
	
	IF v_booking_id IS NOT NULL THEN

		SELECT (seating_capacity - available_seats + 1) INTO v_seat_no
        FROM carriage_class c
        JOIN seat_availability sa ON c.id = sa.carriage_class_id
        WHERE sa.train_id = p_train_id 
        AND sa.journey_date = p_journey_date
        AND sa.carriage_class_id = p_class_id;

		-- SELECT IFNULL(position_number, 0) INTO v_position FROM booking WHERE ticket_no = v_booking_id;
		
		
		-- Update RAC positions
		UPDATE booking 
		SET position_number = position_number - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND ticket_class_id = p_class_id
		AND status_id = v_rac_status_id;
		-- AND position_number > v_position;


		-- Upgrade RAC to confirmed
		UPDATE booking
		SET status_id = v_confirmed_status_id,
			seat_no = v_seat_no,
			position_number = NULL
		WHERE ticket_no = v_booking_id;
		
		-- Update seat availability
		UPDATE seat_availability 
		SET rac_seats = rac_seats + 1,
			available_seats = available_seats - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND carriage_class_id = p_class_id;
		
		-- Check if we need to upgrade a WL to RAC
		-- CALL upgrade_wl_to_rac(p_train_id, p_journey_date, p_class_id);
	END IF;
END //
DELIMITER ;

-- Procedure to upgrade WL to RAC
DELIMITER //
CREATE PROCEDURE upgrade_wl_to_rac(
	IN p_train_id INT,
	IN p_journey_date DATE,
	IN p_class_id INT
)
BEGIN
	DECLARE v_wl_status_id INT;
	DECLARE v_rac_status_id INT;
	DECLARE v_booking_id INT;
	DECLARE v_position INT;

	SELECT id INTO v_wl_status_id FROM booking_status WHERE status = 'WL';
	SELECT id INTO v_rac_status_id FROM booking_status WHERE status = 'RAC';
	
	-- Find first WL ticket
	SELECT ticket_no INTO v_booking_id
	FROM booking
	WHERE train_id = p_train_id 
	AND journey_date = p_journey_date
	AND ticket_class_id = p_class_id
	AND status_id = v_wl_status_id
	ORDER BY position_number
	LIMIT 1;
	
	IF v_booking_id IS NOT NULL THEN
		-- Upgrade WL to RAC
		SELECT (MAX(position_number) + 1) INTO v_position
		FROM booking
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND ticket_class_id = p_class_id
		AND status_id = v_rac_status_id;


		UPDATE booking
		SET status_id = v_rac_status_id,
			position_number = v_position
		WHERE ticket_no = v_booking_id;

		-- SELECT IFNULL(position_number, 0) INTO v_position FROM booking WHERE ticket_no = v_booking_id;
		
		-- Update WL positions
		UPDATE booking 
		SET position_number = position_number - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND ticket_class_id = p_class_id
		AND status_id = v_wl_status_id;
		
		-- Update seat availability
		UPDATE seat_availability 
		SET waiting_list = waiting_list + 1,
			rac_seats = rac_seats - 1
		WHERE train_id = p_train_id 
		AND journey_date = p_journey_date
		AND carriage_class_id = p_class_id;
	END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE initialize_seat_availability(
	IN p_train_id INT,
	IN p_journey_date DATE,
	IN p_class_id INT,
	IN p_rac_quota INT,
	IN p_waiting_list_quota INT
)
BEGIN
	DECLARE v_total_seats INT;
	
	-- Get total seats for the class
	SELECT seating_capacity INTO v_total_seats
	FROM carriage_class
	WHERE id = p_class_id;
	
	-- Insert or update seat availability
	INSERT INTO seat_availability (
		train_id, journey_date, carriage_class_id, 
		total_seats, available_seats, total_rac_seats, rac_seats, total_waiting_list, waiting_list
	) VALUES (
		p_train_id, p_journey_date, p_class_id,
		v_total_seats, v_total_seats, p_rac_quota, p_rac_quota, p_waiting_list_quota, p_waiting_list_quota
	)
	ON DUPLICATE KEY UPDATE
		total_seats = v_total_seats,
		available_seats = v_total_seats,
		rac_seats = p_rac_quota,
		waiting_list = p_waiting_list_quota;
END //
DELIMITER ;



CALL initialize_seat_availability(22896, "2025-04-19 14:49:00", 1, 20, 100);
CALL initialize_seat_availability(22896, "2025-04-19 14:49:00", 2, 20, 100);
CALL initialize_seat_availability(22896, "2025-04-19 14:49:00", 3, 10, 100);
CALL initialize_seat_availability(22896, "2025-04-19 14:49:00", 4, 10, 100);
CALL book_ticket(1,22896, 2, 4, 2, "2025-04-19 14:49:00", 1, 100);
CALL book_ticket(1,22896, 1, 4, 2, "2025-04-19 14:49:00", 1, 100);



--  ██████╗ ██╗   ██╗███████╗██████╗ ██╗███████╗███████╗
-- ██╔═══██╗██║   ██║██╔════╝██╔══██╗██║██╔════╝██╔════╝
-- ██║   ██║██║   ██║█████╗  ██████╔╝██║█████╗  ███████╗
-- ██║▄▄ ██║██║   ██║██╔══╝  ██╔══██╗██║██╔══╝  ╚════██║
-- ╚██████╔╝╚██████╔╝███████╗██║  ██║██║███████╗███████║
--  ╚══▀▀═╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝

-- Query for journey
SELECT t.id, t.name, js1.departure_time as Departure_Time, js2.departure_time as Arrival_Time, (js2.distance_from_start-js1.distance_from_start) as Distance
FROM train t
JOIN journey_station js1 ON t.id = js1.train_id
JOIN journey_station js2 ON t.id = js2.train_id
JOIN train_station ts1 ON js1.station_id = ts1.id
JOIN train_station ts2 ON js2.station_id = ts2.id
WHERE ts1.id = 2
AND ts2.id = 4
AND js1.departure_time > "2025-04-19 00:00:00"
AND js1.stop_order < js2.stop_order
ORDER BY js1.departure_time;



-- Query for user's bookings
SELECT ticket_no, status_id, starting_station_id, ending_station_id, train_id, ticket_class_id, transaction_id, booking_date, seat_no, position_number, distance, journey_date
FROM booking
WHERE passenger_id = 1;




                                                     


-- Query for PNR tracking using ticket_no
SELECT
    b.ticket_no,
    u.username AS passenger_name,
    u.category AS passenger_category,
    ts.name AS start_station,
    te.name AS end_station,
    tr.name AS train_name,
    cc.class_name AS ticket_class,
    b.seat_no,
    b.position_number,
    bs.status AS booking_status,
    b.booking_date,
    b.journey_date,
    b.distance,
    t.amount AS paid_amount,
    t.status AS transaction_status
FROM
    booking b
JOIN user u ON b.passenger_id = u.id
JOIN booking_status bs ON b.status_id = bs.id
JOIN train_station ts ON b.starting_station_id = ts.id
JOIN train_station te ON b.ending_station_id = te.id
JOIN train tr ON b.train_id = tr.id
JOIN carriage_class cc ON b.ticket_class_id = cc.id
JOIN transaction t ON b.transaction_id = t.id
WHERE
    b.ticket_no = 2;

-- Query for train schedule lookup
SELECT
    js.stop_order,
    ts.name AS station_name,
    ts.city,
    ts.state,
    js.distance_from_start,
    js.departure_time
FROM
    journey_station js
JOIN train_station ts ON js.station_id = ts.id
WHERE
    js.train_id =  22896
ORDER BY
    js.stop_order;

-- Query for Available seats query for a specific train, date and class.
SELECT
    sa.available_seats,
    sa.rac_seats,
    sa.waiting_list,
    sa.total_seats,
    sa.total_rac_seats,
    sa.total_waiting_list
FROM
    seat_availability sa
WHERE
    sa.train_id = 22896
    AND sa.journey_date = '2025-04-19'
    AND sa.carriage_class_id = 1;

-- Query for Listing all passengers traveling on a specific train on a given date.
SELECT
    b.ticket_no,
    u.username AS passenger_name,
    u.email,
    u.mob AS mobile,
    u.category AS passenger_category,
    ts_start.name AS starting_station,
    ts_end.name AS ending_station,
    cc.class_name AS ticket_class,
    b.seat_no,
    bs.status AS booking_status,
    b.booking_date,
    b.journey_date
FROM
    booking b
JOIN user u ON b.passenger_id = u.id
JOIN train_station ts_start ON b.starting_station_id = ts_start.id
JOIN train_station ts_end ON b.ending_station_id = ts_end.id
JOIN carriage_class cc ON b.ticket_class_id = cc.id
JOIN booking_status bs ON b.status_id = bs.id
WHERE
    b.train_id = 22896
    AND b.journey_date = '2025-04-19'
ORDER BY
    b.seat_no;

-- Query for Retrieving all waitlisted passengers for a particular train.
SELECT
    b.ticket_no,
    u.username AS passenger_name,
    u.email,
    u.mob AS mobile,
    u.category AS passenger_category,
    ts_start.name AS starting_station,
    ts_end.name AS ending_station,
    cc.class_name AS ticket_class,
    b.position_number AS waiting_position,
    b.journey_date,
    b.booking_date
FROM
    booking b
JOIN user u ON b.passenger_id = u.id
JOIN train_station ts_start ON b.starting_station_id = ts_start.id
JOIN train_station ts_end ON b.ending_station_id = ts_end.id
JOIN carriage_class cc ON b.ticket_class_id = cc.id
JOIN booking_status bs ON b.status_id = bs.id
WHERE
    b.train_id = 22896
    AND bs.status = 'WL'
ORDER BY
    b.journey_date, b.position_number;

-- Query for Finding total amount that needs to be refunded for cancelling a train.
SELECT
    SUM(t.amount) AS total_refund_amount
FROM
    booking b
JOIN transaction t ON b.transaction_id = t.id
JOIN booking_status bs ON b.status_id = bs.id
WHERE
    b.train_id = 22896
    AND b.journey_date = '2025-04-19'
    AND t.status = 'DONE';

-- Query for Total revenue generated from ticket bookings over a specified period.
SELECT
    SUM(t.amount) AS total_revenue
FROM
    transaction t
WHERE
    t.status = 'DONE'
    AND DATE(t.date) BETWEEN '2025-04-16' AND '2025-04-17';

-- Query for Cancellation of records with refund status.
SELECT
    b.ticket_no,
    u.username AS passenger_name,
    tr.name AS train_name,
    b.journey_date,
    t.amount AS paid_amount,
    t.status AS transaction_status,
    bs.status AS booking_status,
    t.date AS transaction_date
FROM
    booking b
JOIN user u ON b.passenger_id = u.id
JOIN train tr ON b.train_id = tr.id
JOIN transaction t ON b.transaction_id = t.id
JOIN booking_status bs ON b.status_id = bs.id
WHERE
    bs.status = 'CANCELLED';

-- Query for Finding the busiest route based on passenger count.
SELECT
    ts_start.name AS starting_station,
    ts_end.name AS ending_station,
    COUNT(*) AS passenger_count
FROM
    booking b
JOIN train_station ts_start ON b.starting_station_id = ts_start.id
JOIN train_station ts_end ON b.ending_station_id = ts_end.id
GROUP BY
    b.starting_station_id,
    b.ending_station_id
ORDER BY
    passenger_count DESC
LIMIT 1;

-- Query for Generating an itemized bill for a ticket including all charges.
SELECT
    b.ticket_no,
    u.username AS passenger_name,
    u.category AS passenger_category,
    tr.name AS train_name,
    cc.class_name,
    b.distance,
    cc.distance_price_multiplier,
    (b.distance * cc.distance_price_multiplier) AS base_fare,
    c.concession,
    ROUND((b.distance * cc.distance_price_multiplier) * (1 - c.concession), 2) AS discounted_fare,
    t.amount AS final_paid,
    t.status AS payment_status,
    b.journey_date
FROM
    booking b
JOIN user u ON b.passenger_id = u.id
JOIN train tr ON b.train_id = tr.id
JOIN carriage_class cc ON b.ticket_class_id = cc.id
JOIN concession c ON u.category = c.category
JOIN transaction t ON b.transaction_id = t.id
WHERE
    b.ticket_no = 66;
