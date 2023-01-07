INSERT INTO Supplier VALUES (
    seq_supplier.nextval,
    'АГРОМИКС'
);
INSERT INTO Supplier VALUES (
    seq_supplier.nextval,
    'Сладкая идея'
);

INSERT INTO Contractor VALUES (
    seq_contractor.nextval,
    'Контрагентов',
    'Контрагент',
    'Контрагентович',
    '+78005553535',
    1
);
INSERT INTO Contractor VALUES (
    seq_contractor.nextval,
    'Contractor',
    'Contractor',
    NULL,
    '+79006664646',
    1
);
INSERT INTO Contractor VALUES (
    seq_contractor.nextval,
    'Сладенький',
    'Шоколад',
    'Идеевич',
    '+77777777777',
    2
);

INSERT INTO Storage_condition VALUES (
    seq_storage_condition.nextval,
    'Полка'
);
INSERT INTO Storage_condition VALUES (
    seq_storage_condition.nextval,
    'Холодильник'
);
INSERT INTO Storage_condition VALUES (
    seq_storage_condition.nextval,
    'Морозильник'
);

INSERT INTO WriteOff_cause VALUES (
    seq_writeoff_cause.nextval,
    'Истечение срока годности'
);
INSERT INTO WriteOff_cause VALUES (
    seq_writeoff_cause.nextval,
    'Повреждение'
);
INSERT INTO WriteOff_cause VALUES (
    seq_writeoff_cause.nextval,
    'Недостача'
);
INSERT INTO WriteOff_cause VALUES (
    seq_writeoff_cause.nextval,
    'Кража'
);
INSERT INTO WriteOff_cause VALUES (
    seq_writeoff_cause.nextval,
    'Другая причина'
);

INSERT INTO Operation_type VALUES (
    seq_operation_type.nextval,
    'Приход'
);
INSERT INTO Operation_type VALUES (
    seq_operation_type.nextval,
    'Расход'
);

INSERT INTO Goods_type VALUES (
    seq_goods_type.nextval,
    'Мясная продукция',
    3
);
INSERT INTO Goods_type VALUES (
    seq_goods_type.nextval,
    'Молочная продукция',
    2
);
INSERT INTO Goods_type VALUES (
    seq_goods_type.nextval,
    'Десерт',
    2
);

INSERT INTO Job VALUES (
    seq_job.nextval,
    'Администратор'
);
INSERT INTO Job VALUES (
    seq_job.nextval,
    'Товаровед'
);
INSERT INTO Job VALUES (
    seq_job.nextval,
    'Кладовщик'
);
INSERT INTO Job VALUES (
    seq_job.nextval,
    'Продавец'
);

INSERT INTO Division_of_the_company VALUES (
    seq_division_of_the_company.nextval,
    'Техническое оснащение'
);
INSERT INTO Division_of_the_company VALUES (
    seq_division_of_the_company.nextval,
    'Транспортная служба'
);
INSERT INTO Division_of_the_company VALUES (
    seq_division_of_the_company.nextval,
    'Коммерческий отдел'
);

INSERT INTO System_role VALUES (
    seq_system_role.nextval,
    'Admin'
);
INSERT INTO System_role VALUES (
    seq_system_role.nextval,
    'Communicator'
);
INSERT INTO System_role VALUES (
    seq_system_role.nextval,
    'Seller'
);

INSERT INTO Country VALUES (
    seq_country.nextval,
    'Россия'
);
INSERT INTO Country VALUES (
    seq_country.nextval,
    'Китай'
);
INSERT INTO Country VALUES (
    seq_country.nextval,
    'Беларусь'
);

INSERT INTO Producer VALUES (
    seq_producer.nextval,
    'ALTIS',
    1,
    1111
);
INSERT INTO Producer VALUES (
    seq_producer.nextval,
    'Альтернатива',
    1,
    2222
);
INSERT INTO Producer VALUES (
    seq_producer.nextval,
    'Белизна',
    3,
    3333
);
INSERT INTO Producer VALUES (
    seq_producer.nextval,
    'Qin Shi Huan Di',
    2,
    4444
);

