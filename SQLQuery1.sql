CREATE DATABASE QLKH

USE QLKH

CREATE TABLE GiangVien(
	GV char(4) NOT NULL,
	HoTen varchar(20) NOT NULL,
	DiaChi varchar(30) NOT NULL,
	NgaySinh char(10) NOT NULL,
	CONSTRAINT MAINKEYGV primary key(GV)
);

CREATE TABLE DeTai(
	DT char(4) NOT NULL,
	TenDT varchar(30) NOT NULL,
	Cap varchar(10) NOT NULL,
	KinhPhi smallint NOT NULL,
	CONSTRAINT MAINKEYDT primary key(DT)
);

CREATE TABLE ThamGia(
	GV char(4) NOT NULL,
	DT char(4) NOT NULL,
	SoGio smallint NOT NULL,
	primary key(GV, DT),
	foreign key(GV) references GiangVien(GV),
	foreign key(DT) references DeTai(DT),
	check(SoGio > 0)
);
use QLKH
--1.	Đưa ra thông tin giảng viên có địa chỉ ở quận “Hai Bà Trưng”, sắp xếp theo thứ tự giảm dần của họ tên.
SELECT * FROM GiangVien
WHERE DiaChi LIKE 'Hai Bà Trưng%'

--2.	Đưa ra danh sách gồm họ tên, địa chỉ, ngày sinh của giảng viên có tham gia vào đề tài “Tính toán lưới”.
SELECT HoTen, DiaChi, NgaySinh
FROM GiangVien AS A, ThamGia AS B, DeTai AS C
WHERE A.GV = B.GV AND B.DT = C.DT AND C.TenDT LIKE 'Tính toán lưới'

SELECT Hoten, DiaChi, NgaySinh, TenDT
FROM ((GiangVien INNER JOIN ThamGia ON GiangVien.GV = ThamGia.GV)
	             INNER JOIN DeTai ON ThamGia.DT = DeTai.DT)
WHERE TenDT LIKE 'Tính toán lưới'

--3.	Đưa ra danh sách gồm họ tên, địa chỉ, ngày sinh của giảng viên có tham gia vào đề tài “Phân loại văn bản” hoặc “Dịch tự động Anh Việt”.
SELECT HoTen, DiaChi, NgaySinh
FROM GiangVien AS A, ThamGia AS B, DeTai AS C
WHERE A.GV = B.GV AND B.DT = C.DT AND (C.TenDT LIKE 'Phân loại văn bản' OR C.TenDT LIKE 'Dịch tự động Anh Việt')

SELECT Hoten, DiaChi, NgaySinh, TenDT
FROM ((GiangVien INNER JOIN ThamGia ON GiangVien.GV = ThamGia.GV)
	             INNER JOIN DeTai ON ThamGia.DT = DeTai.DT)
WHERE TenDT LIKE 'Phân loại văn bản' OR TenDT LIKE 'Dịch tự động Anh Việt'

--4.	Cho biết thông tin giảng viên tham gia ít nhất 2 đề tài.
SELECT GiangVien.GV, HoTen, DiaChi, NgaySinh, COUNT(DT)
FROM GiangVien LEFT OUTER JOIN ThamGia ON GiangVien.GV = ThamGia.GV
GROUP BY GiangVien.GV, HoTen, DiaChi, NgaySinh
HAVING COUNT(DT) >= 2

--5.	Cho biết tên giảng viên tham gia nhiều đề tài nhất. 
--@ HIEU
SELECT *
FROM ( SELECT GiangVien.GV, HoTen, NgaySinh, DiaChi, COUNT(DT) AS NUMBER
	   FROM GiangVien LEFT OUTER JOIN ThamGia ON GiangVien.GV = ThamGia.GV
	   GROUP BY GiangVien.GV, HoTen, NgaySinh, DiaChi ) AS A
WHERE A.NUMBER >= ALL(SELECT B.NUMBER FROM (SELECT GiangVien.GV, HoTen, NgaySinh, DiaChi, COUNT(DT) AS NUMBER
											  FROM GiangVien LEFT OUTER JOIN ThamGia ON GiangVien.GV = ThamGia.GV
											  GROUP BY GiangVien.GV, HoTen, NgaySinh, DiaChi) AS B)

--@LINH
SELECT *
FROM GiangVien
where GV =(SELECT A.GV
FROM (SELECT GV, COUNT(DT) AS NUMBER 
	  FROM Thamgia 
      GROUP BY GV) AS A
WHERE A.NUMBER >= ALL(SELECT NUMBER FROM (SELECT GV, COUNT(DT) AS NUMBER 
										  FROM ThamGia
										  GROUP BY GV) AS B) )



--6.	Đề tài nào tốn ít kinh phí nhất?
SELECT DT, TenDT, Cap
FROM DeTai
WHERE KinhPhi <= ALL(SELECT KinhPhi FROM DeTai)

--7.	Cho biết tên và ngày sinh của giảng viên sống ở quận Tây Hồ và tên các đề tài mà giảng viên này tham gia
SELECT HoTen, DiaChi, NgaySinh, TenDT
FROM (GiangVien LEFT OUTER JOIN ThamGia ON GiangVien.GV = ThamGia.GV)
	  LEFT OUTER JOIN DeTai ON ThamGia.DT = DeTai.DT 
WHERE DiaChi LIKE 'Tây Hồ%'

--8.	Cho biết tên những giảng viên sinh trước năm 1980 và có tham gia đề tài “Phân loại văn bản”
ALTER TABLE GiangVien
ALTER COLUMN NgaySinh DATE


SELECT HoTen
FROM (GiangVien LEFT OUTER JOIN ThamGia ON GiangVien.GV = ThamGia.GV)
	  LEFT OUTER JOIN DeTai ON ThamGia.DT = DeTai.DT 
WHERE NgaySinh <= CONVERT(DATE,'1980/01/01') AND TenDT ='Tính toán lưới'

--9.	Đưa ra mã giảng viên, tên giảng viên và tổng số giờ tham gia nghiên cứu khoa học của từng giảng viên.
SELECT GiangVien.GV, HoTen, SUM(SoGio)
FROM GiangVien LEFT OUTER JOIN ThamGia ON GiangVien.GV = ThamGia.GV
GROUP BY GiangVien.GV, HoTen

--10.	Giảng viên Ngô Tuấn Phong sinh ngày 08/09/1986 địa chỉ Đống Đa, Hà Nội mới tham gia nghiên cứu đề tài khoa học. Hãy thêm thông tin giảng viên này vào bảng GiangVien.
INSERT INTO GiangVien (GV, HoTen, DiaCHi, NgaySinh)
VALUES ('GV07', 'Ngô Tuấn Phong','Đống Đa, Hà Nội', '08/09/1980')

--11.	Giảng viên Vũ Tuyết Trinh mới chuyển về sống tại quận Tây Hồ, Hà Nội. Hãy cập nhật thông tin này.
UPDATE GiangVien
SET DiaChi = 'Tây Hồ, Hà Nội'
WHERE HoTen = 'Vũ Tuyết Trinh'

--12.	Giảng viên có mã GV02 không tham gia bất kỳ đề tài nào nữa. Hãy xóa tất cả thông tin liên quan đến giảng viên này trong CSDL.
ALTER TABLE ThamGia
ADD CONSTRAINT SECONDKEY FOREIGN KEY(GV) REFERENCES GiangVien(GV)
ON DELETE CASCADE

DELETE FROM GiangVien
WHERE GV = 'GV02'




