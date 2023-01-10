-- БП1.
--
--Проверка товара на наличие в БД; Вывод даты пропажи товара на основе даты изготовления (инф-ция исп-ся в БП2);
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
        
    -- Проверка остатков партии на полке по ИС
    FUNCTION parcel_residue(parcelId NUMERIC, shelfId NUMERIC)
        RETURN NUMERIC;
END;
/
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
        PIPE ROW (rec); -- Асинхронно отправляется в return

        RETURN;
    END checkGoods;

    FUNCTION parcel_residue(parcelId NUMERIC, shelfId NUMERIC)
        RETURN NUMERIC IS
        lastStocktakingId NUMERIC;
        lastStocktakingDate DATE;
        CURSOR c_last_stocktaking IS
            SELECT S.id, S.executing_date
            INTO lastStocktakingId, lastStocktakingDate
            FROM Stocktaking S, Stocktaking_parcel SP
            WHERE (
                S.id=SP.stocktaking_id AND
                SP.parcel_id=parcelId AND
                SP.shelf_id=shelfId
            )
            ORDER BY S.executing_date DESC
            OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
            
        positive_operation NUMERIC:=0;
        cursor c_positive_operation IS
            SELECT NVL(SUM(OaP.goods_number),0)
                INTO positive_operation
                FROM Operation O, Operation_and_parcel OaP
                WHERE (
                    O.shelf_id=shelfId AND OaP.parcel_id=parcelId AND -- Нужные полка и партия
                    O.type_id=1 AND -- Приход
                    OaP.operation_id=O.id
                );
        cursor c_positive_operation_from_date IS
            SELECT NVL(SUM(OaP.goods_number),0)
                INTO positive_operation
                FROM Operation O, Operation_and_parcel OaP
                WHERE (
                    O.shelf_id=shelfId AND OaP.parcel_id=parcelId AND -- Нужные полка и партия
                    O.type_id=1 AND -- Приход
                    O.executing_date>lastStocktakingDate AND -- После последней инвентаризации
                    OaP.operation_id=O.id
                );
        negative_operation NUMERIC:=0;
        cursor c_negative_operation IS
            SELECT NVL(SUM(OaP.goods_number),0)
                INTO positive_operation
                FROM Operation O, Operation_and_parcel OaP
                WHERE (
                    O.shelf_id=shelfId AND OaP.parcel_id=parcelId AND -- Нужные полка и партия
                    O.type_id=2 AND -- Расход
                    OaP.operation_id=O.id
                );
        cursor c_negative_operation_from_date IS
            SELECT NVL(SUM(OaP.goods_number),0)
                INTO positive_operation
                FROM Operation O, Operation_and_parcel OaP
                WHERE (
                    O.shelf_id=shelfId AND OaP.parcel_id=parcelId AND -- Нужные полка и партия
                    O.type_id=2 AND -- Расход
                    O.executing_date>lastStocktakingDate AND -- После последней инвентаризации
                    OaP.operation_id=O.id
                );
        
        lastResidue NUMERIC;
        cursor c_last_residue IS
            SELECT stock
            FROM Stocktaking_parcel
            WHERE (
                stocktaking_id=lastStocktakingId AND
                parcel_id=parcelId AND
                shelf_id=shelfId
                );
        
        residue NUMERIC :=0;
    BEGIN
        OPEN c_last_stocktaking;
        FETCH c_last_stocktaking INTO lastStocktakingId, lastStocktakingDate;
        IF c_last_stocktaking%notfound THEN    
            open c_positive_operation;
            fetch c_positive_operation into positive_operation;
            CLOSE c_positive_operation;
        
            open c_negative_operation;
            fetch c_negative_operation into negative_operation;
            CLOSE c_negative_operation;
        ELSE
            open c_positive_operation_from_date;
            fetch c_positive_operation_from_date into positive_operation;
            CLOSE c_positive_operation_from_date;
        
            open c_negative_operation_from_date;
            fetch c_negative_operation_from_date into negative_operation;
            CLOSE c_negative_operation_from_date;
            
            OPEN c_last_residue;
            FETCH c_last_residue INTO lastResidue;
            CLOSE c_last_residue;
            positive_operation := positive_operation+lastResidue;
        END IF;
        CLOSE c_last_stocktaking;
            
        residue := positive_operation-negative_operation;
        RETURN residue;
    END parcel_residue;
