/* 
*** MySQL Course Final Project***
*/

# delete database: 
# DROP DATABASE if exists bbdd_e_commerce;

# create database: 
CREATE DATABASE if not exists bbdd_e_commerce;

# activate database: 
USE bbdd_e_commerce;

-- *************************************
-- ********** Creation of tables: ******
-- *************************************

/* 
***cliente***
Customers of the company: 
*/
CREATE TABLE IF NOT EXISTS cliente (
    ID_CLIENTE INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- customer id 
    ES_EMPRESA BOOLEAN NOT NULL, -- TRUE if the customer is a company 
    DNI_CUIT VARCHAR(30) NOT NULL, -- customer DNI or CUIT 
    CONTRASEÑA_CLIENTE VARCHAR(30) NOT NULL, -- customer password
    MAIL_CLIENTE VARCHAR(100) NOT NULL, -- customer email  
    UNIQUE (DNI_CUIT), -- DNI/CUIT with which customers register cannot be repeated
    UNIQUE (MAIL_CLIENTE) -- Mail with which customers register cannot be repeated
);

/* 
***tarjeta***
It contains all the cards that our customers have registered on our site.
*/

CREATE TABLE IF NOT EXISTS tarjeta (
    ID_TARJETA INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- card ID
    DEBITO_CREDITO VARCHAR(7) NOT NULL, -- credit or debit card
    BANCO VARCHAR(30) NOT NULL, -- Card issuing bank
    ID_CLIENTE INT, -- ID of the customer to whom the card belongs
    FOREIGN KEY (ID_CLIENTE)
        REFERENCES cliente (ID_CLIENTE)
        ON DELETE SET NULL ON UPDATE CASCADE -- it is allowed to delete the customer from the parent table but leaves the record in TARJETA table with ID_CLIENTE = NULL
);

/* 
***METODO_DE_PAGO***
It contains the possible methods of payment with which our company works.
*/

CREATE TABLE IF NOT EXISTS metodo_de_pago (
    ID_METODO_DE_PAGO INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- payment method ID
    METODO_DE_PAGO VARCHAR(50) NOT NULL, -- payment method name 
    UNIQUE (METODO_DE_PAGO) -- payment method name cannot repeat 
);

/* 
***Pedido***
It contains all the orders placed by customers. 
*/
CREATE TABLE IF NOT EXISTS pedido (
    ID_PEDIDO INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- order ID 
    FECHA_PEDIDO DATE NOT NULL, -- order date 
    ID_CLIENTE INT, -- client ID of the client placing the order 
    ID_METODO_DE_PAGO INT NOT NULL, -- payment method of the order
    FOREIGN KEY (ID_CLIENTE)
		REFERENCES cliente (ID_CLIENTE)
        ON DELETE SET NULL ON UPDATE CASCADE, -- it is allowed to delete the customer from the parent table but leaves the record in PEDIDO table with ID_CLIENTE = NULL
	FOREIGN KEY (ID_METODO_DE_PAGO)
		REFERENCES metodo_de_pago (ID_METODO_DE_PAGO)
        ON DELETE RESTRICT ON UPDATE CASCADE -- Arbitrary.
);

/* 
***Tabla Descuento***
It contains the discounts that our company offers to its customers.
*/
CREATE TABLE IF NOT EXISTS descuento (
    ID_DESCUENTO INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- discount ID
    PORCENTAJE_DESCUENTO DECIMAL(5,2) NOT NULL, -- discount % 
    NOMBRE_DESCUENTO VARCHAR(50) NOT NULL, -- discount name 
    DESCRIPCION_DESCUENTO VARCHAR(100) not null, -- discount description 
	UNIQUE (NOMBRE_DESCUENTO), -- two discounts cannot have the same name  
    UNIQUE (DESCRIPCION_DESCUENTO) -- two discounts cannot have the same descr.  
);

/* 
***Tabla Descuento_Pedido***
Bridge table between table DESCUENTO and table PEDIDO. 
Each line is a discount that applies to an order. 
Each order can have more than 1 discount.
*/

