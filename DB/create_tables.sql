CREATE SEQUENCE seq_supplier
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Supplier ( -- Поставщик (Const)
  id NUMERIC(8) NOT NULL,
  enterprise_name VARCHAR2(64) NOT NULL UNIQUE, -- Название предприятия
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_contractor 
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Contractor ( -- Контрагент (Const)
  id NUMERIC(8) NOT NULL,
  surname VARCHAR2(32) NOT NULL, -- Фамилия
  forename VARCHAR2(32) NOT NULL, -- Имя
  patronymic VARCHAR2(32) NULL, -- Отчество
  callback_phone_number VARCHAR2(16) NOT NULL, -- Контактный номер телефона
  supplier_id NUMERIC(8) NOT NULL, -- id поставщик
  --
  PRIMARY KEY(id),
  FOREIGN KEY(supplier_id)
    REFERENCES Supplier(id)
);

CREATE SEQUENCE seq_storage_condition 
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Storage_condition ( -- Условие хранения товара (Const)
  id NUMERIC(2) NOT NULL,
  name VARCHAR2(32) NOT NULL UNIQUE, -- Наименование
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_writeoff_cause
  START WITH 1 INCREMENT BY 1;
CREATE TABLE WriteOff_cause ( -- Причина списания товара (Const)
  id NUMERIC(2) NOT NULL,
  name VARCHAR2(64) NOT NULL UNIQUE, -- Наименование
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_operation_type
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Operation_type ( -- Тип операции (Const)
  id NUMERIC(1) NOT NULL,
  name VARCHAR2(16) NOT NULL, -- Наименование
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_goods_type
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Goods_type ( -- Тип товара (Const)
  id NUMERIC(3) NOT NULL,
  name VARCHAR2(64) NOT NULL, -- Наименование
  storage_condition_id NUMERIC(2) NOT NULL,
  --
  PRIMARY KEY(id),
  FOREIGN KEY(storage_condition_id)
    REFERENCES Storage_condition(id)
);

CREATE SEQUENCE seq_job
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Job ( -- Должность (Const)
  id NUMERIC(4) NOT NULL,
  name VARCHAR2(64) NOT NULL, -- Наименование
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_division_of_the_company
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Division_of_the_company ( -- Подразделение компании (Const)
  id NUMERIC(4) NOT NULL,
  name VARCHAR2(128) NOT NULL, -- Наименование
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_system_role
  START WITH 1 INCREMENT BY 1;
CREATE TABLE System_role ( -- Роль в информационной системе компании (Const)
  id NUMERIC(3) NOT NULL,
  name VARCHAR2(32) NOT NULL,
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_country
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Country ( -- Страна (Const)
  id NUMERIC(3) NOT NULL,
  name VARCHAR2(128) NOT NULL UNIQUE, -- Название
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_producer
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Producer ( -- Производитель (Const)
  id NUMERIC(7) NOT NULL,
  name VARCHAR2(128) NOT NULL, -- Наименование компании производителя
  country_id NUMERIC(3) NOT NULL, -- Страна производитель
  code NUMERIC(4) NOT NULL, -- Значение штрих-кода компании производителя
  --
  PRIMARY KEY(id),
  FOREIGN KEY(country_id)
    REFERENCES Country(id)
);

CREATE SEQUENCE seq_goods
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Goods ( -- Товар (Const)
  id NUMERIC(8) NOT NULL,
  name VARCHAR2(64) NOT NULL, -- Наименование
  type_id NUMERIC(3) NOT NULL, -- id типа
  shelf_life INTERVAL DAY (3) TO SECOND NOT NULL, -- Технический срок годности (количество времени с момента производства до пропажи)
  producer_id NUMERIC(7) NOT NULL, -- id производителя
  sizes VARCHAR2(32) NULL, -- Размеры
  unit_of_measurement VARCHAR(16) NOT NULL, -- Единица измерения количества
  code NUMERIC(5) NOT NULL, -- Значение штрих-кода
  --
  PRIMARY KEY(id),
  FOREIGN KEY(type_id)
    REFERENCES Goods_type(id),
  FOREIGN KEY(producer_id)
    REFERENCES Producer(id)
);

CREATE SEQUENCE seq_truck
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Truck ( -- Грузовик компании (Const)
  id NUMERIC(8) NOT NULL,
  plate VARCHAR2(8) NOT NULL, -- Автомобильный номер
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_staff_member
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Staff_member ( -- Сотрудник (Const)
  id NUMERIC(6) NOT NULL,
  surname VARCHAR2(32) NOT NULL, -- Фамилия
  forename VARCHAR2(32) NOT NULL, -- Имя
  patronymic VARCHAR2(32) NULL, -- Отчество
  passport_number NUMERIC(10) NOT NULL, -- Номер российского пасспорта
  birthday DATE NOT NULL, -- День рождения
  job_id NUMERIC(4) NOT NULL, -- id должность
  division_of_the_company_id NUMERIC(4) NOT NULL, -- id подразделение компании
  login VARCHAR(16) NOT NULL, -- Логин в ИС компании
  password VARCHAR(16) NOT NULL, -- Пароль в ИС компании
  system_role_id NUMERIC(3) NOT NULL, -- id роль в ИС
	business_phone_number VARCHAR(16) NOT NULL, -- Рабочий телефонный номер
  private_phone_number VARCHAR(16) NULL, -- Личный телефонный номер
  email VARCHAR(64) NULL, -- Электронная почта
  --
  PRIMARY KEY(id),
  FOREIGN KEY(job_id)
    REFERENCES Job(id),
  FOREIGN KEY(division_of_the_company_id)
    REFERENCES Division_of_the_company(id),
  FOREIGN KEY(system_role_id)
    REFERENCES System_role(id)
);

CREATE SEQUENCE seq_place_of_storage
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Place_of_storage ( -- Место хранения (Const)
  id NUMERIC(2) NOT NULL,
  name VARCHAR(16) NOT NULL, -- Наименование
  --
  PRIMARY KEY(id)
);

CREATE SEQUENCE seq_shelf
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Shelf ( -- "Полка" для хранения товара
  id NUMERIC(4) NOT NULL,
  place_of_storage_id NUMERIC(2), -- id место хранения
  storage_condition_id NUMERIC(2) NOT NULL, -- id условие хранения
  number_of_places NUMERIC(4) NOT NULL, -- количество мест
  --
  PRIMARY KEY(id),
  FOREIGN KEY(storage_condition_id)
    REFERENCES Storage_condition(id),
  FOREIGN KEY(place_of_storage_id)
    REFERENCES Place_of_storage(id)
);

CREATE SEQUENCE seq_delivery_contract
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Delivery_contract ( -- Договор на поставку товара
  id NUMERIC(4) NOT NULL,
  supplier_id NUMERIC(8) NOT NULL, -- id поставщик
  delivery_date DATE NOT NULL, -- Дата поставки
  --
  PRIMARY KEY(id),
  FOREIGN KEY(supplier_id)
    REFERENCES Supplier(id)
);

CREATE TABLE Delivery_contract_and_goods ( -- Договоры на поставку и товары в них
  delivery_contract_id NUMERIC(4) NOT NULL, -- id договор на поставку
  goods_id NUMERIC(8) NOT NULL, -- id товар
  goods_number NUMERIC(8) NOT NULL, -- Количество заказанных в договоре единиц товара
  --
  PRIMARY KEY(delivery_contract_id, goods_id),
  FOREIGN KEY(delivery_contract_id)
    REFERENCES Delivery_contract(id),
  FOREIGN KEY(goods_id)
    REFERENCES Goods(id)
);

CREATE SEQUENCE seq_parcel
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Parcel ( -- Партия товара
  id NUMERIC(16) NOT NULL,
  delivery_contract_id NUMERIC(4) NULL, -- id договор на поставку
  goods_id NUMERIC(8) NOT NULL, -- id Товар партии
  loss_date DATE NOT NULL, -- Дата пропажи
  truck_id NUMERIC(8) NULL, -- id грузовика-перевозщика
  goods_number NUMERIC(4) NOT NULL,
  --
  PRIMARY KEY(id),
  FOREIGN KEY(delivery_contract_id)
    REFERENCES Delivery_contract(id),
  FOREIGN KEY(goods_id)
    REFERENCES Goods(id),
  FOREIGN KEY(truck_id)
    REFERENCES Truck(id)
);

CREATE SEQUENCE seq_operation
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Operation ( -- Операция движения товаров
  id NUMERIC(32) NOT NULL,
  type_id NUMERIC(1) NOT NULL, -- Тип
  exectuer_id NUMERIC(6) NOT NULL, -- id проводящий операцию
  executing_date DATE NOT NULL, -- Дата проведения
  shelf_id NUMERIC(4) NULL, -- id полка
  --
  PRIMARY KEY(id),
  FOREIGN KEY(type_id)
    REFERENCES Operation_type(id),
  FOREIGN KEY(exectuer_id)
    REFERENCES Staff_member(id),
  FOREIGN KEY(shelf_id)
    REFERENCES Shelf(id)
);

CREATE TABLE Operation_and_parcel ( -- Движение партий в операции
  operation_id NUMERIC(32) NOT NULL, -- Операция
  parcel_id NUMERIC(16) NOT NULL, -- Партия
  goods_number NUMERIC(8) NOT NULL, -- Количество единиц товара партии
  --
  PRIMARY KEY(operation_id, parcel_id),
  FOREIGN KEY(operation_id)
    REFERENCES Operation(id),
  FOREIGN KEY(parcel_id)
    REFERENCES Parcel(id)
);

CREATE SEQUENCE seq_writeoff
  START WITH 1 INCREMENT BY 1;
CREATE TABLE WriteOff ( -- Списание товара
  id NUMERIC(32) NOT NULL,
  cause_id NUMERIC(2) NOT NULL, -- Причина
  shelf_id NUMERIC(2) NULL, -- "Полка" хранения товара
  executer_id NUMERIC(6) NOT NULL, -- Проводящий списание
  executing_date DATE NOT NULL, -- Дата списания
  commentary VARCHAR(128) NOT NULL, -- Комментарий
  --
  PRIMARY KEY(id),
  FOREIGN KEY(cause_id)
    REFERENCES WriteOff_cause(id),
  FOREIGN KEY(shelf_id)
    REFERENCES Shelf(id),
  FOREIGN KEY(executer_id)
    REFERENCES Staff_member(id)
);

CREATE TABLE WritedOff_and_parcel ( -- Списание и списанные в них партии
  writeOff_id NUMERIC(32) NOT NULL, -- id списание
  parcel_id NUMERIC(16) NOT NULL, -- Партия
  parcel_number NUMERIC(8) NOT NULL, -- Количество списанных единиц партии
  --
  PRIMARY KEY(writeOff_id, parcel_id),
  FOREIGN KEY(writeOff_id)
    REFERENCES WriteOff(id),
  FOREIGN KEY(parcel_id)
    REFERENCES Parcel(id)
);

CREATE SEQUENCE seq_stocktaking
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Stocktaking ( -- Инвентаризация
  id NUMERIC(6) NOT NULL,
  executer_id NUMERIC(6) NOT NULL, -- Проводящий
  executing_date DATE NOT NULL, -- Дата инвентаризации
  --
  PRIMARY KEY(id),
  FOREIGN KEY(executer_id)
    REFERENCES Staff_member(id)
);

CREATE SEQUENCE seq_stocktaking_parcel
  START WITH 1 INCREMENT BY 1;
CREATE TABLE Stocktaking_parcel ( -- Инвентаризация и её партии
  id NUMERIC(32) NOT NULL,
  stocktaking_id NUMERIC(6) NOT NULL, -- Инвентаризация
  parcel_id NUMERIC(16) NOT NULL, -- Инвентаризованная партия
  stock NUMERIC(8) NOT NULL, -- Остаток партии (количество)
  --
  PRIMARY KEY(id),
  FOREIGN KEY(stocktaking_id)
    REFERENCES Stocktaking(id),
  FOREIGN KEY(parcel_id)
    REFERENCES Parcel(id)
);


CREATE TABLE Parcel_User (
  goods_name VARCHAR2(64),
  supplier_name VARCHAR2(64),
  truck_plate VARCHAR2(64),
  goods_loss_date DATE,
  goods_number NUMERIC
);
CREATE OR REPLACE VIEW Parcel_View AS SELECT * FROM Parcel_User;

CREATE TABLE Problematic_Parcel (
  parcel_id NUMERIC,
  status VARCHAR2(64),
  is_accepted NUMERIC(1) NULL
);

CREATE OR REPLACE VIEW Parcel_from_S_to_TZ AS
  SELECT SS.id AS SSid, STZ.id AS STZid, P.id AS parcel_id, P.goods_number
  FROM Shelf SS, Shelf STZ, Parcel P
  WHERE (SS.place_of_storage_id=3 AND STZ.place_of_storage_id=4);

CREATE OR REPLACE VIEW WriteOff_view AS
  SELECT WO.shelf_id, WOaP.parcel_id, WOaP.parcel_number, WO.cause_id, WO.commentary
  FROM WriteOff WO, WritedOff_and_parcel WOaP;
CREATE OR REPLACE VIEW Parcel_from AS
  SELECT S.id AS shelf_id, P.id AS parcel_id, P.goods_number
  FROM Shelf S, Parcel P;
  