END;
/
--БП2
--
-- Изменение количества места на полке, если мы добавили или убрали с неё товар Операцией
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_update_shelf_by_operation
    FOR INSERT ON Operation_and_parcel
    COMPOUND TRIGGER
    
    operationType NUMERIC;
    shelfId NUMERIC;

    goodsNumber NUMERIC;
    --PRAGMA autonomous_transaction;
BEFORE EACH ROW IS BEGIN
    SELECT type_id, shelf_id
        INTO operationType, shelfId
        FROM Operation
        WHERE id=:new.operation_id;
    goodsNumber := :new.goods_number;
END BEFORE EACH ROW;

AFTER STATEMENT IS BEGIN
    IF operationType=1 THEN
        UPDATE Shelf
            SET number_of_places=number_of_places-goodsNumber 
            WHERE id=shelfId;
    ELSE
        UPDATE Shelf
            SET number_of_places=number_of_places+goodsNumber 
            WHERE id=shelfId;
    END IF;
END AFTER STATEMENT; 
END trg_update_shelf_by_operation;
/
-- Попытка добавления товара в партию.
-- Если всё хорошо, попытка проводится как обычно, в Problematic Parcel состояние "ОК" и IS_ACCESSED=1 (Принято)
-- Если что-то не то, то записываем в статус Problematic Parcel состояние ошибки, IS_ACCESSED=NULL
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_insert_parcel
    INSTEAD OF INSERT ON Parcel_View
    FOR EACH ROW
DECLARE
    expected_goodsId NUMERIC NULL;
    expected_supplierId NUMERIC NULL;
    expected_deliveryContractId NUMERIC NULL;
    expected_truckId NUMERIC NULL;
    expected_goodsNumber NUMERIC NULL;
    status VARCHAR(64) NOT NULL := 'OK';
    parcelId NUMERIC NULL;
BEGIN
    BEGIN
        SELECT id
            INTO expected_goodsId
            FROM Goods
            WHERE name=:new.goods_name;
        EXCEPTION WHEN no_data_found THEN
            status := 'The goods was not found';
            DBMS_OUTPUT.put_line(status);
            RETURN;
    END;
    BEGIN
        SELECT id
            INTO expected_supplierId
            FROM Supplier
            WHERE enterprise_name=:new.supplier_name;
        EXCEPTION WHEN no_data_found THEN
            status := 'The supplier was not found';
            DBMS_OUTPUT.put_line(status);
            RETURN;
    END;
    BEGIN
        SELECT id
            INTO expected_truckId
            FROM Truck
            WHERE plate=:new.truck_plate;
        EXCEPTION WHEN no_data_found THEN
            status := 'The truck was not found';
            DBMS_OUTPUT.put_line(status);
            RETURN;
    END;
    BEGIN
        SELECT id
            INTO expected_deliveryContractId
            FROM Delivery_contract
            WHERE (TO_DATE(delivery_date,'DD-MON-YYYY')=TO_DATE(SYSDATE,'DD-MON-YYYY') AND supplier_id=expected_supplierId);
        EXCEPTION WHEN no_data_found THEN
            status := 'There is no delivery from this supplier today!';
            expected_deliveryContractId := 0;
            DBMS_OUTPUT.put_line(status);
    END;
    BEGIN
        IF expected_deliveryContractId<>0 THEN
            SELECT goods_number
                INTO expected_goodsNumber
                FROM Delivery_contract_and_goods
                WHERE (delivery_contract_id=expected_deliveryContractId AND goods_id = expected_goodsId);    
            IF :new.goods_number<>expected_goodsNumber THEN
                status := 'Expected ' || TO_CHAR(expected_goodsNumber) || ' goods. Got ' || TO_CHAR(:new.goods_number);
                DBMS_OUTPUT.put_line(status);
            END IF;
        END IF;
        EXCEPTION WHEN no_data_found THEN
            status := 'The goods is not expected in this delivery';
            DBMS_OUTPUT.put_line(status);
    END;
    
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
/
-- Обработка созданной партии:
-- Если партия принимается (Problematic_parcel.is_accessed=1), то она отправляется на склад на соответствующую полку;
-- Если парти отзывается (Problematic_parcel.is_accessed=1) или решение о принятии ещё не принято (=NULL), то с ней ничего не делается.
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_parcel_to_s
    AFTER UPDATE OF is_accepted ON Problematic_Parcel
    FOR EACH ROW
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
    operationId NUMERIC;

    --PRAGMA autonomous_transaction;