CREATE TABLE IF NOT EXISTS descuento_pedido (
    ID_DESCUENTO_PEDIDO INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- discount - order ID 
    ID_DESCUENTO INT NOT NULL, -- discount ID 
    ID_PEDIDO INT NOT NULL, -- order ID 
    FOREIGN KEY (ID_DESCUENTO)
        REFERENCES descuento (ID_DESCUENTO)
        ON DELETE RESTRICT ON UPDATE CASCADE, -- arbitrary
	FOREIGN KEY (ID_PEDIDO)
        REFERENCES pedido (ID_PEDIDO)
        ON DELETE RESTRICT ON UPDATE CASCADE -- arbitrary
);

/* 
***Tabla Proveedor***
Information about our company's suppliers
*/
CREATE TABLE if not exists proveedor (
    ID_PROVEEDOR int not null auto_increment primary key, -- supplier ID 
    NOMBRE_PROVEEDOR varchar(50) not null, -- supplier name 
    TIPO_PROVEEDOR varchar(50) not null, -- supplier type  
    unique (NOMBRE_PROVEEDOR) -- cannot have two suppliers with the same name 
    );
    
/* 
***Tabla producto***
It contains information about the books (products) marketed by our company.
*/
CREATE TABLE IF NOT EXISTS producto (
    ID_LIBRO INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- product (book) ID  
    NOMBRE_LIBRO VARCHAR(150) NOT NULL, -- book name 
    AUTOR_LIBRO VARCHAR(50) NOT NULL, -- book author 
    COSTO_COMPRA_LIBRO DECIMAL(10,2) NOT NULL, -- unitary cost of purchase 
    PRECIO_VENTA_LIBRO DECIMAL(10,2) NOT NULL, -- unitary selling price  
    ID_PROVEEDOR INT, -- supplier ID who sells our company the product 
    FOREIGN KEY (ID_PROVEEDOR)
        REFERENCES proveedor (ID_PROVEEDOR)
        ON DELETE set null ON UPDATE CASCADE, -- if supplier is deleted from parent table the recod is left in this table as ID_PROVEEDOR = NULL.
    UNIQUE (NOMBRE_LIBRO) -- there cannot be two books with the same title  
);

/* 
***Tabla pedido_producto***
Bridge table between tables PEDIDO and PRODUCTO. Each record is a determined quantity of a product inside an order.  
*/
CREATE TABLE IF NOT EXISTS pedido_producto (
    ID_PEDIDO_LIBRO INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- ID of each pedido - libro 
    ID_PEDIDO INT NOT NULL, -- order ID
    ID_LIBRO INT NOT NULL, -- product ID
    CANTIDAD int not null, -- quantity of product inside the order
	FOREIGN KEY (ID_PEDIDO)
        REFERENCES pedido (ID_PEDIDO)
        ON DELETE RESTRICT ON UPDATE CASCADE, -- arbitrary 
	FOREIGN KEY (ID_LIBRO)
        REFERENCES producto (ID_LIBRO)
        ON DELETE RESTRICT ON UPDATE CASCADE -- arbitrary 
);


# Describes: take a look to the tables

/*
describe cliente;
describe tarjeta;
describe metodo_de_pago;
describe pedido;
describe descuento;
describe descuento_pedido;
describe producto;
describe pedido_producto;
describe proveedor;
*/

# drops table (in order so the DELETE RESTRICT does not bother): 
/*
drop table pedido_producto;
drop table producto;
drop table proveedor;
drop table descuento_pedido;
drop table descuento;
drop table pedido;
drop table metodo_de_pago;
drop table tarjeta;
drop table cliente;
*/


# Selects 
/*
select * from cliente;
select * from descuento;
select * from tarjeta;
select * from metodo_de_pago;
select * from pedido;
select * from descuento_pedido;
select * from proveedor;
select * from producto;
select * from pedido_producto;
*/

# *****************************************
# ***************  VIEWs  ***************** 
# *****************************************

/*
View # 1
Top 5 best-selling books   
*/
create or replace view top_5_libros_vendidos as 
(select min(p.nombre_libro) as libro, min(p.autor_libro) as autor_libro, sum(pp.cantidad) as cantidad_vendida 
from pedido_producto pp left join 
producto p on (pp.id_libro = p.id_libro)
group by p.nombre_libro
order by sum(pp.cantidad) desc
limit 5
);

# Check:
# select * from top_5_libros_vendidos;

/*
View # 2
Top 5 best-selling authors
*/
create or replace view top_5_autores_vendidos as
(select min(p.autor_libro) as autor_libro, sum(pp.cantidad) as cantidad_vendida
from pedido_producto pp left join 
producto p on (pp.id_libro = p.id_libro)
group by p.autor_libro
order by sum(pp.cantidad) desc
limit 5
);