INSERT INTO Goods VALUES (
    seq_goods.nextval,
    'Мясо куриное',
    1,
    to_dsinterval('90 00:00:00'),
    4,
    '30x25x10',
    'уп.',
    11111
);
INSERT INTO Goods VALUES (
    seq_goods.nextval,
    'Шоколад Россия',
    3,
    to_dsinterval('14 00:00:00'),
    2,
    '15x7x0.7',
    'шт.',
    22222
);
INSERT INTO Goods VALUES (
    seq_goods.nextval,
    'Торт Вкуснота',
    3,
    to_dsinterval('00 12:00:00'),
    2,
    '20x20x10',
    'шт.',
    33333
);
INSERT INTO Goods VALUES (
    seq_goods.nextval,
    'Фарш говяжий',
    1,
    to_dsinterval('90 00:00:00'),
    2,
    '30x25x10',
    'уп.',
    44444
);
INSERT INTO Goods VALUES (
    seq_goods.nextval,
    'Молоко Бурёнка',
    2,
    to_dsinterval('7 00:00:00'),
    2,
    '30x25x5',
    'уп.',
    55555
);
INSERT INTO Goods VALUES (
    seq_goods.nextval,
    'Конфета Яснополе',
    3,
    to_dsinterval('14 00:00:00'),
    3,
    '3x1.5x1',
    'шт.',
    66666
);

INSERT INTO Truck VALUES (
    seq_truck.nextval,
    'A111AA01'
);
INSERT INTO Truck VALUES (
    seq_truck.nextval,
    'B222BB23'
);

INSERT INTO Staff_member VALUES (
  seq_staff_member.nextval,
  'Товароведов',
  'Товаровед',
  'Товароведыч',
  '0854000001',
  TO_DATE('01/01/01','dd/mm/yy'),
  2,
  2,
  'tovaroved',
  '123456',
  2,
  '+79000000001',
  '+78000000001',
  'toverovedych@mail.ru'
);
INSERT INTO Staff_member VALUES (
    seq_staff_member.nextval,
    'Че',
    'Дел',
    'Чеделыч',
    '5505123456',
    TO_DATE('01.01.01','dd-mm-yy'),
    1,
    1,
    'C##SEAGULL',
    'password',
    1,
    '+00000000000',
    NULL,
    NULL
);

INSERT INTO Place_of_storage VALUES (
  seq_place_of_storage.nextval,
  'ГК'
);
INSERT INTO Place_of_storage VALUES (
  seq_place_of_storage.nextval,
  'РК'
);
INSERT INTO Place_of_storage VALUES (
  seq_place_of_storage.nextval,
  'С'
);
INSERT INTO Place_of_storage VALUES (
  seq_place_of_storage.nextval,
  'ТЗ'
);


INSERT INTO Shelf VALUES (
    seq_shelf.nextval,
    3,
    1,
    '2000'
);
INSERT INTO Shelf VALUES (
    seq_shelf.nextval,
    3,
    2,
    '1000'
);
INSERT INTO Shelf VALUES (
    seq_shelf.nextval,
    3,
    3,
    '7000'
);
INSERT INTO Shelf VALUES (
    seq_shelf.nextval,
    4,
    1,
    '200'
);
INSERT INTO Shelf VALUES (
    seq_shelf.nextval,
    4,
    2,
    '100'
);
INSERT INTO Shelf VALUES (
    seq_shelf.nextval,
    4,
    3,
    '700'
);

INSERT INTO Delivery_contract VALUES (
  seq_delivery_contract.nextval,
  1,
  SYSDATE
);

INSERT INTO Delivery_contract_and_goods VALUES (
    1,
    1,
    30
);
INSERT INTO Delivery_contract_and_goods VALUES (
    1,
    4,
    25
);