BEGIN
    IF :new.is_accepted=1 THEN
        SELECT user
            INTO username
            FROM dual;
        SELECT id
            INTO userid
            FROM Staff_member
            WHERE login=username;

        SELECT goods_id, goods_number
            INTO goodsId, goodsNumber
            FROM Parcel
            WHERE id=:new.parcel_id;
    
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
            SELECT seq_operation.nextval
                INTO operationId
                FROM DUAL;
            INSERT INTO Operation VALUES (
                operationId,
                1,
                userid,
                SYSDATE,
                shelf_id
            );
            INSERT INTO Operation_and_parcel VALUES (
                operationId,
                :new.parcel_id,
                goodsNumber
            );
        END IF;
    END IF;
END trg_parcel_to_s;
/
-- Движение партии со склада в торговый зал, если в нём есть место (На самом деле, пока что можно с любой полки на любую полку тягать)
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_parcel_from_s_to_tz
    INSTEAD OF INSERT ON Parcel_from_S_to_TZ
    FOR EACH ROW
DECLARE
    STZ_numberOfPlaces NUMERIC;

    operationId NUMERIC;
    userName VARCHAR2(64);
    userId NUMERIC;

    --PRAGMA autonomous_transaction;
BEGIN
    SELECT number_of_places
        INTO STZ_numberOfPlaces
        FROM Shelf
        WHERE id=:new.STZid;
    
    IF STZ_numberOfPlaces < :new.goods_number THEN -- Есть ли у нас достаточно места в ТЗ?
        DBMS_OUTPUT.put_line('Out of places!'); -- Если нет, то выводим сообщение об ошибке
        RETURN;
    ELSE -- Иначе проведение операцию по переносу партии
        SELECT user
            INTO userName
            FROM dual;
        SELECT id
            INTO userId
            FROM Staff_member
            WHERE login=userName;

        -- Проведение операции по расходу на складе
        SELECT seq_operation.nextval
            INTO operationId
            FROM DUAL;
        INSERT INTO Operation VALUES (
            operationId,
            2,
            userId,
            SYSDATE,
            :new.SSid
        );
        INSERT INTO Operation_and_parcel VALUES (
            operationId,
            :new.parcel_id,
            :new.goods_number
        );

        -- Проведение операции по приходу в ТЗ
        SELECT seq_operation.nextval
            INTO operationId
            FROM DUAL;
        INSERT INTO Operation VALUES (
            operationId,
            1,
            userId,
            SYSDATE,
            :new.STZid
        );
        INSERT INTO Operation_and_parcel VALUES (
            operationId,
            :new.parcel_id,
            :new.goods_number
        );
    END IF; 
END trg_parcel_from_s_to_tz;
/
-- Списание товара с указанием причины
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_writeOff_insert
    INSTEAD OF INSERT ON WriteOff_view
    FOR EACH ROW
DECLARE
    writeOffId NUMERIC;
    userName VARCHAR2(64);
    userId NUMERIC;

    --PRAGMA autonomous_transaction;
BEGIN
    SELECT seq_writeoff.nextval
        INTO writeOffId
        FROM DUAL;

    SELECT user
        INTO userName
        FROM dual;
    SELECT id
        INTO userId
        FROM Staff_member
        WHERE login=userName;

    INSERT INTO WriteOff VALUES (
        writeOffId,
        :new.cause_id,
        :new.shelf_id,
        userId,
        SYSDATE,
        :new.commentary
    );
    INSERT INTO WritedOff_and_parcel VALUES (
        writeOffId,
        :new.parcel_id,
        :new.parcel_number
    );
END trg_parcel_from_s_to_tz;
/
-- Заполнение торгового зала при наличии свободных мест на полке
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_fill_tz
    FOR UPDATE OF number_of_places ON Shelf
    COMPOUND TRIGGER 
    
    isShelfUpdated BOOLEAN := FALSE;
    isTZShelf BOOLEAN;
    gotShelfId NUMERIC;
    TZShelfId NUMERIC;
    TZShelfStorageConditionId NUMERIC;
    TZShelfNumberOfPlaces NUMERIC;
    parcelId NUMERIC;
    parcelResidue NUMERIC;
    SShelfId NUMERIC;

    --PRAGMA autonomous_transaction;