# Check:
# select * from top_5_autores_vendidos;

/*
View # 3
Revenue and profit per author (just those authors whose name begins with  "J").
*/
create or replace view ganancia_por_autor as
(select min(p.autor_libro) as autor_libro, 
sum(pp.cantidad * p.precio_venta_libro) as total_venta, 
sum(pp.cantidad * p.costo_compra_libro) as costo_mercaderia_vendida,
sum(pp.cantidad * p.precio_venta_libro - pp.cantidad * p.costo_compra_libro) as beneficio_bruto,
avg((pp.cantidad * p.precio_venta_libro) / (pp.cantidad * p.costo_compra_libro) - 1) as '%_beneficio_bruto'
from pedido_producto pp left join 
producto p on (pp.id_libro = p.id_libro)
group by p.autor_libro
having p.autor_libro like 'J%' 
order by beneficio_bruto desc
);

# check:
# select * from ganancia_por_autor;

/*
View # 4
Join between tables DESCUENTO_PEDIDO and PEDIDO.
Filtering by those orders to which the smallest discount the company currently has was applied. 
A subquery is used since the ID number of the smallest discount is not known a priori. 

*/
create or replace view vista_descuento_menor as
(
select p.id_pedido, dp.id_descuento from descuento_pedido dp right join
pedido p on (dp.id_pedido = p.id_pedido)
Where id_descuento = (SELECT ID_DESCUENTO FROM descuento order by PORCENTAJE_DESCUENTO asc limit 1)
order by p.id_pedido
); 

# Test:
# select * from vista_descuento_menor;

/*
View # 5
Quantity of times each discount was applied to total orders. 
*/
create or replace view ocurrencias_descuentos as
(
select 
    d.id_descuento, d.porcentaje_descuento, d.nombre_descuento, d.descripcion_descuento, dp.cantidad_veces_se_aplico_descuento
from descuento d left join
    (
    select id_descuento, count(*) as cantidad_veces_se_aplico_descuento
    from descuento_pedido
    group by id_descuento
    )dp
    on d.id_descuento = dp.id_descuento
order by dp.cantidad_veces_se_aplico_descuento desc
);

# Test:
# select * from ocurrencias_descuentos;

# *******************************
# ********** FUNCTIONs **********
# *******************************

/* The GANANCIA_PERIODO function calculates the sales profit within the periods passed as parameters
	The dates entered must have a valid date format
    Parameters:
		Param_date_initial: Initial date (format "YYYY-MM-DD")
        Param_date_end: Final date (format "YYYY-MM-DD")
*/

drop function if exists ganancia_periodo;  
delimiter $$ 
create function ganancia_periodo(param_date_initial date, param_date_end date)
returns float -- function will return float  
reads sql data -- function only reads data  
begin 
	declare ganancia_periodo float;
	select sum(a.ganancia_periodo) into ganancia_periodo -- a.ganancia_periodo is the sum of the profits per period
	from 
	--  joins to group profits per period  
	(select p.fecha_pedido, sum((prod.precio_venta_libro * pp.cantidad - prod.costo_compra_libro * pp.cantidad)) as ganancia_periodo 
	from pedido p right join
	pedido_producto pp on 
	p.id_pedido = pp.id_pedido
	left join producto prod on 
	pp.id_libro = prod.id_libro
	where fecha_pedido BETWEEN param_date_initial AND param_date_end
	group by p.fecha_pedido
	)a;
	return ganancia_periodo;
end$$
delimiter ;

# test ganancia_periodo function: 

# select ganancia_periodo('2022-01-01','2022-01-01');
# select ganancia_periodo('2022-03-01','2022-05-01');
# select ganancia_periodo('2022-01-01','2022-12-01');


/* The CONTAR_TARJETAS function calculates the quantity of cards in our data base.
	Parameter: "param_tipo_tarjeta" "crédito" o "débito" for credit or debit type of card. 
*/
drop function if exists contar_tarjetas; 
delimiter $$ 
create function contar_tarjetas(param_tipo_tarjeta varchar(8)) 
returns int 
reads sql data  
begin
	declare resultado_cantidad_tarjetas int;
    select count(*) into resultado_cantidad_tarjetas from tarjeta where debito_credito=param_tipo_tarjeta;
    return resultado_cantidad_tarjetas;
