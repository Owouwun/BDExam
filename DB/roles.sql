CREATE ROLE c##administrator;
CREATE ROLE c##tovaroved;
CREATE ROLE c##kladovschik;

GRANT CREATE SESSION TO c##administrator;
GRANT CREATE SESSION TO c##tovaroved;
GRANT CREATE SESSION TO c##kladovschik;

GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Supplier TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Contractor TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.WriteOff_cause TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation_type TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Goods_type TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Job TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Division_of_the_company TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.System_role TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Country TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Producer TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Goods TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Truck TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Staff_member TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Place_of_storage TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Shelf TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Delivery_contract TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Delivery_contract_and_goods TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Parcel TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation_and_parcel TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.WriteOff TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.WritedOff_and_parcel TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Stocktaking TO c##administrator;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Stocktaking_parcel TO c##administrator;

GRANT SELECT ON c##seagull.Supplier TO c##tovaroved;
GRANT SELECT ON c##seagull.Contractor TO c##tovaroved;
GRANT SELECT ON c##seagull.WriteOff_cause TO c##tovaroved;
GRANT SELECT ON c##seagull.Operation_type TO c##tovaroved;
GRANT SELECT ON c##seagull.Goods_type TO c##tovaroved;
GRANT SELECT ON c##seagull.Job TO c##tovaroved;
GRANT SELECT ON c##seagull.Division_of_the_company TO c##tovaroved;
GRANT SELECT ON c##seagull.System_role TO c##tovaroved;
GRANT SELECT ON c##seagull.Country TO c##tovaroved;
GRANT SELECT ON c##seagull.Producer TO c##tovaroved;
GRANT SELECT ON c##seagull.Goods TO c##tovaroved;
GRANT SELECT ON c##seagull.Truck TO c##tovaroved;
GRANT SELECT ON c##seagull.Staff_member TO c##tovaroved;
GRANT SELECT ON c##seagull.Place_of_storage TO c##tovaroved;
GRANT SELECT, UPDATE ON c##seagull.Shelf TO c##tovaroved;
GRANT SELECT ON c##seagull.Delivery_contract TO c##tovaroved;
GRANT SELECT ON c##seagull.Delivery_contract_and_goods TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Parcel TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation_and_parcel TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.WriteOff TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.WritedOff_and_parcel TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Stocktaking TO c##tovaroved;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Stocktaking_parcel TO c##tovaroved;

GRANT SELECT ON c##seagull.Operation_type TO c##kladovschik;
GRANT SELECT ON c##seagull.Job TO c##kladovschik;
GRANT SELECT ON c##seagull.Division_of_the_company TO c##kladovschik;
GRANT SELECT ON c##seagull.System_role TO c##kladovschik;   
GRANT SELECT ON c##seagull.Staff_member TO c##kladovschik;
GRANT SELECT ON c##seagull.Place_of_storage TO c##kladovschik;
GRANT SELECT, UPDATE ON c##seagull.Shelf TO c##kladovschik;
GRANT SELECT, INSERT ON c##seagull.Parcel TO c##kladovschik;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation TO c##kladovschik;
GRANT SELECT, INSERT, DELETE, UPDATE ON c##seagull.Operation_and_parcel TO c##kladovschik;