BEFORE EACH ROW IS
BEGIN
    IF (:new.number_of_places-:old.number_of_places<0 AND (:new.id=1 OR :new.id=2 OR :new.id=3)) THEN
        isShelfUpdated := TRUE;
        isTZShelf := FALSE;
        gotShelfId := :new.id;
    ELSIF (:new.number_of_places-:old.number_of_places>0 AND (:new.id=4 OR :new.id=5 OR :new.id=6)) THEN
        isShelfUpdated := TRUE;
        isTZShelf := TRUE;
        gotShelfId := :new.id;
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS  
BEGIN
    IF (isShelfUpdated=TRUE) THEN
    BEGIN
        -- Получить id полки в ТЗ
        IF (isTZShelf=TRUE) THEN
            TZShelfId := gotShelfId;
        ELSE
            SELECT TZS.id
                INTO TZShelfId
                FROM Shelf TZS, Shelf SS
                WHERE (
                    SS.id = gotShelfId AND
                    TZS.place_of_storage_id=4 AND
                    TZS.storage_condition_id=SS.storage_condition_id
                    );
        END IF;
        
        -- Получить данные о полке в ТЗ
        SELECT storage_condition_id, number_of_places
            INTO TZShelfStorageConditionId, TZShelfNumberOfPlaces
            FROM Shelf
            WHERE id=TZShelfId;
        
        -- Данные о партии на складе
        SELECT P.id, S.id, exam.parcel_residue(P.id,S.id)
            INTO parcelId, SShelfId, parcelResidue
            FROM Operation O, Operation_and_parcel OaP, Parcel P, Shelf S
            WHERE (
                S.place_of_storage_id=3 AND
                OaP.parcel_id=P.id AND
                O.shelf_id=S.id AND
                OaP.operation_id=O.id AND
                S.storage_condition_id=TZShelfStorageConditionId AND
                exam.parcel_residue(P.id,S.id)>0
                )
            ORDER BY O.executing_date
            OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
            
        IF TZShelfNumberOfPlaces>parcelResidue THEN -- Если место на полке ещё останется 
            INSERT INTO Parcel_from_S_to_TZ VALUES (
                SShelfId,
                TZShelfId,
                parcelId,
                parcelResidue
                );
        ELSE -- Если места на полке уже не останется
            INSERT INTO Parcel_from_S_to_TZ VALUES (
                SShelfId,
                TZShelfId,
                parcelId,
                TZShelfNumberOfPlaces
                );
        END IF;
        isShelfUpdated := FALSE;
    EXCEPTION
    WHEN no_data_found THEN
        isShelfUpdated := FALSE;
    END;
    END IF;
END AFTER STATEMENT;  
END trg_fill_tz;
/
-- Проведение расходной операции по подтверждённому списанию
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_writeOff_update_operate
    FOR UPDATE OF commentary ON WriteOff
COMPOUND TRIGGER
    shelfId NUMERIC;
    parcelId NUMERIC;
    parcelNumber NUMERIC;
    
    operate BOOLEAN := FALSE;
BEFORE EACH ROW IS BEGIN
    IF :new.commentary='OK' THEN
        operate := TRUE;
        shelfId := :new.shelf_id;
        SELECT parcel_id, parcel_number
            INTO parcelId, parcelNumber
            FROM WritedOff_and_parcel
            WHERE writeOff_id=:new.id;
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS BEGIN
    INSERT INTO Parcel_from VALUES (
        shelfId,
        parcelId,
        parcelNumber
        );
    operate := FALSE;
END AFTER STATEMENT;  
END trg_writeOff_update_operate;
/
-- Расходная операция c полки
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_parcel_from
    INSTEAD OF INSERT ON Parcel_from
    FOR EACH ROW
DECLARE
    userName VARCHAR2(64);
    userId NUMERIC;
    operationId NUMERIC;
BEGIN
    SELECT user
        INTO userName
        FROM dual;
    SELECT id
        INTO userId
        FROM Staff_member
        WHERE login=userName;
        
    -- Проведение операции по расходу на полке
    SELECT seq_operation.nextval
        INTO operationId
        FROM DUAL;
    INSERT INTO Operation VALUES (
        operationId,
        2,
        userId,
        SYSDATE,
        :new.shelf_id
    );
    INSERT INTO Operation_and_parcel VALUES (
        operationId,
        :new.parcel_id,
        :new.goods_number
    );
END trg_parcel_from;
/
-- Обработка новой записи в инвентаризацию
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_stocktaking_parcel
    INSTEAD OF INSERT ON Stocktaking_parcel_view
    FOR EACH ROW
DECLARE
    stocktakingId NUMERIC;
    userName VARCHAR(32);
    userId NUMERIC;