end$$
delimiter ;

# Test contar_tarjetas function:
# select contar_tarjetas("credito");
# select contar_tarjetas("debito");

# ***************************************
# ********** STORED PROCEDURES **********
# ***************************************

#############################################
# Stored procedure # 1: "ordenamiento_producto"
#############################################

-- In this last example we are going to want to modify the clauses of the SELECT query according to the input that we indicate when calling the stored procedure.
-- With this procedure we are going to want to order the records of the table PRODUCTO, depending on a column that we indicate as input parameter.
-- With a second input parameter, we will want to specify if the ordering is ascending or descending.

DROP PROCEDURE IF EXISTS ordenamiento_producto ;
delimiter $$
CREATE PROCEDURE ordenamiento_producto (IN campo_a_ordenar VARCHAR(50), IN orden BOOLEAN)
-- orden=1 -> asc
-- orden=0 -> desc
-- If campo_a_ordenar='' then there is no order
BEGIN
	IF campo_a_ordenar <> '' AND orden = 1 THEN
		SET @ordenar = concat('ORDER BY ', campo_a_ordenar);
	ELSEIF campo_a_ordenar <> '' AND orden = 0 THEN
		SET @ordenar = concat('ORDER BY ', campo_a_ordenar, ' DESC');
	ELSEIF campo_a_ordenar <> '' AND orden NOT IN (0,1) THEN
		SET @ordenar = 'No válido';
		SELECT 'Parámetro de ordenamiento ingresado no válido' AS Mensaje;
    ELSE
		SET @ordenar = '';
	END IF;
    IF @ordenar <> 'No válido' THEN
		SET @clausula_select = concat('SELECT * FROM producto ', @ordenar);
		PREPARE ejecucion FROM @clausula_select;
		EXECUTE ejecucion;
		DEALLOCATE PREPARE ejecucion;
	END IF;
END $$
delimiter ;

# Test:
# CALL ordenamiento_producto ('AUTOR_LIBRO',0);
# CALL ordenamiento_producto ('AUTOR_LIBRO',1);

########################################
# Stored procedure # 2 - "nuevo_proveedor"
########################################

# Stored Procedure that inserts a new supplier in the table "proveedor"
# Supports 2 parameters: 
#     "param_nombre_proveedor" name of the supplier to add
#     "param_tipo_proveedor" type of supplier (SRL, SA, SAS, etc).
# In case the supplier name already exists in the table, a message will be displayed to indicate the problem. 

DROP PROCEDURE IF EXISTS nuevo_proveedor;
DELIMITER $$
CREATE PROCEDURE nuevo_proveedor (IN param_nombre_proveedor varchar(50), IN param_tipo_proveedor varchar(10))
BEGIN
	IF param_nombre_proveedor not in (select nombre_proveedor from proveedor) then -- If the supplier name does not exist in the table, then it proceeds to add the supplier. 
		INSERT INTO proveedor VALUES (DEFAULT, param_nombre_proveedor, param_tipo_proveedor);
	else
		SELECT 'Ya existe un proveedor registrado bajo ese nombre' AS Mensaje; -- If the supplier name already exists, then there is a message indicating the issue. 
	end if;
END $$
DELIMITER ;

-- Test stored procedure: 
# select * from proveedor; -- table before running the SP

# CALL nuevo_proveedor('nuevo_proveedor1', "SA");
# CALL nuevo_proveedor('nuevo_proveedor2', "SRL");
# CALL nuevo_proveedor('nuevo_proveedor3', "SAS");

# CALL nuevo_proveedor('nuevo_proveedor3', "SA"); -- Repeated supplier. Record is not added.  
# select * from proveedor; -- table after running the SP 

# delete of the new suppliers:
# delete from proveedor where nombre_proveedor = "nuevo_proveedor1" 
# or nombre_proveedor = "nuevo_proveedor2" 
# or nombre_proveedor = "nuevo_proveedor3";


########################################
# Stored procedure # 3 - "nuevo_pedido"
########################################

# Stored Procedure that inserts a new ORDER in the tables "PEDIDO", "PEDIDO_PRODUCTO" and "DESCUENTO_PEDIDO"
# It does this through a TRANSACTION since 3 different tables are being impacted.

#  5 parameters: 
#  "id_libro_param" product being ordered  
#  "cant_prod_param" quantity of product being ordered 
#  "fecha_pedido_param" date of the order 
#  "id_cliente_param" client ID who is placing the order  
#  "metodo_de_pago_param" payment method of the order 

