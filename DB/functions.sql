-- БП1.
CREATE OR REPLACE PACKAGE exam AS

    TYPE checkGoods_record IS RECORD (
        status VARCHAR2(32) NOT NULL := 'OK',
        goods_loss_date DATE NULL
        );

    TYPE checkGoods_table IS TABLE OF checkGoods_record;

    -- Проверка товара на наличие в БД;
    -- Вычисление даты пропажи товара на основе даты создания.
    FUNCTION checkGoods(goods_name VARCHAR2, goods_production_date DATE)
        RETURN checkGoods_table                                          
        PIPELINED;

END;

CREATE OR REPLACE PACKAGE BODY exam AS

    FUNCTION checkGoods(goods_name VARCHAR2, goods_production_date DATE)
        RETURN checkGoods_table
        PIPELINED IS
        rec            checkGoods_record;
        
        shelf_life INTERVAL DAY (3) TO SECOND;
        cursor c_shelf_life IS SELECT shelf_life FROM Goods WHERE name=goods_name;
        status VARCHAR(32) NOT NULL := 'OK';
        goods_loss_date DATE NULL;
    BEGIN
        open c_shelf_life;
        fetch c_shelf_life into shelf_life;
        IF c_shelf_life%notfound THEN
            status := 'Goods was not found';
            goods_loss_date := NULL;
        ELSE 
            goods_loss_date := goods_production_date + shelf_life;
            IF goods_loss_date < SYSDATE - INTERVAL '3 0:00:00' DAY TO SECOND THEN
                status := 'It is losing!';
            END IF;
        END IF;        
        
        CLOSE c_shelf_life;
    
        SELECT status, goods_loss_date
          INTO rec
          FROM DUAL;

        -- you would usually have a cursor and a loop here   
        PIPE ROW (rec);

        RETURN;
    END checkGoods;
END;

SELECT * FROM table(exam.fillParcel('Мясо куриное', TO_DATE('10-01-01','DD-MM-YY')));

SELECT * FROM table(exam.fillParcel('Мясо куриное', 'АГРОМИКС', 'A111AA01', TO_DATE('10-01-23','DD-MM-YY'), 23));
-- Информация о товарах из партий, привезённых сегодня
SELECT G.name as Goods_name, GT.name as Goods_type, G.shelf_life, DCaG.goods_number, DC.delivery_date, S.enterprise_name
FROM Goods G, Delivery_contract_and_goods DCaG, Delivery_contract DC, Goods_type GT, Supplier S
WHERE (G.id=DCaG.goods_id AND DCAG.delivery_contract_id=DC.id AND TO_DATE(DC.delivery_date,'DD-MON-YYYY')=TO_DATE(SYSDATE,'DD-MON-YYYY') AND G.type_id=GT.id AND DC.supplier_id=S.id);

БП1 -> Подготовка к созданию партий
БП2 -> Создание партий с принятыми товарами и распределение их по складу; отмена непринятых товаров

Распределяем по складу Партии, которые были приняты Товароведом (ОК и Не ОК принятые ГК)
Что нужно? Результат 1 БП, id полки
INSERT INTO Parcel VALUES (
            seq_parcel.nextval,
            ?delivery_contract_id,
            ?goods_id,
            TO_DATE(?goods_loss_date, "dd-mm-yy"),
            ?truck_id,
            ?goods_number
            );

CREATE OR REPLACE TRIGGER ParcelToStorage_onCreate AFTER INSERT ON Parcel FOR EACH ROW

Обработка созданной партии
->Если партия принимается, то она отправляется на склад.
->Если парти отзывается, то с ней ничего не делается.
-- Отправка партии на склад при принятии на соответствующую полку
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER ParcelToStorage AFTER UPDATE ON Problematic_Parcel FOR EACH ROW
DECLARE
    place_of_storage_id NUMERIC;
    username VARCHAR(32);
    userid NUMERIC;
    goods_type_id NUMERIC;
    goods_storage_condition_id NUMERIC;
    shelf_id NUMERIC;
    shelf_number_of_places NUMERIC;
    
    goodsId NUMERIC;
    goodsNumber NUMERIC;