BEGIN
    BEGIN
        SELECT id
            INTO stocktakingId
            FROM Stocktaking
            WHERE executing_date=SYSDATE;
        EXCEPTION
        WHEN no_data_found THEN
            BEGIN
                SELECT user
                    INTO userName
                    FROM dual;
                SELECT id
                    INTO userId
                    FROM Staff_member
                    WHERE login=userName;
                SELECT seq_stocktaking.nextval
                    INTO stocktakingId
                    FROM Dual;
                INSERT INTO Stocktaking VALUES (
                    stocktakingId,
                    userid,
                    SYSDATE
                );
            END;
    END;
    INSERT INTO Stocktaking_parcel VALUES (
        seq_stocktaking_parcel.nextval,
        stocktakingId,
        :new.parcel_id,
        :new.shelf_id,
        :new.stock
    );
END trg_stocktaking_parcel;
/
-- Создание объекта инвентаризации во время проведения
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_stocktaking_parcel
    INSTEAD OF INSERT ON Stocktaking_parcel_view
    FOR EACH ROW
DECLARE
    stocktakingId NUMERIC;
    userName VARCHAR(32);
    userId NUMERIC;
BEGIN
    BEGIN
        SELECT id
            INTO stocktakingId
            FROM Stocktaking
            WHERE TO_DATE(executing_date,'dd-mm-yy')=TO_DATE(SYSDATE,'dd-mm-yy');
        EXCEPTION WHEN no_data_found THEN
            BEGIN
                SELECT user
                    INTO userName
                    FROM dual;
                SELECT id
                    INTO userId
                    FROM Staff_member
                    WHERE login=userName;
                SELECT seq_stocktaking.nextval
                    INTO stocktakingId
                    FROM Dual;
            END;
    END;
    INSERT INTO Stocktaking_parcel VALUES (
        seq_stocktaking_parcel.nextval,
        stocktakingId,
        :new.parcel_id,
        :new.shelf_id,
        :new.stock
    );
    INSERT INTO Stocktaking VALUES (
        stocktakingId,
        userid,
        SYSDATE
        );
END trg_stocktaking_parcel;
/
-- Сравнение стоков с данными в ИС с целью найти пропажу
SET SERVEROUTPUT ON
CREATE OR REPLACE TRIGGER trg_stealing
    FOR INSERT ON Stocktaking_parcel
    COMPOUND TRIGGER
    
    parcelId NUMERIC;
    shelfId NUMERIC;
    stock NUMERIC;
    
    expectedStock NUMERIC;
    
BEFORE EACH ROW IS BEGIN
    stock:=:new.stock;
    parcelId:=:new.parcel_id;
    shelfId:=:new.shelf_id;
    SELECT number_of_goods
        INTO expectedStock
        FROM Shelf_and_parcel
        WHERE (
            parcel_id=parcelId AND
            shelf_id=shelfId
            );
END BEFORE EACH ROW;

AFTER STATEMENT IS BEGIN
    IF expectedStock>stock THEN
        INSERT INTO WriteOff_view VALUES (
            shelfId,
            parcelId,
            expectedStock-stock,
            4,
            'inventarization'
        );
    END IF;
END AFTER STATEMENT;
END trg_stealing;
/
-- Информация о товарах из партий, привезённых сегодня
SELECT G.name as Goods_name, GT.name as Goods_type, G.shelf_life, DCaG.goods_number, DC.delivery_date, S.enterprise_name
FROM Goods G, Delivery_contract_and_goods DCaG, Delivery_contract DC, Goods_type GT, Supplier S
WHERE (G.id=DCaG.goods_id AND DCAG.delivery_contract_id=DC.id AND TO_DATE(DC.delivery_date,'DD-MON-YYYY')=TO_DATE(SYSDATE,'DD-MON-YYYY') AND G.type_id=GT.id AND DC.supplier_id=S.id);

INSERT INTO Parcel_View VALUES (
    'Мясо куриное', 'АГРОМИКС', 'A111AA01', TO_DATE('10-01-23','DD-MM-YY'), 23
);

UPDATE Problematic_parcel SET is_accepted=1 WHERE parcel_id=1;

UPDATE Shelf SET number_of_places=number_of_places+5 WHERE id=3;

INSERT INTO WriteOff_view VALUES (
    6,
    1,
    5,
    1,
    'smth'
);

UPDATE WriteOff
    SET commentary='OK'
    WHERE id=1;

select exam.parcel_residue(1,6) from dual;

INSERT INTO Stocktaking_parcel_view VALUES (
    1,
    6,
    1
);

DBMS_OUTPUT.put_line('');