# In case the product, customer ID or payment method does not exist in the database, the SP will display a message indicating the problem. 
# In addition, in case the ORDER date is a special date, the corresponding discount will be automatically applied (Ex: Discount for purchase on "Book Day").
# In case the ORDER exceeds 10 items, discount # 1 (Quantity discount) will be applied automatically.

DROP PROCEDURE IF EXISTS nuevo_pedido;
DELIMITER $$
CREATE PROCEDURE nuevo_pedido (IN id_libro_param INT, IN cant_prod_param INT, IN fecha_pedido_param DATE, IN id_cliente_param INT, IN metodo_de_pago_param INT)
BEGIN
	-- 1st Check: if product OR client OR payment method does not exist in the database, then will trigger a message:  
	IF id_libro_param not in (select id_libro from producto) or id_cliente_param not in (select id_cliente from cliente) or metodo_de_pago_param not in (select id_metodo_de_pago from metodo_de_pago) THEN 
        SELECT 'El PRODUCTO o el CLIENTE o el MEDIO de PAGO no existe en la base de datos' AS Mensaje; 
    -- If three of them exist, then the sp continues:
    ELSE
    -- 2nd Check: if any date discount applies:
        IF month(fecha_pedido_param) = 4 and day(fecha_pedido_param) = 23 THEN  -- book day
			SET @id_descuento_fecha = 2;
        ELSEIF month(fecha_pedido_param) = 6 and day(fecha_pedido_param) = 19 THEN -- fathers day 
			SET @id_descuento_fecha =4;
        ELSEIF month(fecha_pedido_param) = 10 and day(fecha_pedido_param) = 16 THEN -- mothers day 
			SET @id_descuento_fecha =5;
        ELSE
			SET @id_descuento_fecha =False; -- If no date discount then turns off @id_descuento_fecha
		END IF;
	-- 3rd Check: Quantity discount:
		IF cant_prod_param > 10 THEN 
			set @id_descuento_cantidad = 1; -- if more than 10 items then turn on @id_descuento_cantidad
		ELSE
			set @id_descuento_cantidad = False; -- if more than 10 items then turn off @id_descuento_cantidad
		END IF;
	
    -- Insert record in the database (3 different tables) :  
		
        START TRANSACTION; # Se inicia la transacción de INSERT
		
    -- 1st INSERT - Insert order in table PEDIDO:
        INSERT INTO pedido VALUES (DEFAULT, fecha_pedido_param, id_cliente_param, metodo_de_pago_param);
        set @id_pedido_insertado = LAST_INSERT_ID(); -- Captures the ID of the registered order 
        -- SELECT @id_pedido_insertado; 
	
    -- 2nd INSERT - order detail (order, product and quantity) into PEDIDO_PRODUCTO bridge table:
        INSERT INTO pedido_producto VALUES (concat(@id_pedido_insertado,id_libro_param),@id_pedido_insertado,id_libro_param, cant_prod_param);
	
    -- 3rd INSERT- Insert order detail and discount in table DESCUENTO_PEDIDO:
		-- Check if quantity discount applies (+ de 10 items)
        IF @id_descuento_cantidad = 1 THEN 
			-- Check date discount 
            -- If quantity and date discount applies, then insert 2 records in bridge table DESCUENTO_PEDIDO:
            IF @id_descuento_fecha THEN 
				INSERT INTO descuento_pedido VALUES (concat(@id_descuento_cantidad,@id_pedido_insertado),@id_descuento_cantidad, @id_pedido_insertado);
                INSERT INTO descuento_pedido VALUES (concat(@id_descuento_fecha,@id_pedido_insertado),@id_descuento_fecha, @id_pedido_insertado);
			-- If only quantity discount: 
            ELSE
				INSERT INTO descuento_pedido VALUES (concat(@id_descuento_cantidad,@id_pedido_insertado),@id_descuento_cantidad, @id_pedido_insertado);
			END IF;
		-- If there is no quantity discount:
		ELSEIF @id_descuento_cantidad = False THEN 
			-- There is date discount 1 record is added to DESCUENTO_PEDIDO table:
            IF @id_descuento_fecha THEN
				INSERT INTO descuento_pedido VALUES (concat(@id_descuento_fecha,@id_pedido_insertado),@id_descuento_fecha, @id_pedido_insertado);
			END IF;
		END IF;
        COMMIT;
	END IF;