BEGIN
    IF :new.is_accepted=1 THEN
        SELECT user
            INTO username
            FROM dual;

        SELECT goods_id, goods_number
            INTO goodsId, goodsNumber
            FROM Parcel
            WHERE id=:new.parcel_id;

        SELECT id
            INTO userid
            FROM Staff_member
            WHERE login=username;
    
        SELECT type_id
            INTO goods_type_id
            FROM Goods
            WHERE id=goodsId;
        
        SELECT storage_condition_id
            INTO goods_storage_condition_id
            FROM Goods_type
            WHERE id=goods_type_id;
        
        SELECT id, number_of_places
            INTO shelf_id, shelf_number_of_places
            FROM Shelf
            WHERE (place_of_storage_id=3 AND storage_condition_id=goods_storage_condition_id);

        IF (shelf_number_of_places-goodsNumber)<0 THEN
            DBMS_OUTPUT.put_line('Out of places!');
        ELSE
            INSERT INTO Operation VALUES (
                seq_operation.nextval,
                1,
                userid,
                SYSDATE,
                shelf_id
            );
            UPDATE Shelf
                SET number_of_places=number_of_places-goodsNumber
                WHERE id=shelf_id;
        END IF;
    END IF;
END;

INSERT INTO PARCEL VALUES (
    seq_parcel.nextval,
    1,
    1,
    SYSDATE,
    1,
    4000
    );

Попытка добавления товара в партию
->Если всё хорошо, попытка проводится как обычно
->Если что-то не то, то мы создаём "Problematic Parcel" и ждём, пока он изменится

SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_insert_parcel
    INSTEAD OF INSERT ON Parcel_View
DECLARE
    expected_goodsId NUMERIC NULL;
    expected_supplierId NUMERIC NULL;
    expected_deliveryContractId NUMERIC NULL;
    expected_truckId NUMERIC NULL;
    expected_goodsNumber NUMERIC NULL;
    status VARCHAR(64) NOT NULL := 'OK';
    parcelId NUMERIC NULL;
BEGIN
    SELECT id
        INTO expected_goodsId
        FROM Goods
        WHERE name=:new.goods_name;
    SELECT id
        INTO expected_supplierId
        FROM Supplier
        WHERE enterprise_name=:new.supplier_name;
    SELECT id
        INTO expected_truckId
        FROM Truck
        WHERE plate=:new.truck_plate;
    SELECT id
        INTO expected_deliveryContractId
        FROM Delivery_contract
        WHERE (TO_DATE(delivery_date,'DD-MON-YYYY')=TO_DATE(SYSDATE,'DD-MON-YYYY') AND supplier_id=expected_supplierId);
    SELECT goods_number
        INTO expected_goodsNumber
        FROM Delivery_contract_and_goods
        WHERE (delivery_contract_id=expected_deliveryContractId AND goods_id = expected_goodsId);
            
    IF expected_goodsId=NULL THEN
        status := 'The goods was not found';
        DBMS_OUTPUT.put_line('Out of places!');
        RETURN;
    END IF;
        
    IF expected_supplierId=NULL THEN
        status := 'The supplier was not found';
        DBMS_OUTPUT.put_line('The supplier was not found');
        RETURN;
    END IF;
        
    IF expected_truckId=NULL THEN
        status := 'The truck was not found';
        DBMS_OUTPUT.put_line('The truck was not found');
        RETURN;
    END IF;
        
    IF expected_deliveryContractId=NULL THEN
        status := 'There is no delivery from this supplier today!';
        DBMS_OUTPUT.put_line('There is no delivery from this supplier today!');
    ELSE
        IF expected_goodsNumber=NULL THEN
            status := 'The goods is not expected in this delivery';
            DBMS_OUTPUT.put_line('The goods is not expected in this delivery');
        ELSIF :new.goods_number<>expected_goodsNumber THEN
            status := 'Expected ' || TO_CHAR(expected_goodsNumber) || ' goods. Got ' || TO_CHAR(:new.goods_number);
            DBMS_OUTPUT.put_line(status);
        END IF;
    END IF;
    
    SELECT seq_parcel.nextval
        INTO parcelId
        FROM DUAL;
    IF status='OK' THEN
        INSERT INTO Problematic_Parcel VALUES (
            parcelId,
            status,
            1
        );
    ELSE
        INSERT INTO Problematic_Parcel VALUES (
            parcelId,
            status,
            NULL
        );
    END IF;
    INSERT INTO Parcel VALUES (
        parcelId,
        expected_deliverycontractId,
        expected_goodsId,
        :new.goods_loss_date,
        expected_truckId,
        :new.goods_number
    );
END trg_insert_parcel;

INSERT INTO Parcel_View VALUES (
    'Мясо куриное', 'АГРОМИКС', 'A111AA01', TO_DATE('10-01-23','DD-MM-YY'), 23
);