END $$
DELIMITER ;

-- Store Procedure test: 

/*
##################### test 2 discounts (mothers day and quantity) #####################

# call SP: (id_libro_param = 1, cant_prod_param = 11, fecha_pedido_param = '2022-10-16', id_cliente_param = 1, metodo_de_pago = 1)
call nuevo_pedido(1,11,"2022-10-16",1,1); # discount # 5 and quantity discount

# check if records were added correctly: 
select * from pedido order by id_pedido desc;
select * from pedido_producto order by id_pedido desc;
select * from descuento_pedido order by id_pedido desc;

# Placeholder to eliminate added records (change ID_PEDIDO):
DELETE FROM pedido WHERE id_pedido = 511;
DELETE FROM pedido_producto WHERE id_pedido = 511;
DELETE FROM descuento_pedido WHERE id_pedido = 511;

##################### test 1 discount (book day) #####################
# call SP: (id_libro_param = 1, cant_prod_param = 1, fecha_pedido_param = '2022-04-23', id_cliente_param = 1, metodo_de_pago = 1)
call nuevo_pedido(1,1,"2022-04-23",1,1); # discount # 2

# check if records were added correctly: 
select * from pedido order by id_pedido desc;
select * from pedido_producto order by id_pedido desc;
select * from descuento_pedido order by id_pedido desc;

# Placeholder to eliminate added records (change ID_PEDIDO):
DELETE FROM pedido WHERE id_pedido = 508;
DELETE FROM pedido_producto WHERE id_pedido = 508;
DELETE FROM descuento_pedido WHERE id_pedido = 508;

##################### test quantity discount (>10 items) #####################

# Call SP: (id_libro_param = 1, cant_prod_param = 1000, fecha_pedido_param = '2022-07-19', id_cliente_param = 1, metodo_de_pago = 1)
call nuevo_pedido(1,1000,"2022-07-19",1,1); # discount # 1

# check if records were added correctly: 
select * from pedido order by id_pedido desc;
select * from pedido_producto order by id_pedido desc;
select * from descuento_pedido order by id_pedido desc;

# Placeholder to eliminate added records (change ID_PEDIDO):
DELETE FROM pedido WHERE id_pedido = 509;
DELETE FROM pedido_producto WHERE id_pedido = 509;
DELETE FROM descuento_pedido WHERE id_pedido = 509;

##################### Test w/o discounts  #####################

# Se llama al SP: (id_libro_param = 1, cant_prod_param = 1, fecha_pedido_param = '2022-07-19', id_cliente_param = 1, metodo_de_pago = 1)
call nuevo_pedido(1,1,"2022-07-19",1,1); # no discount

# check if records were added correctly: 
select * from pedido order by id_pedido desc;
select * from pedido_producto order by id_pedido desc;
select * from descuento_pedido order by id_pedido desc;

# Placeholder to eliminate added records (change ID_PEDIDO):
DELETE FROM pedido WHERE id_pedido = 510;
DELETE FROM pedido_producto WHERE id_pedido = 510;
DELETE FROM descuento_pedido WHERE id_pedido = 510;

*/


# *******************************
# ********* TRIGGERS ************
# *******************************

# ********************* TRIGGER #1  *********************
# ********** "insert LOG" table "PROVEEDOR" **********

# log table to capture metadata of inserts in table "proveedor"
# - id_proveedor
# - nombre_proveedor  
# - tipo_proveedor
# - usuario: who inserted the record 
# - fecha_operacion: insert date 
# - hora_operacion: insert hour 

DROP TABLE IF EXISTS log_insercion_proveedor;
CREATE TABLE log_insercion_proveedor (
id_log INT PRIMARY KEY auto_increment,
id_proveedor INT NOT NULL,
nombre_proveedor VARCHAR(50),
tipo_proveedor VARCHAR(50),
usuario VARCHAR(50),
fecha_operacion date,
hora_operacion time 
);

-- Trigger 

DROP TRIGGER IF EXISTS log_insercion_proveedor;
CREATE TRIGGER log_insercion_proveedor
AFTER INSERT ON proveedor
FOR EACH ROW
INSERT INTO log_insercion_proveedor VALUES (DEFAULT, new.id_proveedor, new.nombre_proveedor, new.tipo_proveedor ,user(), curdate(), curtime());

# Test TRIGGER # 1 - log_insercion_proveedor

# Test for 3 new records in table proveedor:  
INSERT INTO proveedor VALUES 
(21, 'nombre_proveedor21', "SRL"), 
(22, 'nombre_proveedor22', "SRL"),
(23, 'nombre_proveedor23', "SRL");

# Check: 
# select * from log_insercion_proveedor;

# Delete new test records: 
delete from proveedor where id_proveedor = 21 or id_proveedor = 22 or id_proveedor = 23;
# check:
# select * from proveedor;

# *************************** TRIGGER # 2  **************************
# **********  "check supplier name " table "PROVEEDOR" **********

# Trigger to avoid insert of new supplier with blank name 

DROP TRIGGER IF EXISTS chequeo_vacios_proveedor;
DELIMITER $$
CREATE TRIGGER chequeo_vacios_proveedor
BEFORE INSERT ON proveedor
FOR EACH ROW
BEGIN
	IF new.nombre_proveedor = '' THEN
		signal sqlstate '45000' SET message_text = "EL PROVEEDOR TIENE QUE TENER UN NOMBRE";
	END IF;
END $$
DELIMITER ;

# Test TRIGGER # 2 - chequeo_vacios_proveedor 
# INSERT INTO proveedor VALUES (21, '', "SRL"); 

# *********************** TRIGGER # 3 **********************
# ********** After insert table "PRODUCTO" **********

# Insert trigger records AFTER each INSERT in table "producto":
# - user that inserted the record
# - insert date 
# - insert hour
# - inserted name product
# - quantity of products in the inventory AFTER insert in table PRODUCTO
# - avg cost of purchase in the inventory AFTER insert

# Create table to host metadata logs of INSERT in table PRODUCTO
DROP TABLE IF EXISTS tabla_log_insercion_producto;
create table tabla_log_insercion_producto (
id_log int primary key auto_increment,
usuario_operacion varchar(50),
fecha_operacion date,
hora_operacion time, 
id_libro int,
nombre_libro varchar(150),
cantidad_catalogo_libros int,
promedio_costo_libros float
);

# Create trigger INSERT of table PRODUCTO 
DROP TRIGGER IF EXISTS trigger_insercion_producto;
DELIMITER $$
create trigger trigger_insercion_producto
AFTER INSERT on producto
FOR EACH ROW
BEGIN
	SET @cantidad_catalogo_producto = (SELECT COUNT(*) FROM producto); # Variable that stores the number of products in the product table.
    SET @promedio_costo_libros = (SELECT Avg(COSTO_COMPRA_LIBRO) FROM PRODUCTO); # Variable that stores the average cost of the products in the product table.
	INSERT INTO tabla_log_insercion_producto values (
    DEFAULT,
    user(),
    curdate(),
    curtime(),
    new.id_libro, 
    new.nombre_libro, 
    @cantidad_catalogo_producto, 
    @promedio_costo_libros);
END $$
DELIMITER ;

# test TRIGGER # 3 - trigger_insercion_producto:

# First, look for quantity of products in table producto and the avg cost: 

# SELECT COUNT(*) FROM producto;
# SELECT Avg(COSTO_COMPRA_LIBRO) FROM PRODUCTO;
 
# 2nd, insert 1 new product to table producto: 
INSERT INTO producto VALUES (351, 'nombre_libro351', "autor_libro351", 10, 15, 1);

# Check record has been inserted correctly: 
# select * from producto ORDER BY id_libro DESC LIMIT 3;

# Check trigger:

# select * from tabla_log_insercion_producto;
# SELECT COUNT(*) FROM producto;
# SELECT Avg(COSTO_COMPRA_LIBRO) FROM PRODUCTO;

-- Delete record:
delete from producto where ID_LIBRO = 351;


# ************************* TRIGGER # 4 ************************
# ********** before INSERT in table "PRODUCTO" *****************

# Trigger that prevent insert of prohibited product 
# The companys policy is not to have in its catalog any books written by the author VOLDEMORT

DROP TRIGGER IF EXISTS chequeo_producto_prohibido;
DELIMITER $$
CREATE TRIGGER chequeo_producto_prohibido
BEFORE INSERT ON producto
FOR EACH ROW
BEGIN
	IF new.autor_libro = 'VOLDEMORT' THEN
		signal sqlstate '45000' SET message_text = "NO PODES AGREGAR UN LIBRO DEL AUTOR VOLDEMORT";
	END IF;
END $$
DELIMITER ;

# Test TRIGGER # 4 - chequeo_producto_prohibido

# INSERT INTO producto VALUES (351, 'nombre_libro351', "VOLDEMORT", 10, 15, 1); 
# INSERT INTO producto VALUES (351, 'nombre_libro351', "voldemort", 10, 15, 1); 


#  *******************************
#  ******* User creation *********
#  *******************************

# User creation:

CREATE USER IF NOT EXISTS 'usuario_1'@'localhost' identified by '1234'; # User who will have read permissions on all tables
CREATE USER IF NOT EXISTS 'usuario_2'@'localhost' identified by '1234'; # User who will have Read / Insert / Modify permissions on all tables 

# GRANT permissions:

GRANT SELECT ON bbdd_e_commerce.* TO 'usuario_1'@'localhost'; # Read-only permission is granted to the entire database.
GRANT SELECT, INSERT, UPDATE ON bbdd_e_commerce.* TO 'usuario_2'@'localhost'; # usuario_2 is granted Read, Insert and Update permissions to the entire database.

# Granted permissions:

# SHOW GRANTS FOR 'usuario_1'@'localhost';
# SHOW GRANTS FOR 'usuario_2'@'localhost';

#  *******************************************
#  ****** Transaction Control Language *******
#  *******************************************

#############################################
# DELETE records table TARJETA 
#############################################

# Check tabla before DELETE: 
# select * from tarjeta order by id_tarjeta desc;

# DELETE w TCL:

START TRANSACTION;  
DELETE FROM tarjeta WHERE id_tarjeta = 100 or id_tarjeta = 99 or id_tarjeta = 98;
# ROLLBACK;
COMMIT; 

# Check table after DELETE: 
# select * from tarjeta order by id_tarjeta desc;

# Insert deleted records : 
insert into tarjeta (id_tarjeta, debito_credito, banco, id_cliente) 
values (100,'DEBITO', 'Provincia de Buenos aires', 58),
(99,'DEBITO', 'Banco Frances', 44),
(98, 'CREDITO', 'Provincia de Buenos aires', 67);

# Check table after re-INSERT: 
# select * from tarjeta order by id_tarjeta desc;

####################################
# INSERT in table DESCUENTO 
####################################

# Check table before INSERT: 
# select * from descuento order by id_descuento desc;

# INSERT:

START TRANSACTION;
# Insert 4 records:
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (6, 0.01, 'nombre_descuento6', 'descripcion_descuento6');
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (7, 0.01, 'nombre_descuento7', 'descripcion_descuento7');
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (8, 0.01, 'nombre_descuento8', 'descripcion_descuento8');
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (9, 0.01, 'nombre_descuento9', 'descripcion_descuento9');
# SAVEPOINT:
SAVEPOINT primeros_cuatro_registros;
# Insert another 4 records:
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (10, 0.01, 'nombre_descuento10', 'descripcion_descuento10');
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (11, 0.01, 'nombre_descuento11', 'descripcion_descuento11');
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (12, 0.01, 'nombre_descuento12', 'descripcion_descuento12');
insert into descuento (id_descuento, porcentaje_descuento, nombre_descuento, descripcion_descuento) values (13, 0.01, 'nombre_descuento13', 'descripcion_descuento13');
# 2nd SAVEPOINT:
SAVEPOINT segundos_cuatro_registros;

# select inside TRANSACTION to see how table DESCUENTO would be if commited:
# SELECT * FROM descuento ORDER BY id_descuento desc;

# Rollbacks to SAVEPOINTs:

# ROLLBACK TO segundos_cuatro_registros;
# SELECT * FROM descuento ORDER BY id_descuento desc;

# ROLLBACK TO primeros_cuatro_registros;
# SELECT * FROM descuento ORDER BY id_descuento desc;

# Delete SAVEPOINTs:

# RELEASE SAVEPOINT primeros_cuatro_registros;
# RELEASE SAVEPOINT segundos_cuatro_registros;

ROLLBACK;
# COMMIT; 
# DELETE FROM descuento WHERE id_descuento in (6,7,8,9,10,11,12,13);

# SELECT * FROM descuento ORDER BY id_descuento desc; # Para observar que luego del ROLLBACK la tabla DESCUENTO quedó inalterada.

